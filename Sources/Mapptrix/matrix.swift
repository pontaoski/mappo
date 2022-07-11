import AsyncHTTPClient
import AsyncKit
import NIO
import NIOHTTP1
import Foundation
import NIOFoundationCompat
import JSONValueRX
import Logging

protocol MatrixStorage {
	func saveFilterID(id: String, for userID: String) async throws
	func loadFilterID(for userID: String) async throws -> String?

	func saveNextBatch(id: String, for userID: String) async throws
	func loadNextBatch(for userID: String) async throws -> String?

	func saveRoom(_ room: MatrixRoom) async throws
	func loadRoom(id: String) async throws -> MatrixRoom?

	func saveDMRoomID(_ id: String, for userID: String) async throws
	func loadDMRoomID(for userID: String) async throws -> String?
}

protocol MatrixSyncer {
	func handle(response: MatrixSyncResponse, since: String?) async throws
	func handleFailed(error: Error) async throws -> TimeAmount
	func getFilterJSON(for userID: String) async throws -> JSONValue
}

final class DefaultSyncer: MatrixSyncer {
	var userID: String
	var listeners: [String: [(MatrixEvent) async -> Void]]
	let storage: MatrixStorage

	init(userID: String, storage: MatrixStorage) {
		self.userID = userID
		self.storage = storage
		self.listeners = [:]
	}

	func broadcast(_ event: MatrixEvent) async {
		for listener in (listeners[event.type] ?? []) {
			await listener(event)
		}
	}

	func listen(to eventType: String, _ closure: @escaping (MatrixEvent) async -> Void) {
		self.listeners[eventType] = (self.listeners[eventType] ?? []) + [closure]
	}

	func getOrCreateRoom(id: String) async throws -> MatrixRoom {
		guard let room = try await storage.loadRoom(id: id) else {
			let room = MatrixRoom(id: id)
			try await storage.saveRoom(room)
			return room
		}
		return room
	}

	func handle(response: MatrixSyncResponse, since: String?) async throws {
		for (roomID, roomData) in (response.rooms?.join ?? [:]) {
			let room = try await getOrCreateRoom(id: roomID)
			for var event in roomData.state.events {
				event.roomID = roomID
				room.updateState(against: event)
				await broadcast(event)
			}
			for var event in roomData.timeline.events {
				event.roomID = roomID
				await broadcast(event)
			}
			for var event in roomData.ephemeral.events { 
				event.roomID = roomID
				await broadcast(event)
			}
			try await storage.saveRoom(room)
		}
		for (roomID, roomData) in (response.rooms?.invite ?? [:]) {
			let room = try await getOrCreateRoom(id: roomID)
			for var event in roomData.inviteState.events {
				event.roomID = roomID
				room.updateState(against: event)
				await broadcast(event)
			}
			try await storage.saveRoom(room)
		}
		for (roomID, roomData) in (response.rooms?.leave ?? [:]) {
			let room = try await getOrCreateRoom(id: roomID)
			for var event in roomData.timeline.events {
				guard event.stateKey != nil else {
					continue
				}
				event.roomID = roomID
				room.updateState(against: event)
				await broadcast(event)
			}
			try await storage.saveRoom(room)
		}
	}

	func handleFailed(error: Error) async throws -> TimeAmount {
		return .seconds(10)
	}

	func getFilterJSON(for userID: String) async throws -> JSONValue {
		return try JSONValue(object: ["room": ["timeline": ["limit": 50]]])
	}
}

final class InMemoryStorage: MatrixStorage {
	var filters: [String: String] = [:]
	var nextBatches: [String: String] = [:]
	var rooms: [String: MatrixRoom] = [:]
	var dmRoomIDS: [String: String] = [:]

	func saveFilterID(id: String, for userID: String) async throws {
		filters[userID] = id
	}

	func loadFilterID(for userID: String) async throws -> String? {
		return filters[userID]
	}

	func saveNextBatch(id: String, for userID: String) async throws {
		nextBatches[userID] = id
	}

	func loadNextBatch(for userID: String) async throws -> String? {
		return nextBatches[userID]
	}

	func saveRoom(_ room: MatrixRoom) async throws {
		rooms[room.id] = room
	}

	func loadRoom(id: String) async throws -> MatrixRoom? {
		return rooms[id]
	}

	func saveDMRoomID(_ id: String, for userID: String) async throws {
		dmRoomIDS[id] = userID
	}

	func loadDMRoomID(for userID: String) async throws -> String? {
		return dmRoomIDS[userID]
	}
}

final class MatrixRoom: Codable {
	let id: String
	var state: [String: [String: MatrixEvent]]

