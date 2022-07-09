import NIO
import Logging
import Foundation

@main
struct Main {
	static func main() async {
		struct Config: Codable {
			var userID: String
			var token: String
		}

		let config = try! JSONDecoder().decode(Config.self,  from: try! String(contentsOfFile: "matrix_config.json").data(using: .utf8)!)
		let evGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
		let storage = try! SQLiteStorage(databasePath: "matrix.db")
		let userID = config.userID
		let token = config.token
		var logger = Logger(label: "com.github.pontaoski.Mappo")
		let syncer = DefaultSyncer(userID: userID, storage: storage)
		logger.logLevel = .info
		let client = MatrixClient(
			homeserver: "https://matrix.tchncs.de",
			eventLoop: evGroup,
			syncer: syncer,
			storage: storage,
			logger: logger,
			userID: userID,
			accessToken: token
		)

		syncer.listen(to: "m.room.message") { event in
			guard let msg = event.content as? MatrixMessageContent else {
				return
			}
			guard let body = msg.body else {
				return
			}
			if body.hasPrefix("bot, echo ") {
				let trimmed = body.dropFirst("bot, echo ".count)
				_ = try? await client.sendMessage(to: event.roomID!, content: MatrixMessageContent(body: "You said: \(trimmed)"))
			}
		}

		try! await client.sync()
	}
}
