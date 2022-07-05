import Swiftcord
import NIO
import Foundation
import AsyncKit

struct Config: Codable {
	var token: String
}

let config = try! JSONDecoder().decode(Config.self,  from: try! String(contentsOfFile: "config.json").data(using: .utf8)!)

enum Role {
	case villager
	case werewolf
	case guardianAngel
	case seer
	case beholder
	case jester
	case cookiePerson
	case furry

	func appearsAs(to: Role) -> Role {
		switch (self, to) {
		case (.furry, .seer):
			return .werewolf
		default:
			return self
		}
	}

	func isValid(with roles: [Role], playerCount count: Int) -> Bool {
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
		return true
	}

	var absoluteMax: Int {
		switch self {
		case .guardianAngel, .seer, .beholder, .jester, .cookiePerson:
			return 1
		default:
			return Int.max
		}
	}
	var minimumPlayerCount: Int {
		switch self {
		case .beholder, .cookiePerson, .jester:
			return 5
		default:
			return 0
		}
	}
	var roleName: String {
		switch self {
		case .villager:
			return "Villager"
		case .werewolf:
			return "Werewolf"
		case .guardianAngel:
			return "Guardian Angel"
		case .seer:
			return "Seer"
		case .beholder:
			return "Beholder"
		case .jester:
			return "Jester"
		case .cookiePerson:
			return "Cookie Person"
		case .furry:
			return "Furry"
		}
	}
	var roleDescription: String {
		switch self {
		case .villager:
			return "You are but a simple villager, with the ability to vote people out."
		case .werewolf:
			return "You are the werewolf! Eat everyone, but try not to get caught!"
		case .guardianAngel:
			return "Each night, you can protect one person, but be careful: if you protect a werewolf, there's a 50% chance they might eat you!"
		case .seer:
			return "Your wisdom allows you to choose a player every night. Their role will be revealed to be you. Be careful, if you reveal you're the seer, the wolves might try to kill you!"
		case .beholder:
			return "You have one job: you know who the Seer is."
		case .jester:
			return "You have one goal: get the village to exile you."
		case .cookiePerson:
			return "Every night, you can choose to visit someone and give them cookies. If you visit a wolf, you will be killed. However, if you're visiting someone and the wolves try to kill you, you'll survive! (because you weren't home). If the wolves kill someone you're visiting, they'll kill you as well."
		case .furry:
			return "You love to cosplay as a wolf! The problem is, the seer doesn't know what's up with these newfangled youths, and assumes you are a wolf. Oops."
		}
	}

	static let good: [Role] = [.guardianAngel, .seer, .beholder]
	static let neutral: [Role] = [.villager, .jester, .cookiePerson, .furry]
	static let evil: [Role] = [.werewolf]
}

enum Action: Equatable {
	case kill(who: Snowflake)
	case freeze(who: Snowflake)
	case protect(who: Snowflake)
	case check(who: Snowflake)
	case giveCookies(to: Snowflake)

	var awayFromHome: Bool {
		switch self {
		case .kill, .giveCookies:
			return true
		case .freeze, .protect, .check:
			return false
		}
	}
}

enum GameState {
	case waiting
	case assigned
	case playing
}

enum DeathReason {
	case werewolf
	case exile
}

enum TimeOfYear {
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

	var name: String {
		switch self {
		case .earlySpring:
			return "Early Spring"
		case .lateSpring:
			return "Late Spring"
		case .earlySummer:
			return "Early Summer"
		case .lateSummer:
			return "Late Summer"
		case .earlyFall:
			return "Early Fall"
		case .lateFall:
			return "Late Fall"
		case .earlyWinter:
			return "Early Winter"
		case .lateWinter:
			return "Late Winter"
		}
	}
}

extension Collection where Self.Element: Comparable {
	func except(_ item: Self.Element) -> [Self.Element] {
		self.filter({ $0 != item })
	}
}

// user -> state
var currentlyIn: [Snowflake: State] = [:]

class State {
	// user -> role
	var roles: [Snowflake: Role] = [:]

	// id -> user
	var users: [Snowflake: User] = [:]

	// where are we playing?
	var channel: TextChannel

	// what thread are we playing in?
	var thread: TextChannel?

	// who's playing?
	var party: Set<Snowflake> = []

	// what actions have been done tonight, and by who
	var actions: [Snowflake: Action] = [:]

	// what action messages have been sent
	var actionMessages: [Snowflake: Message] = [:]

