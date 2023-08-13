import NIO
import OrderedCollections
import Foundation

public class ConditionVariable {
	let promise: EventLoopPromise<Void>
	let future: EventLoopFuture<Void>
	var done = false

	public init(for eventLoop: EventLoop) {
		promise = eventLoop.makePromise(of: Void.self)
		future = promise.futureResult
	}
	deinit {
		if !done {
			promise.succeed(())
		}
	}
	public func release() {
		promise.succeed(())
		done = true
	}
	public func wait() async throws {
		try await future.get()
	}
}

public enum Role: CaseIterable {
	case villager
	case werewolf
	case guardianAngel
	case seer
	case beholder
	case jester
	case cookiePerson
	case furry
	case innocent
	case pacifist
	case goose
	case cursed
	case oracle
	case bartender
	case laundryperson
	case gossip
	case librarian

	func appearsAs(to: Role) -> Role {
		switch (self, to) {
		case (.furry, .seer):
			return .werewolf
		case (.cursed, .seer):
			return .villager
		default:
			return self
		}
	}

	func isValid<T: Sequence>(with roles: T, playerCount count: Int) -> Bool where T.Element == Role {
		guard roles.filter({ $0 == self }).count < self.absoluteMax else {
			return false
		}
		guard count >= self.minimumPlayerCount else {
			return false
		}
		if self == .beholder {
			guard roles.contains(.seer) else {
				return false
			}
		}
		if self.defaultTeam == .werewolf {
			guard Role.wolves.contains(self) || roles.contains(where: { Role.wolves.contains($0) }) else {
				return false
			}
		}
		return true
	}

	var defaultTeam: Team {
		switch self {
			case .jester:
				return .jester
			case .werewolf, .goose, .cursed:
				return .werewolf
			default:
				return .village
		}
	}

	var absoluteMax: Int {
		switch self {
		case .guardianAngel, .seer, .oracle, .beholder, .jester, .cookiePerson, .innocent, .pacifist, .cursed, .laundryperson, .gossip, .librarian:
			return 1
		case .furry:
			return 2
		default:
			return Int.max
		}
	}
	var minimumPlayerCount: Int {
		switch self {
		case .beholder, .cookiePerson, .jester, .seer:
			return 5
		default:
			return 0
		}
	}
	func strength<T: Sequence>(with party: T, playerCount count: Int) -> Double where T.Element == Role {
		switch self {
		// passive roles
		case .villager:
			return 1
		case .furry:
			return 1

		// active information roles
		case .seer:
			// strength of 10 in a 3-player game, lowers to 5 in a 7-player game
			return max( 20.0 * (2.0 / ( Double(count) + 1.0 )), 5.0 )
		case .oracle:
			return 5
		case .cookiePerson:
			return 6
		case .beholder:
			return 2

		// active roles
		case .bartender:
			return 4

		// defensive roles
		case .guardianAngel:
			return 6

		// jester roles (this doesn't really matter for balancing)
		case .jester:
			return 0

		// vote roles
		case .innocent:
			return 4
		case .pacifist:
			return 2

		// wolf roles
		case .werewolf:
			return 10
		case .goose:
			return 10
		case .cursed:
			return 8

		// sog roles
		case .laundryperson, .gossip, .librarian:
			// we don't really want more than one of these for an average-sized game, so their
			// strength spikes dramatically
			return Double(4 * party.filter{ Role.startOfGameInfoRoles.contains($0) }.count)
		}
	}

	private static func assignInner(_ roles: inout [Role], playerCount count: Int) {
		func eligible(_ against: [Role]) -> [Role] {
			return against.filter { $0.isValid(with: roles, playerCount: count) }
		}

		let shuffle = roles.indices.shuffled()
		let evil = max(Int(round(Float(shuffle.count) * 0.29)), 1)
		let other = shuffle.count - evil

		shuffle.prefix(evil).forEach {
			roles[$0] = eligible(Role.werewolves).randomElement()!
		}
		shuffle.suffix(other).forEach {
			roles[$0] = eligible(Role.village).randomElement()!
		}
	}

	static public func generateRoles(partySize: Int) -> [Role]? {
	outer:
		for _ in 0...500 {
			var roles: [Role] = Array(repeating: .villager, count: partySize)

			assignInner(&roles, playerCount: partySize)

			let villagerStrength =
				roles.filter{ $0.defaultTeam == .village }
					.map { $0.strength(with: roles, playerCount: partySize) }
					.reduce(0.0, (+))
			let werewolfStrength = roles.filter{ $0.defaultTeam == .werewolf }
					.map { $0.strength(with: roles, playerCount: partySize) }
					.reduce(0.0, (+))

			let villagerPercentDifference =
				(villagerStrength - werewolfStrength) / werewolfStrength

			guard -0.2 <= villagerPercentDifference && villagerPercentDifference <= 0.4 else {
				continue outer
			}

			return roles
		}
		return nil
	}

	static let village: [Role] = Role.allCases.filter { $0.defaultTeam != .werewolf }
	static let werewolves: [Role] = Role.allCases.filter { $0.defaultTeam == .werewolf }

	static let wolves: Set<Role> = [.werewolf]
	static let startOfGameInfoRoles: Set<Role> = [.laundryperson, .gossip, .librarian]
}

public enum Team: Equatable {
	case village
	case werewolf
	case jester
}

public enum GameState {
	case waiting
	case assigned
	case playing
}

enum DeathReason<T: Communication>: Equatable {
	case werewolf
	case exile
	case visitedWerewolf
	case visitedSomeoneBeingVisitedByWerewolf(visiting: T.UserID)
	case protectedWerewolf
	case nominatedInnocent
	case goose
}

public enum VictoryReason {
	case allWerewolvesDead
	case werewolvesMajority
	case jesterExiled

	var winningTeam: Team {
		switch self {
		case .allWerewolvesDead:
			return .village
		case .werewolvesMajority:
			return .werewolf
		case .jesterExiled:
			return .jester
		}
	}
}

public enum TimeOfYear {
	case earlySpring
	case lateSpring
	case earlySummer
	case lateSummer
	case earlyFall
	case lateFall
	case earlyWinter
	case lateWinter

