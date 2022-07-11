import MappoCore
import NIO
import Foundation

class MatrixChannel: Sendable {
	typealias Message = MatrixMessage
	typealias UserID = String

	let client: MatrixClient
	let room: String

	init(client: MatrixClient, room: String) {
		self.client = client
		self.room = room
	}

	func send(_ text: String) async throws -> Message {
		let msg = try await client.sendMessage(to: room, content: MatrixMessageContent(
			html: text.replacingMentionsWithHTML,
			plaintext: text.replacingMentionsWithPlaintext
		))
		return MatrixMessage(client: client, room: room, messageID: msg)
	}

	func send(_ embed: CommunicationEmbed) async throws -> Message {
		let msg = try await client.sendMessage(to: room, content:
			MatrixMessageContent(
				html: "<h4>\(embed.title.replacingMentionsWithHTML)</h4>\n\(embed.body.replacingMentionsWithHTML)",
				plaintext: "\(embed.title.replacingMentionsWithPlaintext)\n\n\(embed.body.replacingMentionsWithPlaintext)"
			)
		)
		return MatrixMessage(client: client, room: room, messageID: msg)
	}

	func send(_ buttons: [CommunicationButton]) async throws -> Message {
		let htmlPrefix = "<h4>Take an action</h4>\n"
		let plainPrefix = "Take an action\n\n"

		let mapped = buttons.map { "\($0.label): send m!\($0.id)" }
		let htmlBody = mapped.joined(separator: "<br>")
		let plainBody = mapped.joined(separator: "\n")

		let msg = try await client.sendMessage(to: room, content: MatrixMessageContent(html: htmlPrefix + htmlBody, plaintext: plainPrefix + plainBody))
		return MatrixMessage(client: client, room: room, messageID: msg)
	}

	func send(userSelection options: [UserID], id: String, label: String) async throws -> Message {
		let htmlPrefix = "<h4>\(label.replacingMentionsWithHTML)</h4>\n"
		let plainPrefix = "\(label.replacingMentionsWithPlaintext)\n\n"

		let htmlBody = options.indices.map { "<a href='https://matrix.to/#/\(options[$0])'>\(options[$0])</a>: send m?\(id) \($0)" }.joined(separator: "<br>")
		let plainBody = options.indices.map { "\(options[$0]): send m?\(id) \($0)" }.joined(separator: "\n")

		activeSelections[room] = options

		let msg = try await client.sendMessage(to: room, content: MatrixMessageContent(html: htmlPrefix + htmlBody, plaintext: plainPrefix + plainBody))
		return MatrixMessage(client: client, room: room, messageID: msg)
	}
}

class MatrixMessage: Deletable, Replyable {
	let roomID: String
	let messageID: String
	let client: MatrixClient

	init(client: MatrixClient, room: String, messageID: String) {
		self.roomID = room
		self.messageID = messageID
		self.client = client
	}

	func delete() async throws {
		try await client.redactEvent(id: messageID, in: roomID)
	}

	func reply(with text: String, epheremal: Bool) async throws {
		_ = try await client.sendMessage(to: roomID, content: MatrixMessageContent(
			html: text.replacingMentionsWithHTML,
			plaintext: text.replacingMentionsWithPlaintext
		))
	}

	func reply(with embed: CommunicationEmbed, epheremal: Bool) async throws {
		_ = try await client.sendMessage(to: roomID, content:
			MatrixMessageContent(
				html: "<h4>\(embed.title.replacingMentionsWithHTML)</h4>\n\(embed.body.replacingMentionsWithHTML)",
				plaintext: "\(embed.title.replacingMentionsWithPlaintext)\n\n\(embed.body.replacingMentionsWithPlaintext)"
			)
		)
	}
}

final class MatrixCommunication: Communication {
	typealias UserID = String
	typealias Channel = MatrixChannel
	typealias Message = MatrixMessage
	typealias Interaction = MatrixMessage

	let client: MatrixClient

	init(client: MatrixClient) {
		self.client = client
	}

	func getChannel(for userID: UserID, state: State<MatrixCommunication>) async throws -> Channel? {
		let dmID = try await client.getDM(for: userID)
		return MatrixChannel(client: client, room: dmID)
	}

	func createGameThread(state: State<MatrixCommunication>) async throws -> Channel? {
		return state.channel
	}

	func archive(_: Channel, state: State<MatrixCommunication>) async throws {
		// nothing
	}

	func onJoined(_ user: UserID, state: State<MatrixCommunication>) async throws {
		users[user] = state
	}