	// who's alive?
	var alive: [Snowflake: Bool] = [:]

	// who's voting for who?
	var votes: [Snowflake: Snowflake] = [:]

	var state: GameState = .waiting

	var timeOfYear: TimeOfYear

	var year: Int

	var day: Int

	init(for channel: TextChannel) {
		self.channel = channel
		self.day = 1
		self.year = 1
		self.timeOfYear = .possible.randomElement()!
	}

	func clear() {
		self.day = 1
		self.year = 1
		self.timeOfYear = .possible.randomElement()!
		self.actions = [:]
		self.actionMessages = [:]
		self.roles = [:]
		self.votes = [:]
		self.alive = [:]
	}

	func eligible(_ against: [Role]) -> [Role] {
		against.filter { $0.isValid(with: Array(roles.values), playerCount: party.count) }
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
		let shuffle = party.shuffled()
		let evil = max(Int(floor(Float(shuffle.count) * 0.2)), 1)
		let good = max(Int(floor(Float(shuffle.count) * 0.4)), 2)
		let specials = shuffle.prefix(evil + good)

		specials.prefix(evil).forEach {
			roles[$0] = eligible(Role.evil).randomElement()!
		}
		specials.suffix(good).forEach {
			roles[$0] = eligible(Role.good).randomElement()!
		}

		let neutral = max(shuffle.count - (evil + good), 0)
		shuffle.suffix(neutral).forEach {
			roles[$0] = eligible(Role.neutral).randomElement()!
		}

		for user in shuffle {
			let dms = try await bot.getDM(for: user)
			do {
				_ = try await dms?.send(
					EmbedBuilder.info
						.setTitle(title: roles[user]!.roleName)
						.setDescription(description: roles[user]!.roleDescription)
				)
			} catch ResponseError.nonSuccessfulRequest(let code) where code.code == 50007 {
				_ = try await thread?.send("I can't DM <@\(user)>!")
			}
		}
	}

	func userMenu(id: String, users: [User]) -> ActionRow<SelectMenu> {
		typealias From = (String, String?, SelectMenuOptions...) -> SelectMenu
		typealias To = (String, String?, [SelectMenuOptions]) -> SelectMenu

		let it = unsafeBitCast(SelectMenu.init, to: To.self)

		return ActionRow(components: it(id, nil, users.map { SelectMenuOptions(label: $0.username!, value: "\($0.id)") }))
	}

	func startPlaying() async throws {
		state = .playing

		// TODO: create a thread
		thread = try await bot.createThread(in: channel.id, StartThreadData(name: "Mappo Game"))

		let partyPings = party.map { "<@\($0)> "}.joined(separator: ", ")
		_ = try await thread?.send("\(partyPings), get over here!")
		_ = try await Task.sleep(nanoseconds: 5_000_000_000)

		for user in party {
			let dm = try await bot.getDM(for: user)
			switch roles[user]! {
			case .jester:
				_ = try await dm?.send(EmbedBuilder.info.setTitle(title: "Remember: get yourself exiled!"))
			case .beholder:
				let seer = roles.filter { $0.value == .seer }[0]
				_ = try await dm?.send(EmbedBuilder.info.setDescription(description: "The Seer is <@\(seer.key)>"))
			default:
				break
			}
		}

		while state == .playing {
			_ = try await thread?.send("Night has fallen. Everyone heads to bed, weary after another stressful day. Night players: you have 35 seconds to use your actions!")

			// night actions
			_ = try await thread?.send(EmbedBuilder.info.setTitle(title: "Night of \(timeOfYear.name) of Year \(year) (Game Day \(day))"))
			try await startNight()
			try await Task.sleep(nanoseconds: 35_000_000_000)

			// finish up night actions
			try await endNight()
			try await checkWin()
			if state != .playing {
				if let id = thread?.id {
					_ = try await bot.modifyChannel(id, with: ["archived": true])
				}
				return
			}

			try await nightStatus()

			tickDay()

			_ = try await thread?.send(EmbedBuilder.info.setTitle(title: "Morning of \(timeOfYear.name) of Year \(year) (Game Day \(day))"))
			_ = try await thread?.send("The villagers gather the next morning in the village center.")
			_ = try await thread?.send("It is now day time. All of you have 50 seconds to make your accusations, defenses, or just talk.")

			try await Task.sleep(nanoseconds: 50_000_000_000)

			_ = try await thread?.send("Dusk draws near, and the villagers gather to decide who they are exiling this evening...")
			_ = try await thread?.send("Everyone has 30 seconds to vote!")

			// talk & vote time
			try await announceVote()
			try await Task.sleep(nanoseconds: 30_000_000_000)
			try await concludeVote()

			try await checkWin()
			if state != .playing {
				if let id = thread?.id {
					_ = try await bot.modifyChannel(id, with: ["archived": true])
				}
				return
			}
		}
	}