	static let possible: [TimeOfYear] = [.earlySpring, .lateSpring, .earlySummer, .lateSummer, .earlyFall, .lateFall, .earlyWinter, .lateWinter]

	mutating func next() {
		switch self {
		case .earlySpring:
			self = .lateSpring
		case .lateSpring:
			self = .earlySummer
		case .earlySummer:
			self = .lateSummer
		case .lateSummer:
			self = .earlyFall
		case .earlyFall:
			self = .lateFall
		case .lateFall:
			self = .earlyWinter
		case .earlyWinter:
			self = .lateWinter
		case .lateWinter:
			self = .earlySpring
		}
	}
}

enum GameConditions: Error {
	case gameEnded(reason: VictoryReason)
}

public struct CommunicationEmbed {
	public enum Kind {
		case good, bad, info
	}
	public let title: String
	public let body: String
	public let color: Kind
	public let fields: [Field]

	public struct Field {
		public let title: String
		public let body: String
	}

	public init(title: String = "", body: String = "", color: Kind = .info, fields: [Field] = []) {
		self.title = title
		self.body = body
		self.color = color
		self.fields = fields
	}
}

public struct CommunicationButton {
	public enum Color {
		case neutral, good, bad, bright
	}
	public let id: ButtonID
	public let label: String
	public let color: Color

	public init(id: ButtonID, label: String, color: Color = .neutral) {
		self.id = id
		self.label = label
		self.color = color
	}
}

public enum SingleUserSelectionID: String {
	case werewolfKill = "werewolf-kill"
	case guardianAngelProtect = "guardian-angel-protect"
	case seerInvestigate = "seer-investigate"
	case oracleInvestigate = "oracle-investigate"
	case cookiesGive = "cookies-give"
	case goose = "goose"
	case bartenderInebriate = "bartender-inebriate"
}

public enum MultiUserSelectionID: String {
	case nominate = "nominate"
}

public enum ButtonID: String {
	case nominateSkip = "nominate-skip"
	case voteYes = "vote-yes"
	case voteNo = "vote-no"
}

public protocol Sendable {
	associatedtype Message
	associatedtype UserID: Hashable

	func send(_ text: String) async throws -> Message
	func send(_ embed: CommunicationEmbed) async throws -> Message
	func send(_ buttons: [CommunicationButton]) async throws -> Message
	func send(userSelection options: [UserID], id: SingleUserSelectionID, label: String, buttons: [CommunicationButton]) async throws -> Message
	func send(multiUserSelection options: [UserID], id: MultiUserSelectionID, label: String, buttons: [CommunicationButton]) async throws -> Message
}

public extension Sendable {
	func send(userSelection options: [UserID], id: SingleUserSelectionID, label: String) async throws -> Message {
		try await self.send(userSelection: options, id: id, label: label, buttons: [])
	}
	func send(multiUserSelection options: [UserID], id: MultiUserSelectionID, label: String) async throws -> Message {
		try await self.send(multiUserSelection: options, id: id, label: label, buttons: [])
	}
}

public protocol I18nable {
	func i18n() -> I18n
}

public extension Sendable {
	func send(_ buttons: CommunicationButton...) async throws -> Message {
		try await self.send(buttons)
	}
	func send(userSelection options: Set<UserID>, id: SingleUserSelectionID, label: String) async throws -> Message {
		try await self.send(userSelection: Array(options), id: id, label: label)
	}
	func send(multiUserSelection options: Set<UserID>, id: MultiUserSelectionID, label: String) async throws -> Message {
		try await self.send(multiUserSelection: Array(options), id: id, label: label, buttons: [])
	}
}

public protocol Deletable {
	func delete() async throws
}

public protocol Replyable {
	func reply(with: String, epheremal: Bool) async throws
	func reply(with: CommunicationEmbed, epheremal: Bool) async throws
}

public protocol Mentionable {
	func mention() -> String
}

public protocol Communication {
	associatedtype UserID: Mentionable
	associatedtype Channel: Sendable & I18nable where Channel.Message == Self.Message, Channel.UserID == Self.UserID
	associatedtype Message: Deletable
	associatedtype Interaction: Replyable

	func getChannel(for: UserID, state: State<Self>) async throws -> Channel?
	func createGameThread(state: State<Self>) async throws -> Channel?
	func archive(_: Channel, state: State<Self>) async throws
	func currentParty(of user: UserID, state: State<Self>) async throws -> State<Self>?
	func onPrepareJoined(_ user: UserID, state: State<Self>) async throws
	func onJoined(_: UserID, state: State<Self>) async throws
	func onLeft(_: UserID, state: State<Self>) async throws
}

public class State<Comm: Communication> {
	enum Action: Equatable {
		case kill(who: Comm.UserID)
		case freeze(who: Comm.UserID)
		case protect(who: Comm.UserID)
		case check(who: Comm.UserID)
		case oracleCheck(who: Comm.UserID)
		case giveCookies(to: Comm.UserID)
		case goose(who: Comm.UserID)
		case inebriateRandom(who: Comm.UserID)
		case inebriateFail(who: Comm.UserID)
		case failedInebriate(who: Comm.UserID)

		func isValid<T: Sequence>(doer: Comm.UserID, with actions: T) -> Bool where T.Element == Action {
			if actions.contains(.freeze(who: doer)) {
				return false
			}
			if actions.contains(.kill(who: doer)) && self != .protect(who: doer) && !self.awayFromHome {
				return false
			}
			return true
		}

		var awayFromHome: Bool {
			switch self {
			case .kill, .giveCookies, .inebriateRandom, .inebriateFail, .failedInebriate:
				return true
			case .freeze, .protect, .check, .goose, .oracleCheck:
				return false
			}
		}
	}

	// user -> role
	var roles: [Comm.UserID: Role] = [:]

	// user -> team
	var teams: [Comm.UserID: Team] = [:]

	// where are we playing?
	public internal(set) var channel: Comm.Channel

	// what thread are we playing in?
	var thread: Comm.Channel?

	// who's playing?
	var party: OrderedSet<Comm.UserID> = []