	init(id: String) {
		self.id = id
		self.state = [:]
	}
	func updateState(against event: MatrixEvent) {
		var dict = state[event.type] ?? [:]
		dict[event.stateKey!] = event
		state[event.type] = dict
	}
}

protocol MatrixContent: Codable {
}

final class MatrixUnknownContent: MatrixContent {
	let data: JSONValue

	func encode(to encoder: Encoder) throws {
		try data.encode(to: encoder)
	}
	init(from decoder: Decoder) throws {
		data = try .init(from: decoder)
	}
}

protocol MatrixMessageType: Codable {
	var messageType: String { get }
}

final class MatrixUnknownMessageType: MatrixMessageType {
	let messageType: String
	let data: JSONValue

	func encode(to encoder: Encoder) throws {
		var values = encoder.container(keyedBy: CodingKeys.self)
		try values.encode(messageType, forKey: .messageType)
		try data.encode(to: encoder)
	}
	init(from decoder: Decoder) throws {
		data = try .init(from: decoder)
		let values = try decoder.container(keyedBy: CodingKeys.self)
		messageType = try values.decode(String.self, forKey: .messageType)
	}

	enum CodingKeys: String, CodingKey {
		case messageType = "msgtype"
	}
}

final class MatrixTextMessage: MatrixMessageType {
	static let messageType: String = "m.text"
	let messageType: String = "m.text"

	let richContent: (format: String, body: String)?

	func encode(to encoder: Encoder) throws {
		var values = encoder.container(keyedBy: CodingKeys.self)
		if let rich = richContent {
			try values.encode(rich.format, forKey: .format)
			try values.encode(rich.body, forKey: .formattedBody)
		}
	}
	init() {
		self.richContent = nil
	}
	init(format: String, body: String) {
		self.richContent = (format, body)
	}
	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		if values.contains(.format) {
			let format = try values.decode(String.self, forKey: .format)
			let body = try values.decode(String.self, forKey: .formattedBody)

			self.richContent = (format, body)
		} else {
			self.richContent = nil
		}
	}

	enum CodingKeys: String, CodingKey {
		case format
		case formattedBody = "formatted_body"
	}
}

final class MatrixMessageContent: MatrixContent {
	let messageType: MatrixMessageType
	let body: String

	init(body: String, _ content: MatrixMessageType = MatrixTextMessage()) {
		self.messageType = content
		self.body = body
	}
	init(html: String, plaintext: String) {
		self.messageType = MatrixTextMessage(format: "org.matrix.custom.html", body: html)
		self.body = plaintext
	}
	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		self.body = try values.decode(String.self, forKey: .body)
		let messageType = try values.decode(String.self, forKey: .messageType)
		switch messageType {
		case MatrixTextMessage.messageType:
			self.messageType = try MatrixTextMessage(from: decoder)
		default:
			self.messageType = try MatrixUnknownMessageType(from: decoder)
		}
	}
	func encode(to encoder: Encoder) throws {
		var values = encoder.container(keyedBy: CodingKeys.self)
		try values.encode(messageType.messageType, forKey: .messageType)
		try values.encode(self.body, forKey: .body)
		try messageType.encode(to: encoder)
	}

	enum CodingKeys: String, CodingKey {
		case messageType = "msgtype"
		case body
	}
}

struct MatrixEvent: Codable {
	let type: String
	let content: MatrixContent

	// state events
	let stateKey: String?

	// room events
	var roomID: String?
	let eventID: String?
	let sender: String?

	enum CodingKeys: String, CodingKey {
		case type
		case content

		case stateKey = "state_key"

		case roomID = "room_id"
		case eventID = "event_id"
		case sender
	}

	func encode(to encoder: Encoder) throws {
		var values = encoder.container(keyedBy: CodingKeys.self)

		try values.encode(type, forKey: .type)
		try values.encodeIfPresent(stateKey, forKey: .stateKey)
		try values.encodeIfPresent(roomID, forKey: .roomID)
		try values.encodeIfPresent(eventID, forKey: .eventID)
		try values.encodeIfPresent(sender, forKey: .sender)
		final class Internal: Encodable {
			let content: MatrixContent
			init(_ content: MatrixContent) {
				self.content = content
			}
			func encode(to encoder: Encoder) throws {
				try self.content.encode(to: encoder)
			}
		}
		try values.encode(Internal(content), forKey: .content)
	}
	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		type = try values.decode(String.self, forKey: .type)
		stateKey = try values.decodeIfPresent(String.self, forKey: .stateKey)

		roomID = try values.decodeIfPresent(String.self, forKey: .roomID)
		eventID = try values.decodeIfPresent(String.self, forKey: .eventID)
		sender = try values.decodeIfPresent(String.self, forKey: .sender)

