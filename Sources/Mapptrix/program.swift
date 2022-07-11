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

		let _ = MatrixMappo(client: client, eventLoop: evGroup.next(), syncer: syncer)

		try! await client.sync()
	}
}