	// who's voted for who?
	// player -> their votes
	var votes: [Comm.UserID: [Comm.UserID]] = [:]

	var eventLoop: EventLoop

	// what actions have been done tonight, and by who
	var actions: [Comm.UserID: Action] = [:]

	// what action messages have been sent
	var actionMessages: [Comm.UserID: Comm.Message] = [:]

	// who's alive?
	var alive: [Comm.UserID: Bool] = [:]

	var state: GameState = .waiting

	var timeOfYear: TimeOfYear

	var year: Int

	var day: Int

	var joinQueue: Set<Comm.UserID> = []

	var leaveQueue: Set<Comm.UserID> = []

	var comm: Comm

	var nominatedBefore: Set<Comm.UserID> = []

	var i18n: I18n

	public init(for channel: Comm.Channel, in comm: Comm, eventLoop: EventLoop) {
		self.channel = channel
		self.comm = comm
		self.day = 1
		self.year = 1
		self.timeOfYear = .possible.randomElement()!
		self.eventLoop = eventLoop
		self.votes = [:]
		self.i18n = channel.i18n()
	}

	func resetVotes() {
		self.votes = [:]
	}

	func clear() {
		self.day = 1
		self.year = 1
		self.timeOfYear = .possible.randomElement()!
		self.actions = [:]
		self.actionMessages = [:]
		self.roles = [:]
		self.teams = [:]
		self.alive = [:]
		self.votes = [:]
		self.nominatedBefore = []
	}

	func tickDay() {
		timeOfYear.next()
		if timeOfYear == .earlySpring {
			year += 1
		}
		day += 1
	}

	func assignRoles() async throws {
		clear()

		state = .assigned

		self.day = 1
		self.year = 1
		self.timeOfYear = .possible.randomElement()!

		party.forEach {
			alive[$0] = true
		}

		guard let shuffledRoles = Role.generateRoles(partySize: party.count) else {
			state = .waiting

			_ = try await channel.send("Failed to shuffle a balanced party, please reroll! If this happens too often, contact Janet.")

			return
		}

		shuffledRoles.indices.forEach { idx in
			roles[party[idx]] = shuffledRoles[idx]
		}

		party.forEach {
			teams[$0] = roles[$0]?.defaultTeam
		}

		for user in party {
			let dms = try await comm.getChannel(for: user, state: self)
			let role = roles[user]!
			do {
				_ = try await dms?.send(
					CommunicationEmbed(title: i18n.roleName(role), body: i18n.roleDescription(role) + "\n\n" + i18n.strategyBlurb(for: role))
				)
			} catch {
				_ = try await channel.send("I can't DM \(user.mention())! \(error)")
			}
		}
	}

	func endGameCleanup(reason: VictoryReason) async throws {
		if let thread = thread {
			_ = try await comm.archive(thread, state: self)
		}

		let txt = party
			.map { item -> String in
				let role = roles[item]!
				let alive = alive[item]! ? ":slight_smile:" : ":skull:"
				let won = teams[item] == reason.winningTeam ? ":trophy:" : ":x:"
				return "\(won)\(alive) \(item.mention()) (\(i18n.wasA(role)))"
			}
			.joined(separator: "\n")
		_ = try await channel.send(CommunicationEmbed(title: i18n.victoryTitle(reason), body: txt))

		let incoming = joinQueue.map { "\($0.mention())" }.joined(separator: "\n")
		let outgoing = leaveQueue.map { "\($0.mention())" }.joined(separator: "\n")
		for user in joinQueue {
			party.append(user)
			try await comm.onJoined(user, state: self)
		}
		for user in leaveQueue {
			party.remove(user)
			try await comm.onLeft(user, state: self)
		}
		if joinQueue.count > 0 {
			_ = try await channel.send(
				CommunicationEmbed(title: i18n.peopleJoinedParty, body: incoming, color: .good)
			)
		}
		if leaveQueue.count > 0 {
			_ = try await channel.send(
				CommunicationEmbed(title: i18n.peopleLeftParty, body: outgoing, color: .bad)
			)
		}
		joinQueue = []
		leaveQueue = []
	}

	func playNight() async throws {
		_ = try await thread?.send(i18n.nightHasFallen)

		// night actions
		_ = try await thread?.send(CommunicationEmbed(title: i18n.nightTitle(timeOfYear, year: year, day: day)))
		try await startNight()
		try await Task.sleep(nanoseconds: 35_000_000_000)

		// finish up night actions
		try await endNight()
		try await nightStatus()

		tickDay()

		_ = try await thread?.send(CommunicationEmbed(title: i18n.morningTitle(timeOfYear, year: year, day: day)))
		_ = try await thread?.send(i18n.villagersGather)
		_ = try await thread?.send(i18n.itIsDaytime)

		try await Task.sleep(nanoseconds: 30_000_000_000)

		_ = try await thread?.send(i18n.dayTimeRunningOut)

		try await Task.sleep(nanoseconds: 30_000_000_000)

		resetVotes()
		_ = try await thread?.send(i18n.eveningDraws)
		_ = try await thread?.send(
			multiUserSelection: party.filter { alive[$0]! },
			id: .nominate,
			label: i18n.nominationTitle
		)

		try await Task.sleep(nanoseconds: 15_000_000_000)

		_ = try await thread?.send(
			multiUserSelection: party.filter { alive[$0]! },
			id: .nominate,
			label: i18n.nominationEndingSoonTitle
		)

		try await Task.sleep(nanoseconds: 15_000_000_000)

		let allVotes = votes.flatMap { $0.value }
		let votedPlayers = Dictionary(allVotes.map { key in (key, allVotes.filter { $0 == key }.count) }, uniquingKeysWith: { a, _ in a })
		guard let highestVote = votedPlayers.max(by: { $0.value < $1.value }) else {
			_ = try await thread?.send(i18n.nobodyVoted)
			try await nightStatus()
			return
		}
		guard votedPlayers.filter({ $0.value == highestVote.value }).count == 1 else {
			_ = try await thread?.send(i18n.voteWasTie)
			try await nightStatus()
			try await sendVotes()
			return
		}

		_ = try await thread?.send(i18n.exilingTitle(who: highestVote.key))
		try await sendVotes()
		_ = try await attemptKill(highestVote.key, because: .exile)
		try await nightStatus()
	}