		do {
			switch type {
			case "m.room.message":
				content = try values.decode(MatrixMessageContent.self, forKey: .content)
			default:
				content = try values.decode(MatrixUnknownContent.self, forKey: .content)
			}
		} catch is DecodingError {
			content = try values.decode(MatrixUnknownContent.self, forKey: .content)
		}
	}
}

struct MatrixSyncResponse: Codable {
	let nextBatch: String
	let accountData: AccountData?
	let presence: Presence?
	let rooms: Rooms?

	enum CodingKeys: String, CodingKey {
		case nextBatch = "next_batch"
		case accountData = "account_data"
		case presence = "presence"
		case rooms = "rooms"
	}

	struct AccountData: Codable {
		let events: [MatrixEvent]
	}
	struct Presence: Codable {
		let events: [MatrixEvent]
	}
	struct Rooms: Codable {
		let invite: [String: Invited]?
		let join: [String: Joined]?
		let leave: [String: Left]?
	
		struct Invited: Codable {
			let inviteState: InviteState

			struct InviteState: Codable {
				let events: [MatrixEvent]
			}
		}
		struct Joined: Codable {
			let state: State
			let timeline: Timeline
			let ephemeral: Ephemeral

			struct State: Codable {
				let events: [MatrixEvent]
			}
			struct Timeline: Codable {
				let events: [MatrixEvent]
				let limited: Bool
				let previousBatch: String

				enum CodingKeys: String, CodingKey {
					case previousBatch = "prev_batch"
					case events
					case limited
				}
			}
			struct Ephemeral: Codable {
				let events: [MatrixEvent]
			}
		}
		struct Left: Codable {
			let state: State
			let timeline: Timeline

			struct State: Codable {
				let events: [MatrixEvent]
			}
			struct Timeline: Codable {
				let events: [MatrixEvent]
				let limited: Bool
				let previousBatch: String

				enum CodingKeys: String, CodingKey {
					case previousBatch = "prev_batch"
					case events
					case limited
				}
			}
		}
	}
}

extension HTTPClientResponse {
	func into<T: Decodable>() async throws -> T {
		guard self.status.code/100 == 2 else {
			// not a 2XX response
			let body = try await self.body.collect(upTo: 1024 * 1024)
			var err = try JSONDecoder().decode(MatrixError.self, from: body)
			err.httpStatus = self.status
			throw err
		}
		let body = try await self.body.collect(upTo: 5 * 1024 * 1024)
		let resp = try JSONDecoder().decode(T.self, from: body)
		return resp
	}
}

struct MatrixError: LocalizedError, Decodable {
	let errorCode: String
	let errorMessage: String
	var httpStatus: HTTPResponseStatus = .found
	var localizedDescription: String {
		"\(errorCode) (HTTP \(httpStatus.code) \(httpStatus.reasonPhrase)) - \(errorMessage)"
	}

	enum CodingKeys: String, CodingKey {
		case errorCode = "errcode"
		case errorMessage = "error"
	}
}

extension HTTPClientRequest {
	func log(to: Logger) {
		to.debug("\(self.method) \(self.url)")
	}
	func logged(to: Logger) -> Self {
		log(to: to)
		return self
	}
}

final class MatrixClient {
	// base url
	let homeserverURL: String
	// api prefix
	let apiPrefix: String
	// user id
	var userID: String?
	// access token
	var accessToken: String?
	// http client
	let httpClient: HTTPClient
	// storage
	let storage: MatrixStorage
	// syncer
	let syncer: MatrixSyncer
	// logger
	let logger: Logger