	func nightStatus() async throws {
		let txt = users.values.map { ($0, alive[$0.id]!) }
			.map { item -> String in
				if item.1 {
					return ":white_check_mark: <@\(item.0.id)>"
				} else {
					let role = roles[item.0.id]!
					return ":x: <@\(item.0.id)> (was a \(role.roleName))"
				}
			}
			.joined(separator: "\n")
		_ = try await thread?.send(EmbedBuilder.info.setTitle(title: "Alive").setDescription(description: txt))
	}

	func announceVote() async throws {
		let possible = users.values.filter { alive[$0.id]! }
		let menu = SelectMenuBuilder(message: "Vote on who to exile!")
			.addComponent(component: userMenu(id: "vote", users: possible))
		_ = try await thread?.send(menu)
	}

	func concludeVote() async throws {
		if votes.count == 0 {
			_ = try await thread?.send("Nobody was voted out... sad...")
			return
		}

		var count: [Snowflake: Int] = [:]
		votes.forEach { count[$0.value] = (count[$0.value] ?? 0) + 1 }

		let who = count.sorted(by: { $0.value > $1.value })[0]
		guard who.value >= 2 else {
			_ = try await thread?.send("Nobody was voted out... sad...")
			return
		}
		_ = try await thread?.send("The villagers have cast their votes, amid doubts and suspicions. <@\(who.key)> is exiled.")
		try await kill(who.key, because: .exile)
		let name = roles[who.key]!.roleName
		_ = try await thread?.send("<@\(who.key)> was a **\(name)**!")

		self.votes = [:]
	}

	func startNight() async throws {
		for user in party {
			if !(alive[user] ?? false) {
				continue
			}
			guard let dm = try await bot.getDM(for: user) else {
				continue
			}
			switch roles[user]! {
			case .villager, .jester, .beholder, .furry:
				break
			case .werewolf:
				let menu: SelectMenuBuilder
				if self.timeOfYear == .earlyWinter || self.timeOfYear == .lateWinter {
					_ = try await dm.send(EmbedBuilder.good.setTitle(title: "Looks like it's winter! With your snow coat, it's time to freeze someone tonight! This will prevent them from performing any action today."))
					menu = SelectMenuBuilder(message: "Choose someone to freeze")
						.addComponent(component: userMenu(id: "werewolf-kill", users: Array(users.values).filter { $0.id != user }.filter { alive[$0.id]! }))
				} else {
					_ = try await dm.send(EmbedBuilder.good.setTitle(title: "Time to kill someone tonight!"))
					menu = SelectMenuBuilder(message: "Choose someone to kill")
						.addComponent(component: userMenu(id: "werewolf-kill", users: Array(users.values).filter { $0.id != user }.filter { alive[$0.id]! }))
				}
				actionMessages[user] = try await dm.send(menu)
			case .guardianAngel:
				_ = try await dm.send(EmbedBuilder.good.setTitle(title: "Time to protect someone tonight!"))
				let menu = SelectMenuBuilder(message: "Choose someone to protect")
					.addComponent(component: userMenu(id: "guardianAngel-protect", users: Array(users.values).filter { alive[$0.id]! }))
				actionMessages[user] = try await dm.send(menu)
			case .seer:
				_ = try await dm.send(EmbedBuilder.good.setTitle(title: "Time to see someone tonight!"))
				let menu = SelectMenuBuilder(message: "Choose someone to see their role")
					.addComponent(component: userMenu(id: "seer-investigate", users: Array(users.values).filter { $0.id != user }.filter { alive[$0.id]! }))
				actionMessages[user] = try await dm.send(menu)
			case .cookiePerson:
				_ = try await dm.send(EmbedBuilder.good.setTitle(title: "Time to visit someone tonight!"))
				let menu = SelectMenuBuilder(message: "Choose someone to visit them during the night and give them cookies")
					.addComponent(component: userMenu(id: "cookies-give", users: Array(users.values).filter { $0.id != user }.filter { alive[$0.id]! }))
				actionMessages[user] = try await dm.send(menu)
			}
		}
	}