	func sendVotes() async throws {
		_ = try await thread?.send(CommunicationEmbed(
			body: votes.map { kvp in
				let uwu = kvp.value.map { $0.mention() }.joined(separator: ", ")
				return "\(kvp.key.mention()): \(uwu)"
			}.joined(separator: "\n"),
			color: .info
		))
	}

	func randomize<T>(_ one: T, _ two: T) -> (T, T) {
		var parts = [one, two]
		parts.shuffle()
		return (parts[0], parts[1])
	}
	func randomize<T>(_ one: T, _ two: T, _ three: T) -> (T, T, T) {
		var parts = [one, two, three]
		parts.shuffle()
		return (parts[0], parts[1], parts[2])
	}

	func startPlaying() async throws {
		state = .playing

		// TODO: create a thread
		thread = try await comm.createGameThread(state: self)

		let partyPings = party.map { "\($0.mention()) "}.joined(separator: ", ")
		_ = try await thread?.send(i18n.getOverHere(partyPings))
		_ = try await Task.sleep(nanoseconds: 5_000_000_000)

		for user in party {
			let dm = try await comm.getChannel(for: user, state: self)
			switch roles[user]! {
			case .jester:
				_ = try await dm?.send(CommunicationEmbed(title: i18n.jesterReminder))
			case .beholder:
				let seer = roles.filter { $0.value == .seer }[0]
				_ = try await dm?.send(CommunicationEmbed(body: i18n.beholderSeer(who: seer.key)))
			case .laundryperson:
				let player1 = party.filter{$0 != user}.filter{ teams[$0]! == .village }.randomElement()!
				let player2 = party.filter{$0 != user && $0 != player1}.randomElement()!
				let (p1, p2) = randomize(player1, player2)
				_ = try await dm?.send(CommunicationEmbed(body: i18n.laundrypersonStart(p1, p2, roles[player1]!)))
			case .gossip:
				let player1 = party.filter{$0 != user}.filter{ teams[$0]! == .werewolf }.randomElement()!
				let player2 = party.filter{$0 != user && $0 != player1}.randomElement()!
				let player3 = party.filter{$0 != user && $0 != player1 && $0 != player2}.randomElement()!
				let (p1, p2, p3) = randomize(player1, player2, player3)
				_ = try await dm?.send(CommunicationEmbed(body: i18n.gossip(p1, p2, p3)))
			case .librarian:
				let player1 = party.filter{$0 != user}.filter{ teams[$0]! == .werewolf }.randomElement()!
				let player2 = party.filter{$0 != user && $0 != player1}.randomElement()!
				let (p1, p2) = randomize(player1, player2)
				_ = try await dm?.send(CommunicationEmbed(body: i18n.librarianStart(p1, p2, roles[player1]!)))
			default:
				break
			}
		}

		while state == .playing {
			do {
				try await playNight()
			} catch GameConditions.gameEnded(let reason) {
				try await endGameCleanup(reason: reason)
			}
		}
	}

	func nightStatus() async throws {
		let txt = party.map { ($0, alive[$0]!) }
			.map { item -> String in
				i18n.nightStatus(who: item.0, role: roles[item.0]!, alive: item.1)
			}
			.joined(separator: "\n")
		_ = try await thread?.send(CommunicationEmbed(title: i18n.aliveTitle, body: txt))
	}

	func startNight() async throws {
		for user in party {
			if !(alive[user] ?? false) {
				continue
			}
			guard let dm = try await comm.getChannel(for: user, state: self) else {
				continue
			}
			switch roles[user]! {
			case .villager, .jester, .beholder, .furry, .innocent, .pacifist, .cursed, .laundryperson, .gossip, .librarian:
				break
			case .werewolf:
				let menu: Set<Comm.UserID>
				if self.timeOfYear == .earlyWinter || self.timeOfYear == .lateWinter {
					_ = try await dm.send(CommunicationEmbed(title: i18n.winterWolfAction))
					menu = Set(party.filter { $0 != user }.filter { alive[$0]! }.filter { teams[$0]! != .werewolf })
				} else {
					_ = try await dm.send(CommunicationEmbed(title: i18n.normalWolfAction))
					menu = Set(party.filter { alive[$0]! }.filter { $0 == user || teams[$0]! != .werewolf })
				}
				actionMessages[user] = try await dm.send(userSelection: menu, id: .werewolfKill, label: "")
			case .guardianAngel:
				_ = try await dm.send(CommunicationEmbed(title: i18n.gaAction))
				let possible = party.filter { alive[$0]! }
				actionMessages[user] = try await dm.send(userSelection: possible, id: .guardianAngelProtect, label: i18n.gaPrompt)
			case .seer:
				_ = try await dm.send(CommunicationEmbed(title: i18n.seerAction))
				let possible = party.filter { $0 != user }.filter { alive[$0]! }
				actionMessages[user] = try await dm.send(userSelection: possible, id: .seerInvestigate, label: i18n.seerPrompt)
			case .oracle:
				_ = try await dm.send(CommunicationEmbed(title: i18n.oracleAction))
				let possible = party.filter { $0 != user }.filter { alive[$0]! }
				actionMessages[user] = try await dm.send(userSelection: possible, id: .oracleInvestigate, label: i18n.oraclePrompt)
			case .cookiePerson:
				_ = try await dm.send(CommunicationEmbed(title: i18n.cpAction))
				let possible = party.filter { $0 != user }.filter { alive[$0]! }
				actionMessages[user] = try await dm.send(userSelection: possible, id: .cookiesGive, label: i18n.cpPrompt)
			case .goose:
				_ = try await dm.send(CommunicationEmbed(title: i18n.gooseAction))
				let possible = party.filter { $0 != user }.filter { alive[$0]! }.filter { teams[$0]! != .werewolf }
				actionMessages[user] = try await dm.send(userSelection: possible, id: .goose, label: i18n.goosePrompt)
			case .bartender:
				_ = try await dm.send(CommunicationEmbed(title: i18n.bartenderAction))
				let possible = party.filter{ $0 != user }.filter{ alive[$0]! }
				actionMessages[user] = try await dm.send(userSelection: possible, id: .bartenderInebriate, label: i18n.bartenderPrompt)
			}
		}
	}

