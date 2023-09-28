import MappoCore
import NIO
import Foundation
import Logging

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

	func render(buttons: [CommunicationButton]) -> (String, String) {
		let mappedBtn = buttons.map { "\($0.label): send m!\($0.id.rawValue)" }
		let htmlBodyBtn = mappedBtn.joined(separator: "<br>")
		let plainBodyBtn = mappedBtn.joined(separator: "\n")
		return (htmlBodyBtn, plainBodyBtn)
	}

	func send(_ text: String) async throws -> Message {
		let msg = try await client.sendMessage(to: room, content: MatrixMessageContent(
			html: text.replacingMentionsWithHTML.replacingNewlinesWithBr,
			plaintext: text.replacingMentionsWithPlaintext
		))
		return MatrixMessage(client: client, room: room, messageID: msg)
	}

	func send(_ embed: CommunicationEmbed) async throws -> Message {
		let msg = try await client.sendMessage(to: room, content:
			MatrixMessageContent(
				html: "<h4>\(embed.title.replacingMentionsWithHTML.replacingNewlinesWithBr)</h4>\n\(embed.body.replacingMentionsWithHTML.replacingNewlinesWithBr)",
				plaintext: "\(embed.title.replacingMentionsWithPlaintext)\n\n\(embed.body.replacingMentionsWithPlaintext)"
			)
		)
		return MatrixMessage(client: client, room: room, messageID: msg)
	}

	func send(_ buttons: [CommunicationButton]) async throws -> Message {
		let htmlPrefix = "<h4>Take an action</h4>\n"
		let plainPrefix = "Take an action\n\n"

		let (htmlBody, plainBody) = render(buttons: buttons)

		let msg = try await client.sendMessage(to: room, content: MatrixMessageContent(html: htmlPrefix + htmlBody, plaintext: plainPrefix + plainBody))
		return MatrixMessage(client: client, room: room, messageID: msg)
	}

	func send(userSelection options: [UserID], id: SingleUserSelectionID, label: String, buttons: [CommunicationButton]) async throws -> Message {
		let htmlPrefix = "<h4>\(label.replacingMentionsWithHTML.replacingNewlinesWithBr)</h4>\n"
		let plainPrefix = "\(label.replacingMentionsWithPlaintext)\n\n"

		let (htmlBodyBtn, plainBodyBtn) = render(buttons: buttons)

		let htmlBody = options.indices.map { "<a href='https://matrix.to/#/\(options[$0].id)'>\(options[$0].id)</a>: send m?\(id.rawValue) \($0)" }.joined(separator: "<br>") + htmlBodyBtn
		let plainBody = options.indices.map { "\(options[$0]): send m?\(id.rawValue) \($0)" }.joined(separator: "\n") + plainBodyBtn

		activeSelections[room] = options.map{$0.id}

		let msg = try await client.sendMessage(to: room, content: MatrixMessageContent(html: htmlPrefix + htmlBody, plaintext: plainPrefix + plainBody))
		return MatrixMessage(client: client, room: room, messageID: msg)
	}

	func send(multiUserSelection options: [UserID], id: MultiUserSelectionID, label: String, buttons: [CommunicationButton]) async throws -> Message {
		let htmlPrefix = "<h4>\(label.replacingMentionsWithHTML.replacingNewlinesWithBr)</h4>\n"
		let plainPrefix = "\(label.replacingMentionsWithPlaintext)\n\n"

		let (htmlBodyBtn, plainBodyBtn) = render(buttons: buttons)

		let explanation = ["Send m?\(id.rawValue) followed by the space separated numbers for who you want to select; e.g. (m?\(id.rawValue) 0 1)"]
		let htmlBody = (options.indices.map { "<a href='https://matrix.to/#/\(options[$0].id)'>\(options[$0].id)</a>: \($0)" } + explanation).joined(separator: "<br>") + htmlBodyBtn
		let plainBody = (options.indices.map { "\(options[$0]): \($0)" } + explanation) .joined(separator: "\n") + plainBodyBtn

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
			html: text.replacingMentionsWithHTML.replacingNewlinesWithBr,
			plaintext: text.replacingMentionsWithPlaintext
		))
	}

	func reply(with embed: CommunicationEmbed, epheremal: Bool) async throws {
		_ = try await client.sendMessage(to: roomID, content:
			MatrixMessageContent(
				html: "<h4>\(embed.title.replacingMentionsWithHTML.replacingNewlinesWithBr)</h4>\n\(embed.body.replacingMentionsWithHTML.replacingNewlinesWithBr)",
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

let mentionRegularExpression = #"<@(@[a-zA-Z0-9.-]+:[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})>"#

extension String {
	var replacingMentionsWithHTML: String {
		self.replacingOccurrences(
			of: mentionRegularExpression,
			with: "<a href='https://matrix.to/#/$1'>$1</a>",
			options: .regularExpression
		)
	}
	var replacingNewlinesWithBr: String {
		self.replacingOccurrences(of: "\n", with: "<br>")
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

	init(client: MatrixClient, eventLoop: EventLoop, syncer: DefaultSyncer, logger: Logger, userID: String) {
		self.client = client
		self.communication = MatrixCommunication(client: client)
		self.eventLoop = eventLoop

		syncer.listen(to: "m.room.message") { event in
			guard let cont = event.content as? MatrixMessageContent else {
				return
			}
			Task {
				do {
					try await self.handleMessage(event: event, content: cont)
				} catch {
					logger.warning("Error handling message: \(error)")
				}
			}
		}
		syncer.listen(to: "m.room.member") { event in
			guard let cont = event.content as? MatrixMemberContent, let roomID = event.roomID else {
				return
			}
			do {
				if cont.membership == .invite && event.stateKey == userID {
					_ = try await client.joinRoom(roomID)
				}
			} catch {
				logger.warning("Error handling member: \(error)")
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
				_ = try await client.sendMessage(to: event.roomID!, content: .init(html: "You are not in the game!", plaintext: "You are not in the game!"))
				return
			}
			if let buttonID = ButtonID.init(rawValue: String(content.body.dropFirst(2))),
				let button = state.buttons[buttonID] {
				try await button(state)(UserID(id: event.sender!), message)
			} else {
				_ = try await client.sendMessage(to: event.roomID!, content: .init(html: "Unknown button!", plaintext: "Unknown button!"))
			}
			break
		case "m?": // user selection
			let split = content.body.dropFirst(2).split(separator: " ")
			guard split.count >= 2 else {
				return
			}
			guard let state = users[event.sender!] else {
				_ = try await client.sendMessage(to: event.roomID!, content: .init(html: "You are not in the game!", plaintext: "You are not in the game!"))
				return
			}
			guard let num = Int(split[1]) else {
				_ = try await client.sendMessage(to: event.roomID!, content: .init(html: "Bad number!", plaintext: "Bad number!"))
				return
			}
			guard let target = activeSelections[event.roomID!]?[num] else {
				_ = try await client.sendMessage(to: event.roomID!, content: .init(html: "Invalid selection!", plaintext: "Invalid selection!"))
				return
			}
			if let susID = SingleUserSelectionID.init(rawValue: String(split[0])),
				let dropdown = state.singleUserDropdowns[susID] {
				try await dropdown(state)(UserID(id: event.sender!), UserID(id: target), message)
			} else if let musID = MultiUserSelectionID.init(rawValue: String(split[0])),
				let dropdown = state.multiUserDropdowns[musID] {

				let otherNums = split.dropFirst().compactMap{Int($0)}
				guard otherNums.allSatisfy({ activeSelections[event.roomID!]?[$0] != nil }) else {
					_ = try await client.sendMessage(to: event.roomID!, content: .init(html: "Invalid selection!", plaintext: "Invalid selection!"))
					return
				}
				let allNums = [num] + otherNums
				try await dropdown(state)(UserID(id: event.sender!), allNums.map{UserID(id: activeSelections[event.roomID!]![$0])}, message)
			} else {
				_ = try await client.sendMessage(to: event.roomID!, content: .init(html: "Unknown user selection!", plaintext: "Unknown user selection!"))
			}
			break
		case "m.":
			let command = String(content.body.dropFirst(2))
			if let cmd = event.state.arglessCommands[command] {
				try await cmd(event.state)(UserID(id: event.sender!), message)
			} else {
				_ = try await client.sendMessage(to: event.roomID!, content: .init(html: "Unknown command!", plaintext: "Unknown command!"))
			}
			break
		default:
			break
		}
	}
}