	func onLeft(_ user: UserID, state: State<MatrixCommunication>) async throws {
		users.removeValue(forKey: user)
	}
}

// room -> state
var states: [String: State<MatrixCommunication>] = [:]

// user -> state
var users: [String: State<MatrixCommunication>] = [:]

// room -> selection
var activeSelections: [String: [String]] = [:]

let mentionRegularExpression = #"<@(@[a-zA-Z0-9]+:[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})>"#

extension String {
	var replacingMentionsWithHTML: String {
		self.replacingOccurrences(
			of: mentionRegularExpression,
			with: "<a href='https://matrix.to/#/$1'>$1</a>",
			options: .regularExpression
		)
	}
	var replacingMentionsWithPlaintext: String {
		self.replacingOccurrences(
			of: mentionRegularExpression,
			with: "$1",
			options: .regularExpression
		)
	}
}

extension MatrixEvent {
	func ensureState(client: MatrixClient, communication: MatrixCommunication, eventLoop: EventLoop) {
		if !states.keys.contains(self.roomID!) {
			states[self.roomID!] = State<MatrixCommunication>(for: MatrixChannel(client: client, room: self.roomID!), in: communication, eventLoop: eventLoop)
		}
	}
	var state: State<MatrixCommunication> {
		return states[self.roomID!]!
	}
}

final class MatrixMappo {
	let client: MatrixClient
	let communication: MatrixCommunication
	let eventLoop: EventLoop

	init(client: MatrixClient, eventLoop: EventLoop, syncer: DefaultSyncer) {
		self.client = client
		self.communication = MatrixCommunication(client: client)
		self.eventLoop = eventLoop

		syncer.listen(to: "m.room.message") { event in
			guard let cont = event.content as? MatrixMessageContent else {
				return
			}
			do {
				try await self.handleMessage(event: event, content: cont)
			} catch {
				// TODO: error handling
			}
		}
	}

	func handleMessage(event: MatrixEvent, content: MatrixMessageContent) async throws {
		guard content.body.hasPrefix("m!") || content.body.hasPrefix("m?") || content.body.hasPrefix("m.") else {
			return
		}
		event.ensureState(client: client, communication: self.communication, eventLoop: self.eventLoop)

		let message = MatrixMessage(client: client, room: event.roomID!, messageID: event.eventID!)

		switch content.body.prefix(2) {
		case "m!": // command selection
			guard let state = users[event.sender!] else {
				return // TODO: not in game
			}
			switch content.body.dropFirst(2) {
			case "nominate-yes":
				try await state.nominateYes(who: event.sender!, interaction: message)
			case "nominate-no":
				try await state.nominateNo(who: event.sender!, interaction: message)
			case "vote-yes":
				try await state.voteYes(who: event.sender!, interaction: message)
			case "vote-no":
				try await state.voteNo(who: event.sender!, interaction: message)
			default:
				break
			}
			break
		case "m?": // user selection
			let split = content.body.dropFirst(2).split(separator: " ")
			guard split.count == 2 else {
				return
			}
			guard let state = users[event.sender!] else {
				return // TODO: not in game
			}
			guard let num = Int(split[1]) else {
				return // TODO: complain about bad number
			}
			guard let target = activeSelections[event.roomID!]?[num] else {
				return // TODO: complain about invalid selection
			}
			switch split[0] {
			case "werewolf-kill":
				try await state.werewolfKill(who: event.sender!, target: target, interaction: message)
			case "guardianAngel-protect":
				try await state.guardianAngelProtect(who: event.sender!, target: target, interaction: message)
			case "seer-investigate":
				try await state.seerInvestigate(who: event.sender!, target: target, interaction: message)
			case "cookies-give":
				try await state.cookiesGive(who: event.sender!, target: target, interaction: message)
			case "nominate":
				try await state.nominate(who: event.sender!, target: target, interaction: message)
			default:
				break
			}
			break
		case "m.":
			switch content.body.dropFirst(2) {
			case "join":
				try await event.state.join(who: event.sender!, interaction: message)
			case "leave":
				try await event.state.leave(who: event.sender!, interaction: message)
			case "party":
				try await event.state.party(who: event.sender!, interaction: message)
			case "setup":
				try await event.state.setup(who: event.sender!, interaction: message)
			case "unsetup":
				try await event.state.unsetup(who: event.sender!, interaction: message)
			case "start":
				try await event.state.start(who: event.sender!, interaction: message)
			default:
				break
			}
			break
		default:
			break
		}
	}
}