	var werewolfKillSuccessRate: Double {
		switch party.count {
		case 4, 5:
			return 0.6
		case 6, 7:
			return 0.7
		case 8:
			return 0.8
		case 9:
			return 0.9
		default:
			return 1.0
		}
	}

	func kill(_ who: Comm.UserID, because why: DeathReason<Comm>) async throws {
		let dm = try await comm.getChannel(for: who, state: self)
		let reason: String
		switch why {
		case .werewolf:
			reason = i18n.drWerewolf
		case .exile:
			reason = i18n.drExile
		case .visitedWerewolf:
			reason = i18n.drVisit
		case .visitedSomeoneBeingVisitedByWerewolf(let visiting):
			reason = i18n.drVisitAlso(who: visiting)
		case .protectedWerewolf:
			reason = i18n.drProtect
		case .nominatedInnocent:
			reason = i18n.drInnocent
		case .goose:
			reason = i18n.drGoose
		}
		_ = try await dm?.send(CommunicationEmbed(body: reason, color: .bad))
		alive[who] = false

		if roles[who] == .werewolf && !roles.contains(where: { alive[$0.key]! && $0.value == .werewolf }) {
			let curseds = roles.filter({ $0.value == .cursed })
			for cursed in curseds.keys {
				roles[cursed] = .werewolf
				let dm = try await comm.getChannel(for: cursed, state: self)
				_ = try await dm?.send(CommunicationEmbed(body: i18n.cursedIsWerewolfNow, color: .good))
			}
		}
		if roles[who] == .werewolf && !roles.contains(where: { alive[$0.key]! && $0.value == .werewolf }) {
			let geese = roles.filter({ $0.value == .goose })
			for goose in geese.keys {
				let dm = try await comm.getChannel(for: goose, state: self)
				_ = try await dm?.send(CommunicationEmbed(body: i18n.gooseIsViolentNow, color: .good))
			}
		}
	}

	func attemptKill(_ who: Comm.UserID, because why: DeathReason<Comm>) async throws {
		switch why {
		case .werewolf, .goose:
			if why == .goose {
				_ = try await thread?.send(CommunicationEmbed(body: i18n.gooseKillMessage(who: who)))
			} else {
				_ = try await thread?.send(CommunicationEmbed(body: i18n.werewolfKillMessage(who: who)))
			}

			try await Task.sleep(nanoseconds: 3_000_000_000)

			if actions.contains(where: { $0.key == who && $0.value == .kill(who: who)}) {
				if Double.random(in: 0...1) < (werewolfKillSuccessRate * 0.2) {
					_ = try await thread?.send(CommunicationEmbed(body: i18n.killSuccess, color: .bad))
					try await kill(who, because: why)
				} else {
					_ = try await thread?.send(CommunicationEmbed(body: i18n.killFailure, color: .good))
				}
			} else if actions.contains(where: { $0.value == .protect(who: who) && $0.value.isValid(doer: $0.key, with: actions.values) }) {
				_ = try await thread?.send(CommunicationEmbed(body: i18n.killProtected, color: .good))
			} else if actions.contains(where: { $0.key == who && $0.value.awayFromHome && $0.value.isValid(doer: $0.key, with: actions.values) }) {
				_ = try await thread?.send(CommunicationEmbed(body: i18n.killAwayFromHome, color: .good))
			} else if Double.random(in: 0...1) < werewolfKillSuccessRate {
				_ = try await thread?.send(CommunicationEmbed(body: i18n.killSuccess, color: .bad))
				try await kill(who, because: why)
			} else {
				_ = try await thread?.send(CommunicationEmbed(body: i18n.killFailure, color: .good))
			}
		case .visitedWerewolf:
			_ = try await thread?.send(CommunicationEmbed(body: i18n.visitedWerewolf(who: who), color: .bad))
			try await Task.sleep(nanoseconds: 3_000_000_000)

			if actions.contains(where: { $0.value == .protect(who: who) && $0.value.isValid(doer: $0.key, with: actions.values) }) {
				_ = try await thread?.send(CommunicationEmbed(body: i18n.visitedWerewolfProtected(who: who), color: .good))
			} else {
				_ = try await thread?.send(CommunicationEmbed(body: i18n.visitedWerewolfEaten(who: who), color: .bad))

				try await kill(who, because: .visitedWerewolf)
			}
		case .visitedSomeoneBeingVisitedByWerewolf(let visiting):
			_ = try await thread?.send(CommunicationEmbed(body: i18n.visitedPersonBeingVisitedByWerewolf(who: who, visiting: visiting), color: .bad))
			try await Task.sleep(nanoseconds: 3_000_000_000)
			if actions.contains(where: { $0.value == .protect(who: who) && $0.value.isValid(doer: $0.key, with: actions.values) }) {
				_ = try await thread?.send(CommunicationEmbed(body: i18n.visitedPersonBeingVisitedByWerewolfProtected(who: who), color: .good))
			} else {
				_ = try await thread?.send(CommunicationEmbed(body: i18n.visitedPersonBeingVisitedByWerewolfEaten(who: who), color: .bad))
				try await kill(who, because: why)
			}
			break
		case .exile:
			if teams[who]! == .village && roles.filter({ alive[$0.key]! }).contains(where: { $0.value == .pacifist}) && Double.random(in: 0...1) > 0.5 {
				_ = try await thread?.send(CommunicationEmbed(body: i18n.pacifistIntervention(who: who), color: .good))
			} else {
				try await kill(who, because: why)
			}
		case .nominatedInnocent:
			_ = try await thread?.send(CommunicationEmbed(body: i18n.nominatedInnocent(who: who), color: .bad))
			try await kill(who, because: why)
		case .protectedWerewolf:
			if Double.random(in: 0...1) > 0.5 {
				_ = try await thread?.send(CommunicationEmbed(body: i18n.protectedWerewolf(who: who), color: .bad))

				try await kill(who, because: .protectedWerewolf)
			}
		}
		try await handlePossibleWin(whoDied: who, why: why)
	}