	func kill(_ who: Snowflake, because why: DeathReason) async throws {
		let dm = try await bot.getDM(for: who)
		let reason: String
		switch why {
		case .werewolf:
			reason = "You were killed by a werewolf!"
		case .exile:
			if roles[who] == .jester {
				state = .waiting
				try await checkWin()
				_ = try await thread?.send("<@\(who)> was the Jester! They win!")
				return
			}
			reason = "You were exiled by the village!"
		}
		_ = try await dm?.send(EmbedBuilder.bad.setDescription(description: reason))
		alive[who] = false
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

	func endNight() async throws {
		for actionMessage in actionMessages {
			try await actionMessage.value.delete()
		}
		actionMessages = [:]
		for action in actions {
			if actions.values.contains(.freeze(who: action.key)) {
				let dm = try await bot.getDM(for: action.key)
				_ = try await dm?.send(EmbedBuilder.bad.setDescription(description: "A werewolf froze you, therefore you couldn't do anything tonight!"))
			}
			switch action.value {
			case .check(let who):
				let name = roles[who]!.appearsAs(to: .seer).roleName
				let dm = try await bot.getDM(for: action.key)
				_ = try await dm?.send(EmbedBuilder.bad.setDescription(description: "<@\(who.rawValue)> is a \(name)!"))
			case .kill(let who):
				_ = try await thread?.send(EmbedBuilder.bad.setDescription(description: "The Werewolves try to kill <@\(who.rawValue)>..."))
				try await Task.sleep(nanoseconds: 3_000_000_000)
				if actions.contains(where: { $0.value == .protect(who: who)}) {
					_ = try await thread?.send(EmbedBuilder.good.setDescription(description: "... but a Guardian Angel protects them!"))
				} else if actions.contains(where: { $0.key == who && $0.value.awayFromHome }) {
					_ = try await thread?.send(EmbedBuilder.good.setDescription(description: "... but they were away from home!"))
				} else {
					if Double.random(in: 0...1) > werewolfKillSuccessRate {
						_ = try await thread?.send(EmbedBuilder.bad.setDescription(description: "... and succeed!"))
						try await kill(who, because: .werewolf)
					} else {
						_ = try await thread?.send(EmbedBuilder.bad.setDescription(description: "... and fail!"))
					}
				}
			case .giveCookies(let who):
				if roles[who] == .werewolf {
					_ = try await thread?.send(EmbedBuilder.bad.setDescription(description: "<@\(action.key)> decided to give cookies to a Werewolf, uh-oh..."))
					try await Task.sleep(nanoseconds: 3_000_000_000)
					if actions.contains(where: { $0.value == .protect(who: action.key)}) {
						_ = try await thread?.send(EmbedBuilder.good.setDescription(description: "<@\(action.key)> was protected by a Guardian Angel!"))
					} else {
						_ = try await thread?.send(EmbedBuilder.bad.setDescription(description: "<@\(action.key)> got eaten!"))

						try await kill(action.key, because: .werewolf)
					}
					break
				}
				if actions.contains(where: { $0.value == .kill(who: who) }) {
					_ = try await thread?.send(EmbedBuilder.bad.setDescription(description: "<@\(action.key)> was visiting <@\(who)>, but unfortunately, the werewolves were visiting them too!"))
					try await Task.sleep(nanoseconds: 3_000_000_000)
					if actions.contains(where: { $0.value == .protect(who: action.key)}) {
						_ = try await thread?.send(EmbedBuilder.good.setDescription(description: "The werewolves were going to have a bonus snack, but <@\(action.key)> was protected by a Guardian Angel!"))
					} else {
						_ = try await thread?.send(EmbedBuilder.bad.setDescription(description: "The werewolves had a tasty bonus snack! <@\(action.key)> got eaten by the werewolves!"))
						try await kill(action.key, because: .werewolf)
					}
					break
				}
			case .protect(_), .freeze(_):
				continue
			}
			try await Task.sleep(nanoseconds: 2_000_000_000)
		}
		actions = [:]
	}

	func checkWin() async throws {
		let aliveEvil = roles.filter { roles[$0.key] == .werewolf }
			.filter { alive[$0.key] == true }
		let aliveNotEvil = roles.filter { roles[$0.key] != .werewolf }
			.filter { alive[$0.key] == true }

		if aliveEvil.count == 0 {
			_ = try await thread?.send(EmbedBuilder.good.setTitle(title: "The villagers win!"))
			state = .waiting
		} else if aliveEvil.count >= aliveNotEvil.count {
			_ = try await thread?.send(EmbedBuilder.bad.setTitle(title: "The werewolves win!"))
			state = .waiting
		}

		if state == .waiting {
			let txt = users.values
				.map { item -> String in
					let role = roles[item.id]!
					let alive = alive[item.id]! ? ":white_check_mark:" : ":x:"
					return "\(alive) <@\(item.id)> (was a \(role.roleName))"
				}
				.joined(separator: "\n")
			_ = try await thread?.send(EmbedBuilder.info.setTitle(title: "Players").setDescription(description: txt))
			clear()
		}
	}
}

// channel -> state
var states: [Snowflake: State] = [:]

extension Message {
	var state: State {
		if !states.keys.contains(self.channel.id) {
			states[self.channel.id] = State(for: self.channel)
		}

		return states[self.channel.id]!
	}
}

extension SlashCommandEvent {
	func ensureState() async throws {
		if !states.keys.contains(self.channelId) {
			let chan = try await bot.getChannel(self.channelId)
			states[self.channelId] = State(for: chan as! GuildText)
		}
	}
	var state: State {

		return states[self.self.channelId]!
	}
}

extension EmbedBuilder {
	static var good: EmbedBuilder {
		EmbedBuilder()
			.setColor(color: 0x11FF11)
	}
	static var bad: EmbedBuilder {
		EmbedBuilder()
			.setColor(color: 0xFF0000)
	}
	static var info: EmbedBuilder {
		EmbedBuilder()
			.setColor(color: 0x3DAEE9)
	}
}

let commands = [
	try! SlashCommandBuilder(name: "join", description: "Join a lobby"),
	try! SlashCommandBuilder(name: "leave", description: "Leave a lobby"),
	try! SlashCommandBuilder(name: "party", description: "View the current party"),
	try! SlashCommandBuilder(name: "setup", description: "Set up a game, making it ready to play"),
	try! SlashCommandBuilder(name: "unsetup", description: "Un-set up a game, making it not ready to play, allowing people to leave"),
	try! SlashCommandBuilder(name: "start", description: "Start a game"),
]

class MyBot: ListenerAdapter {
	func slashCommandEvent(event: SlashCommandEvent) async throws {
		try await event.ensureState()

		let author = event.user

		switch event.name {
		case "join":
			guard !currentlyIn.keys.contains(author.id) else {
				_ = try await event.reply(message: "You can't join this game, because you're already playing a game in <#\(currentlyIn[author.id]!.channel.id)>!")
				return
			}
			guard event.state.state == .waiting || event.state.state == .assigned else {
				_ = try await event.reply(message: "A game is in progress! Try joining again, when it's over.")
				return
			}
			event.state.party.insert(author.id)
			event.state.users[author.id] = author
			currentlyIn[author.id] = event.state
			_ = try await event.replyEmbeds(embeds:
				EmbedBuilder.good
					.setTitle(title: "You have joined the party!")
			)
			if event.state.state == .assigned {
				event.state.state = .waiting
				_ = try await event.reply(message: "You need to m!setup again, since a new player joined!")
			}
		case "leave":
			guard event.state.state == .waiting else {
				_ = try await event.reply(message: "You can't leave an in-progress game!")
				return
			}
			event.state.party.remove(author.id)
			event.state.users.removeValue(forKey: author.id)
			currentlyIn.removeValue(forKey: author.id)
			_ = try await event.replyEmbeds(embeds:
				EmbedBuilder.good
					.setTitle(title: "You have left the party!")
			)
		case "party":
			_ = try await event.replyEmbeds(embeds:
				EmbedBuilder.info
					.setTitle(title: "Your Party")
					.setDescription(description: event.state.party.map { "<@\($0)>" }.joined(separator: "\n"))
			)
		case "setup":
			guard event.state.state == .waiting || event.state.state == .assigned else {
				_ = try await event.reply(message: "A game is already in progress!")
				return
			}
			guard event.state.party.count >= 4 else {
				_ = try await event.reply(message: "You need at least 4 people to start playing!")
				return
			}
			try await event.state.assignRoles()
			_ = try await event.replyEmbeds(embeds:
				EmbedBuilder.info
					.setTitle(title: "You're all set to go! Do !start to begin playing!")
			)
		case "unsetup":
			guard event.state.state == .assigned else {
				_ = try await event.reply(message: "The lobby isn't in the right state for that!")
				return
			}

			event.state.state = .waiting
			_ = try await event.replyEmbeds(embeds:
				EmbedBuilder.info
					.setTitle(title: "The game has been un set up!")
			)
		case "start":
			guard event.state.state != .playing else {
				_ = try await event.reply(message: "A game is already in progress!")
				return
			}
			guard event.state.state == .assigned else {
				_ = try await event.reply(message: "You need to !setup before you can !start")
				return
			}
			try await event.state.startPlaying()
		default:
			return
		}
	}
	override func onSlashCommandEvent(event: SlashCommandEvent) async {
		do {
			try await slashCommandEvent(event: event)
		} catch {
			guard let channel = try? await bot.getChannel(event.channelId) as? TextChannel else {
				print("error! \(error)")
				return
			}
			_ = try? await channel.send("Oops, I had an error: \(error)")
		}
	}
	func selectMenuEvent(event: SelectMenuEvent) async throws {
		guard let targ = UInt64(event.selectedValue.value) else {
			try await event.reply(message: "Oops, I didn't understand your target, sorry.")
			return
		}
		let target = Snowflake(targ)
		guard let state = currentlyIn[event.user.id] else {
			try await event.reply(message: "Oops, it doesn't look like you're in a game...")
			return
		}
		guard state.users.contains(where: { $0.key == target }) else {
			try await event.reply(message: "Oops, it doesn't look like your target is in the game...")
			return
		}
		switch event.selectedValue.customId {
		case "werewolf-kill":
			guard state.roles[event.user.id] == .werewolf else {
				try await event.reply(message: "You aren't werewolf!")
				return
			}
			if state.timeOfYear == .earlyWinter || state.timeOfYear == .lateWinter {
				try await event.reply(message: "You're going to freeze <@\(event.selectedValue.value)> tonight!")
				state.actions[event.user.id] = .freeze(who: target)
			} else {
				try await event.reply(message: "You're going to kill <@\(event.selectedValue.value)> tonight!")
				state.actions[event.user.id] = .kill(who: target)
			}
		case "guardianAngel-protect":
			guard state.roles[event.user.id] == .guardianAngel else {
				try await event.reply(message: "You aren't guardianAngel!")
				return
			}
			try await event.reply(message: "You're going to protect <@\(event.selectedValue.value)> tonight!")
			state.actions[event.user.id] = .protect(who: target)
		case "seer-investigate":
			guard state.roles[event.user.id] == .seer else {
				try await event.reply(message: "You aren't seer!")
				return
			}
			try await event.reply(message: "You're going to investigate <@\(event.selectedValue.value)> tonight!")
			state.actions[event.user.id] = .check(who: target)
		case "cookies-give":
			guard state.roles[event.user.id] == .cookiePerson else {
				try await event.reply(message: "You aren't a cookie person!")
				return
			}
			try await event.reply(message: "You're going to give cookies to <@\(event.selectedValue.value)> tonight!")
			state.actions[event.user.id] = .giveCookies(to: target)
		case "vote":
			guard state.alive[event.user.id] == true else {
				event.setEphemeral(true)
				try await event.reply(message: "You aren't alive to vote!")
				return
			}
			guard event.user.id != target else {
				event.setEphemeral(true)
				try await event.reply(message: "You can't vote for yourself!")
				return
			}
			if state.votes.keys.contains(event.user.id) {
				_ = try await state.thread?.send("<@\(event.user.id)> has decided to to exile <@\(target)> instead!")
			} else {
				_ = try await state.thread?.send("<@\(event.user.id)> has voted to exile <@\(target)>!")
			}
			state.votes[event.user.id] = target
		default:
			try await event.reply(message: "Oops, I don't understand what you just did. Sorry.")
		}
	}
	override func onSelectMenuEvent(event: SelectMenuEvent) async {
		do {
			try await selectMenuEvent(event: event)
		} catch {
			_ = try? await event.reply(message: "Oops, I had an error: \(error)")
		}
	}
}

let evGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)

let bot = Swiftcord(token: config.token, eventLoopGroup: evGroup)

bot.setIntents(intents: .guildMessages)
bot.addListeners(MyBot())

bot.connect()
