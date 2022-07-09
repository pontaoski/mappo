import SQLite
import Foundation

final class SQLiteStorage: MatrixStorage {
	var db: Connection

	let filters = Table("filters")
	let id = Expression<String>("id")
	let forUserID = Expression<String>("for_user_id")

	let batches = Table("next_batches")

	let rooms = Table("rooms")
	let roomID = Expression<String>("roomID")
	let roomContent = Expression<Data>("roomContent")

	init(databasePath: String) throws {
		self.db = try Connection(databasePath)

		try db.run(filters.create(ifNotExists: true) { t in
			t.column(forUserID, primaryKey: true)
			t.column(id)
		})

		try db.run(batches.create(ifNotExists: true) { t in
			t.column(forUserID, primaryKey: true)
			t.column(id)
		})

		try db.run(rooms.create(ifNotExists: true) { t in
			t.column(roomID, primaryKey: true)
			t.column(roomContent)
		})
	}

	func saveFilterID(id: String, for userID: String) async throws {
		let insert = filters.insert(or: .replace, forUserID <- userID, self.id <- id)
		try db.run(insert)
	}

	func loadFilterID(for userID: String) async throws -> String? {
		guard let it = try db.pluck(filters.select(id).filter(forUserID == userID)) else {
			return nil
		}
		return try it.get(id)
	}

	func saveNextBatch(id: String, for userID: String) async throws {
		let insert = batches.insert(or: .replace, forUserID <- userID, self.id <- id)
		try db.run(insert)
	}

	func loadNextBatch(for userID: String) async throws -> String? {
		guard let it = try db.pluck(batches.select(id).filter(forUserID == userID)) else {
			return nil
		}
		return try it.get(id)
	}

	func saveRoom(_ room: MatrixRoom) async throws {
		let data = try JSONEncoder().encode(room)
		let insert = rooms.insert(or: .replace, roomID <- id, self.roomContent <- data)
		try db.run(insert)
	}

	func loadRoom(id: String) async throws -> MatrixRoom? {
		guard let it = try db.pluck(rooms.select(roomContent).filter(roomID == id)) else {
			return nil
		}
		let data = try it.get(roomContent)
		let room = try JSONDecoder().decode(MatrixRoom.self, from: data)
		return room
	}
}