	func trueWho(target: Comm.UserID, for doer: Comm.UserID) -> Comm.UserID {
		if actions.values.contains(.goose(who: doer)) || actions.values.contains(.inebriateRandom(who: doer)) {
			return party.filter { alive[$0]! }.randomElement()!
		}
		return target
	}

	func endNight() async throws {
		for actionMessage in actionMessages {
			try await actionMessage.value.delete()
		}
		actionMessages = [:]
		for action in actions {
			if actions.values.contains(.freeze(who: action.key)) {
				let dm = try await comm.getChannel(for: action.key, state: self)
				_ = try await dm?.send(CommunicationEmbed(body: i18n.frozenByWerewolfDM, color: .bad))
				_ = try await thread?.send(CommunicationEmbed(body: i18n.frozenByWerewolfAnnouncement, color: .bad))
				continue
			}
			if actions.values.contains(.inebriateFail(who: action.key)) {
				let dm = try await comm.getChannel(for: action.key, state: self)
				_ = try await dm?.send(CommunicationEmbed(body: i18n.inebriatedFailureDM, color: .bad))
				continue
			}
			switch action.value {
			case .check(let who):
				let truth = trueWho(target: who, for: action.key)
				let role = roles[truth]!.appearsAs(to: .seer)
				let dm = try await comm.getChannel(for: action.key, state: self)
				_ = try await dm?.send(CommunicationEmbed(body: i18n.check(who: who, is: role), color: .bad))
			case .oracleCheck(let who):
				let truth = trueWho(target: who, for: action.key)
				let possibleRoles = Set(party.filter{roles[$0] != roles[truth]}.filter{alive[$0]!}.map{roles[$0]!}).filter{$0 != .oracle}
				let dm = try await comm.getChannel(for: action.key, state: self)
				if let role = possibleRoles.randomElement() {
					_ = try await dm?.send(CommunicationEmbed(body: i18n.check(who: who, isNot: role), color: .bad))
				} else {
					_ = try await dm?.send(CommunicationEmbed(body: "\(who.mention()) is not a something...? I shouldn't be able to reach this game state", color: .bad))
				}
			case .kill(let who):
				let truth = trueWho(target: who, for: action.key)
				try await attemptKill(truth, because: .werewolf)
			case .giveCookies(let who):
				let truth = trueWho(target: who, for: action.key)
				if roles[truth] == .werewolf {
					try await attemptKill(action.key, because: .visitedWerewolf)
				} else if actions.contains(where: { $0.value == .kill(who: truth) && $0.value.isValid(doer: $0.key, with: actions.values) }) {
					try await attemptKill(action.key, because: .visitedSomeoneBeingVisitedByWerewolf(visiting: truth))
				}
			case .protect(let who):
				let truth = trueWho(target: who, for: action.key)
				if roles[truth] == .werewolf {
					try await attemptKill(action.key, because: .protectedWerewolf)
				}
			case .goose(let who) where !roles.contains(where: { alive[$0.key]! && $0.value == .werewolf }):
				let truth = trueWho(target: who, for: action.key)
				try await attemptKill(truth, because: .goose)
			case .inebriateRandom(let who), .inebriateFail(let who), .failedInebriate(let who):
				let truth = trueWho(target: who, for: action.key)
				if actions.contains(where: { $0.value == .kill(who: truth) && $0.value.isValid(doer: $0.key, with: actions.values) }) {
					try await attemptKill(action.key, because: .visitedSomeoneBeingVisitedByWerewolf(visiting: truth))
				}
				let dm = try await comm.getChannel(for: action.key, state: self)
				switch action.value {
				case .inebriateRandom:
					_ = try await dm?.send(CommunicationEmbed(body: i18n.bartenderRandomised(who), color: .info))
				case .inebriateFail:
					_ = try await dm?.send(CommunicationEmbed(body: i18n.bartenderStopped(who), color: .info))
				case .failedInebriate:
					_ = try await dm?.send(CommunicationEmbed(body: i18n.bartenderFailed(who), color: .info))
				default:
					()
				}
			case .freeze(_), .goose(_):
				continue
			}
			try await Task.sleep(nanoseconds: 2_000_000_000)
		}
		actions = [:]
	}

	func checkWin(whoDied: Comm.UserID, why: DeathReason<Comm>) -> VictoryReason? {
		let werewolvesAlive = roles.filter { teams[$0.key] == .werewolf }
			.filter { alive[$0.key] == true }
		let nonWerewolvesAlive = roles.filter { teams[$0.key] != .werewolf }
			.filter { alive[$0.key] == true }

		if roles[whoDied] == .jester && why == .exile {
			return .jesterExiled
		}

		if werewolvesAlive.count == 0 {
			return .allWerewolvesDead
		} else if werewolvesAlive.count >= nonWerewolvesAlive.count {
			return .werewolvesMajority
		}

		return nil
	}

	func handlePossibleWin(whoDied: Comm.UserID, why: DeathReason<Comm>) async throws {
		guard let reason = checkWin(whoDied: whoDied, why: why) else {
			return
		}

		_ = try await thread?.send(i18n.victory(reason))

		state = .waiting
		let txt = party
			.map { item -> String in
				let role = roles[item]!
				let alive = alive[item]! ? ":slight_smile:" : ":skull:"
				let won = teams[item] == reason.winningTeam ? ":trophy:" : ":x:"
				return "\(won)\(alive) \(item.mention()) (\(i18n.wasA(role)))"
			}
			.joined(separator: "\n")
		_ = try await thread?.send(CommunicationEmbed(title: i18n.playerStatusTitle, body: txt))

		throw GameConditions.gameEnded(reason: reason)
	}

	public let arglessCommands = [
		"join": join,
		"leave": leave,
		"setup": setup,
		"unsetup": unsetup,
		"party": party,
		"start": start,
		"roles": sendRoles,
	]
	public let userCommands = [
		"promote": promote,
		"remove": remove,
	]
	public let stringCommands = [
		"language": language,
		"role": role,
	]

