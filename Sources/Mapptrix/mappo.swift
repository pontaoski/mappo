import MappoCore
import NIO
import Foundation

class MatrixChannel: Sendable, I18nable {
	typealias Message = MatrixMessage
	typealias UserID = Mapptrix.UserID

	let client: MatrixClient
	let room: String

	init(client: MatrixClient, room: String) {
		self.client = client
		self.room = room
	}

	func i18n() -> I18n {
		English()
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

	func send(userSelection options: [UserID], id: String, label: String, buttons: [CommunicationButton]) async throws -> Message {
		let htmlPrefix = "<h4>\(label.replacingMentionsWithHTML)</h4>\n"
		let plainPrefix = "\(label.replacingMentionsWithPlaintext)\n\n"

		let mappedBtn = buttons.map { "\($0.label): send m!\($0.id)" }
		let htmlBodyBtn = mappedBtn.joined(separator: "<br>")
		let plainBodyBtn = mappedBtn.joined(separator: "\n")

		let htmlBody = options.indices.map { "<a href='https://matrix.to/#/\(options[$0])'>\(options[$0])</a>: send m?\(id) \($0)" }.joined(separator: "<br>") + htmlBodyBtn
		let plainBody = options.indices.map { "\(options[$0]): send m?\(id) \($0)" }.joined(separator: "\n") + plainBodyBtn

		activeSelections[room] = options.map{$0.id}

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

struct UserID: Mentionable, Hashable {
	let id: String
	func mention() -> String {
		"<@\(id)>"
	}
}

final class MatrixCommunication: Communication {
	typealias UserID = Mapptrix.UserID
	typealias Channel = MatrixChannel
	typealias Message = MatrixMessage
	typealias Interaction = MatrixMessage

	let client: MatrixClient

	init(client: MatrixClient) {
		self.client = client
	}

	func getChannel(for userID: UserID, state: State<MatrixCommunication>) async throws -> Channel? {
		let dmID = try await client.getDM(for: userID.id)
		return MatrixChannel(client: client, room: dmID)
	}

	func createGameThread(state: State<MatrixCommunication>) async throws -> Channel? {
		return state.channel
	}

	func archive(_: Channel, state: State<MatrixCommunication>) async throws {
		// nothing
	}

	func currentParty(of user: UserID, state: State<MatrixCommunication>) async throws -> State<MatrixCommunication>? {
		return users[user.id]
	}

	func onPrepareJoined(_ user: UserID, state: State<MatrixCommunication>) async throws {
		users[user.id] = state
	}

	func onJoined(_ user: UserID, state: State<MatrixCommunication>) async throws {
		users[user.id] = state
	}

	func onLeft(_ user: UserID, state: State<MatrixCommunication>) async throws {
		users.removeValue(forKey: user.id)
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
			if let button = state.buttons[String(content.body.dropFirst(2))] {
				try await button(state)(UserID(id: event.sender!), message)
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
			if let dropdown = state.userDropdowns[String(split[0])] {
				try await dropdown(state)(UserID(id: event.sender!), UserID(id: target), message)
			}
			break
		case "m.":
			let command = String(content.body.dropFirst(2))
			if let cmd = event.state.arglessCommands[command] {
				try await cmd(event.state)(UserID(id: event.sender!), message)
			}
			break
		default:
			break
		}
	}
}