	init(
		homeserver url: String,
		eventLoop: EventLoopGroup,
		syncer: MatrixSyncer,
		storage: MatrixStorage = InMemoryStorage(),
		logger: Logger = Logger(label: "com.github.pontaoski.Mappo"),
		userID: String? = nil,
		accessToken: String? = nil
	) {
		self.homeserverURL = url
		self.apiPrefix = "/_matrix/client/r0"
		self.logger = logger
		self.userID = userID
		self.accessToken = accessToken
		self.httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoop))
		self.storage = storage
		self.syncer = syncer
	}

	func transactionID() -> String {
		let time = Date().timeIntervalSince1970
		return "swift\(time)"
	}

	func buildURL(path: String...) -> URL {
		var url = URL(string: homeserverURL)!
		url.appendPathComponent(apiPrefix)
		for item in path {
			url.appendPathComponent(item)
		}
		return url
	}

	func createRequest(for url: URL, method: HTTPMethod) throws -> HTTPClientRequest {
		var request = HTTPClientRequest(url: url.absoluteString)
		request.method = method
		request.headers.add(name: "Content-Type", value: "application/json")
		if let accessToken = self.accessToken {
			request.headers.add(name: "Authorization", value: "Bearer \(accessToken)")
		}
		return request
	}
	func createRequest<T: Encodable>(for url: URL, method: HTTPMethod, body: T) throws -> HTTPClientRequest {
		var request = try createRequest(for: url, method: method)
		let data = try JSONEncoder().encode(body)
		request.body = .bytes(data)
		return request
	}

	func createFilter(_ filter: JSONValue) async throws -> String {
		let url = buildURL(path: "user", userID!, "filter")
		let request = try createRequest(for: url, method: .POST, body: filter)
		let resp = try await httpClient.execute(request.logged(to: self.logger), timeout: .seconds(30), logger: self.logger)

		struct Response: Decodable {
			let filterID: String

			enum CodingKeys: String, CodingKey {
				case filterID = "filter_id"
			}
		}
		let response: Response = try await resp.into()

		return response.filterID
	}
	func syncRequest(
		timeout: Int,
		since: String? = nil,
		filterID: String? = nil,
		fullState: Bool? = nil,
		setPresence: String? = nil
	) async throws -> MatrixSyncResponse {
		let url = buildURL(path: "sync")
		var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
		components.queryItems = [
			URLQueryItem(name: "timeout", value: String(timeout * 1000)),
			URLQueryItem(name: "since", value: since),
			URLQueryItem(name: "filter", value: filterID),
			URLQueryItem(name: "set_presence", value: setPresence),
			URLQueryItem(name: "full_state", value: fullState.map { $0 ? "true" : "false" }),
		]
		components.queryItems = components.queryItems?.filter({ $0.value != nil })
		let request = try createRequest(for: components.url!, method: .GET)
		let resp = try await httpClient.execute(request.logged(to: self.logger), timeout: .seconds(Int64(timeout) + 15), logger: self.logger)
		return try await resp.into()
	}

	struct EventSendResponse: Codable {
		let event_id: String
	}

	func getDM(
		for userID: String
	) async throws -> String {
		if let roomID = try await storage.loadDMRoomID(for: userID) {
			return roomID
		}

		let url = buildURL(path: "createRoom")
		let params = try JSONValue(object: [
			"preset": "private_chat",
			"invite": [userID]
		])
		let request = try createRequest(for: url, method: .POST, body: params)
		let resp = try await httpClient.execute(request.logged(to: self.logger), timeout: .seconds(30), logger: self.logger)

		struct RoomCreateResponse: Codable {
			let room_id: String
		}
		let response: RoomCreateResponse = try await resp.into()

		try await storage.saveDMRoomID(response.room_id, for: userID)
		return response.room_id
	}

	func redactEvent(
		id: String,
		in roomID: String
	) async throws {
		let url = buildURL(path: "rooms", roomID, "redact", id, transactionID())
		let request = try createRequest(for: url, method: .PUT)
		let resp = try await httpClient.execute(request.logged(to: self.logger), timeout: .seconds(30), logger: self.logger)
		struct RedactResponse: Codable {
			let event_id: String
		}
		let _: RedactResponse = try await resp.into()
	}

	func sendMessage(
		to roomID: String,
		content: MatrixMessageContent
	) async throws -> String {
		let url = buildURL(path: "rooms", roomID, "send", "m.room.message", transactionID())
		let request = try createRequest(for: url, method: .PUT, body: content)
		let resp = try await httpClient.execute(request.logged(to: self.logger), timeout: .seconds(30), logger: self.logger)
		let response: EventSendResponse = try await resp.into()
		return response.event_id
	}

	func sync() async throws -> Never {
		var nextBatch = try await storage.loadNextBatch(for: userID!)
		var filterID = try await storage.loadFilterID(for: userID!)
		if filterID == nil {
			let filterJSON = try await syncer.getFilterJSON(for: userID!)
			let newFilterID = try await createFilter(filterJSON)
			filterID = newFilterID
			try await storage.saveFilterID(id: newFilterID, for: userID!)
		}

		while true {
			let response: MatrixSyncResponse

			do {
				response = try await syncRequest(timeout: 30, since: nextBatch, filterID: filterID)
				try await storage.saveNextBatch(id: response.nextBatch, for: userID!)
			} catch {
				logger.error("\(error)")
				let amount = try await syncer.handleFailed(error: error)
				try await Task.sleep(nanoseconds: UInt64(amount.nanoseconds))
				continue
			}
			try await storage.saveNextBatch(id: response.nextBatch, for: userID!)
			try await syncer.handle(response: response, since: nextBatch)

			nextBatch = response.nextBatch
		}
	}
}