	// command implementations
	func join(who: Comm.UserID, interaction: Comm.Interaction) async throws {
		guard state == .waiting || state == .assigned else {
			if leaveQueue.contains(who) {
				_ = try await interaction.reply(with: i18n.leaveLeaveQueue, epheremal: true)
			} else {
				guard !party.contains(who) else {
					_ = try await interaction.reply(with: i18n.alreadyInParty, epheremal: true)
					return
				}
				guard try await comm.currentParty(of: who, state: self) == nil else {
					_ = try await interaction.reply(with: i18n.alreadyInAnotherParty, epheremal: true)
					return
				}

				joinQueue.insert(who)
				try await comm.onPrepareJoined(who, state: self)
				_ = try await interaction.reply(with: i18n.addedJoinQueue, epheremal: true)
			}
			return
		}
		guard !party.contains(who) else {
			_ = try await interaction.reply(with: i18n.alreadyInParty, epheremal: true)
			return
		}
		guard try await comm.currentParty(of: who, state: self) == nil else {
			_ = try await interaction.reply(with: i18n.alreadyInAnotherParty, epheremal: true)
			return
		}
		try await comm.onPrepareJoined(who, state: self)
		try await comm.onJoined(who, state: self)
		party.append(who)
		_ = try await interaction.reply(with: i18n.joinedParty, epheremal: false)
		if state == .assigned {
			state = .waiting
			_ = try await interaction.reply(with: i18n.setupRequired, epheremal: true)
		}
	}
	func leave(who: Comm.UserID, interaction: Comm.Interaction) async throws {
		guard state == .waiting else {
			if joinQueue.contains(who) {
				joinQueue.remove(who)
				_ = try await interaction.reply(with: i18n.leaveJoinQueue, epheremal: true)
			} else {
				leaveQueue.insert(who)
				_ = try await interaction.reply(with: i18n.addedLeaveQueue, epheremal: true)
			}
			return
		}
		guard party.contains(who) else {
			_ = try await interaction.reply(with: i18n.notInParty, epheremal: true)
			return
		}
		try await comm.onLeft(who, state: self)
		party.remove(who)
		try await interaction.reply(with: i18n.leftParty, epheremal: false)
	}
	func setup(who: Comm.UserID, interaction: Comm.Interaction) async throws {
		guard who == party.first else {
			try await interaction.reply(with: i18n.mustBePartyLeader, epheremal: true)
			return
		}
		guard state == .waiting || state == .assigned else {
			try await interaction.reply(with: i18n.gameAlreadyInProgress, epheremal: false)
			return
		}
		guard party.count >= 4 else {
			try await interaction.reply(with: i18n.atLeastFourPeopleNeeded, epheremal: false)
			return
		}
		try await assignRoles()
		try await interaction.reply(with: i18n.gameHasBeenSetUp, epheremal: false)
	}
	func unsetup(who: Comm.UserID, interaction: Comm.Interaction) async throws {
		guard state == .assigned else {
			try await interaction.reply(with: i18n.lobbyNotInRightState, epheremal: true)
			return
		}

		state = .waiting
		try await interaction.reply(with: i18n.gameHasBeenUnSetUp, epheremal: false)
	}
	func party(who: Comm.UserID, interaction: Comm.Interaction) async throws {
		_ = try await interaction.reply(
			with: CommunicationEmbed(title: i18n.partyListTitle, body: party.map { "\($0.mention())" }.joined(separator: "\n")),
			epheremal: false
		)
	}
	func start(who: Comm.UserID, interaction: Comm.Interaction) async throws {
		guard who == party.first else {
			try await interaction.reply(with: i18n.mustBePartyLeader, epheremal: true)
			return
		}
		guard state != .playing else {
			try await interaction.reply(with: i18n.gameAlreadyInProgress, epheremal: true)
			return
		}
		guard state == .assigned else {
			try await interaction.reply(with: i18n.mustSetUpBeforeStarting, epheremal: true)
			return
		}
		try await interaction.reply(with: i18n.gameHasBeenStarted, epheremal: false)
		try await startPlaying()
	}
	func promote(who: Comm.UserID, target: Comm.UserID, interaction: Comm.Interaction) async throws {
		guard who == party.first else {
			try await interaction.reply(with: i18n.mustBePartyLeader, epheremal: true)
			return
		}
		guard party.contains(target) else {
			try await interaction.reply(with: i18n.targetNotInParty, epheremal: true)
			return
		}
		party.swapAt(party.firstIndex(of: who)!, party.firstIndex(of: target)!)
		try await interaction.reply(with: i18n.hasBeenPromoted(target), epheremal: false)
	}
	func remove(who: Comm.UserID, target: Comm.UserID, interaction: Comm.Interaction) async throws {
		guard who == party.first else {
			try await interaction.reply(with: i18n.mustBePartyLeader, epheremal: true)
			return
		}
		guard state == .waiting else {
			if joinQueue.contains(target) {
				joinQueue.remove(target)
				_ = try await interaction.reply(with: i18n.leaveJoinQueue, epheremal: true)
			} else if party.contains(target) {
				leaveQueue.insert(target)
				_ = try await interaction.reply(with: i18n.addedLeaveQueue, epheremal: true)
			} else {
				try await interaction.reply(with: i18n.targetNotInParty, epheremal: true)
			}
			return
		}
		guard party.contains(target) else {
			try await interaction.reply(with: i18n.targetNotInParty, epheremal: true)
			return
		}
		try await comm.onLeft(target, state: self)
		party.remove(target)
		try await interaction.reply(with: i18n.hasBeenRemoved(target), epheremal: false)
	}
	func language(who: Comm.UserID, what: String, interaction: Comm.Interaction) async throws {
		guard who == party.first else {
			try await interaction.reply(with: i18n.mustBePartyLeader, epheremal: true)
			return
		}
		switch what {
		case "toki pona", "tpo", "tok", "toki", "pona", "tokipona":
			i18n = TokiPona()
			try await interaction.reply(with: "toki musi li toki pona!", epheremal: true)
		case "english", "en":
			i18n = English()
			try await interaction.reply(with: "The game language is English!", epheremal: true)
		default:
			try await interaction.reply(with: "I don't know that language!", epheremal: true)
		}
	}
	func role(who: Comm.UserID, what: String, interaction: Comm.Interaction) async throws {
		guard let role = Role.allCases.filter({ role in
			i18n.roleName(role).lowercased().contains(what.lowercased())
		}).first else {
			try await interaction.reply(with: i18n.roleNotFound, epheremal: true)
			return
		}

		try await interaction.reply(with: CommunicationEmbed(
			title: i18n.roleName(role),
			body: i18n.roleDescription(role),
			color: .info,
			fields: [
				.init(title: i18n.headerMinimumPlayerCount, body: "\(role.minimumPlayerCount)"),
				.init(title: i18n.headerMaximumRoleCount, body: "\(role.absoluteMax)"),
				.init(title: i18n.headerTeam, body: i18n.teamName(role.defaultTeam)),
			]
		), epheremal: true)
	}
	func sendRoles(who: Comm.UserID, interaction: Comm.Interaction) async throws {
		let roles = Role.allCases.map{ i18n.roleName($0) }.map{ "- \($0)" }.joined(separator: "\n")

		try await interaction.reply(with: CommunicationEmbed(title: i18n.headerRoles, body: roles, color: .info), epheremal: true)
	}

	public let multiUserDropdowns = [
		MultiUserSelectionID.nominate: nominate,
	]
	func nominate(who: Comm.UserID, targets: [Comm.UserID], interaction: Comm.Interaction) async throws {
		guard alive[who] == true else {
			try await interaction.reply(with: i18n.mustBeAliveToVote, epheremal: true)
			return
		}

		_ = try await interaction.reply(with: i18n.voteHasBeenRecorded, epheremal: true)
		votes[who] = targets
		if targets.contains(where: { roles[$0] == .innocent && !nominatedBefore.contains($0) }) && teams[who]! != .werewolf {
			try await attemptKill(who, because: .nominatedInnocent)
		}
		targets.forEach { nominatedBefore.insert($0) }
	}

	public let singleUserDropdowns = [
		SingleUserSelectionID.werewolfKill: werewolfKill,
		.guardianAngelProtect: guardianAngelProtect,
		.seerInvestigate: seerInvestigate,
		.cookiesGive: cookiesGive,
		.goose: goose,
		.oracleInvestigate: oracleInvestigate,
		.bartenderInebriate: bartenderInebriate,
	]

	// interaction implementations
	func oracleInvestigate(who: Comm.UserID, target: Comm.UserID, interaction: Comm.Interaction) async throws {
		guard roles[who] == .oracle else {
			try await interaction.reply(with: i18n.youAreNotA(.oracle), epheremal: true)
			return
		}
		try await interaction.reply(with: i18n.youAreGoingToInvestigate(target), epheremal: true)
		actions[who] = .oracleCheck(who: target)
	}

	func werewolfKill(who: Comm.UserID, target: Comm.UserID, interaction: Comm.Interaction) async throws {
		guard roles[who] == .werewolf else {
			try await interaction.reply(with: i18n.youAreNotA(.werewolf), epheremal: true)
			return
		}
		if timeOfYear == .earlyWinter || timeOfYear == .lateWinter {
			try await interaction.reply(with: i18n.youAreGoingToFreeze(target), epheremal: false)
			actions[who] = .freeze(who: target)
		} else {
			try await interaction.reply(with: i18n.youAreGoingToKill(target), epheremal: false)
			actions[who] = .kill(who: target)
		}
	}
	func guardianAngelProtect(who: Comm.UserID, target: Comm.UserID, interaction: Comm.Interaction) async throws {
		guard roles[who] == .guardianAngel else {
			try await interaction.reply(with: i18n.youAreNotA(.guardianAngel), epheremal: true)
			return
		}
		try await interaction.reply(with: i18n.youAreGoingToProtect(target), epheremal: false)
		actions[who] = .protect(who: target)
	}
	func seerInvestigate(who: Comm.UserID, target: Comm.UserID, interaction: Comm.Interaction) async throws {
		guard roles[who] == .seer else {
			try await interaction.reply(with: i18n.youAreNotA(.seer), epheremal: true)
			return
		}
		try await interaction.reply(with: i18n.youAreGoingToInvestigate(target), epheremal: false)
		actions[who] = .check(who: target)
	}
	func cookiesGive(who: Comm.UserID, target: Comm.UserID, interaction: Comm.Interaction) async throws {
		guard roles[who] == .cookiePerson else {
			try await interaction.reply(with: i18n.youAreNotA(.cookiePerson), epheremal: true)
			return
		}
		try await interaction.reply(with: i18n.youAreGoingToGiveCookies(to: target), epheremal: false)
		actions[who] = .giveCookies(to: target)
	}
	func goose(who: Comm.UserID, target: Comm.UserID, interaction: Comm.Interaction) async throws {
		guard alive[who] == true && roles[who] == .goose else {
			try await interaction.reply(with: i18n.youAreNotA(.goose), epheremal: true)
			return
		}
		try await interaction.reply(with: i18n.youAreGoingToGoose(target), epheremal: false)
		actions[who] = .goose(who: target)
	}
	func bartenderInebriate(who: Comm.UserID, target: Comm.UserID, interaction: Comm.Interaction) async throws {
		guard alive[who] == true && roles[who] == .bartender else {
			try await interaction.reply(with: i18n.youAreNotA(.bartender), epheremal: true)
			return
		}
		try await interaction.reply(with: i18n.youAreGoingToInebriate(target), epheremal: false)
		let dice = Double.random(in: 0...1)
		if dice <= 0.5 {
			actions[who] = .inebriateRandom(who: target)
		} else if dice <= 0.9 {
			actions[who] = .inebriateFail(who: target)
		} else {
			actions[who] = .failedInebriate(who: target)
		}
	}

	public let buttons: [ButtonID: (State<Comm>) -> (Comm.UserID, Comm.Interaction) async throws -> ()] = [:]
}
