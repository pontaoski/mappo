import Swiftcord
import NIO
import NIOCore
import Foundation
import AsyncKit
import MappoCore

typealias SwiftcordMessage = Message
typealias SwiftcordChannel = TextChannel

extension SwiftcordMessage: Deletable {
}

extension CommunicationEmbed {
	var discord: EmbedBuilder {
		switch self.color {
		case .bad:
			return EmbedBuilder.bad.setTitle(title: self.title).setDescription(description: self.body)
		case .good:
			return EmbedBuilder.good.setTitle(title: self.title).setDescription(description: self.body)
		case .info:
			return EmbedBuilder.info.setTitle(title: self.title).setDescription(description: self.body)
		}
	}
}

class DiscordChannel: Sendable {
	typealias Message = SwiftcordMessage
	typealias UserID = Snowflake
	let channel: TextChannel

	init(channel: TextChannel) {
		self.channel = channel
	}
	func send(_ text: String) async throws -> Message {
		try await channel.send(text)!
	}
	func send(_ embed: CommunicationEmbed) async throws -> Message {
		return try await channel.send(embed.discord)!
	}
	func send(_ buttons: [CommunicationButton]) async throws -> Message {
		typealias From = (Button...) -> ActionRow<Button>
		typealias To = ([Button]) -> ActionRow<Button>

		let it = unsafeBitCast(ActionRow<Button>.init, to: To.self)

		let builder = ButtonBuilder().addComponent(component: it(buttons.map {
			let style: ButtonStyles
			switch $0.color {
			case .bad:
				style = .red
			case .good:
				style = .green
			case .bright:
				style = .blurple
			case .neutral:
				style = .grey
			}
			return Button(customId: $0.id, style: style, label: $0.label)
		}))

		return try await channel.send(builder)!
	}
	func send(userSelection options: [UserID], id: String, label: String) async throws -> Message {
		typealias From = (String, String?, SelectMenuOptions...) -> SelectMenu
		typealias To = (String, String?, [SelectMenuOptions]) -> SelectMenu

		let it = unsafeBitCast(SelectMenu.init, to: To.self)

		var doptions: [(UserID, String)] = []
		for opt in options {
			let user = try await bot.getUser(opt)
			if let guildText = channel as? GuildText, let guild = guildText.guild, let username = user.username {
				let member = try await bot.getMember(opt, from: guild.id)
				doptions.append((opt, member.nick ?? username))
			} else if let username = user.username {
				doptions.append((opt, username))
			} else {
				doptions.append((opt, "Unknown User"))
			}
		}

		let actionRow = ActionRow(components: it(id, nil, doptions.map { SelectMenuOptions(label: $0.1, value: "\($0.0)") }))
		return try await channel.send(SelectMenuBuilder(message: label).addComponent(component: actionRow))!
	}
}

class DiscordInteraction: Replyable {
	let event: InteractionEvent

	init(interaction: InteractionEvent) {
		self.event = interaction
	}
	func reply(with: String, epheremal: Bool) async throws {
		event.setEphemeral(epheremal)
		return try await event.reply(message: with)
	}
	func reply(with embed: CommunicationEmbed, epheremal: Bool) async throws {
		event.setEphemeral(epheremal)
		return try await event.replyEmbeds(embeds: embed.discord)
	}
}

final class DiscordCommunication: Communication {
	typealias Channel = DiscordChannel
	typealias Message = SwiftcordMessage
	typealias UserID = Snowflake
	typealias Interaction = DiscordInteraction

	func getChannel(for user: UserID, state: DiscordState) async throws -> Channel? {
		guard let dm = try await bot.getDM(for: user) else {
			return nil
		}
		return DiscordChannel(channel: dm)
	}
	func createGameThread(state: DiscordState) async throws -> Channel? {
		let thread = try await bot.createThread(in: state.channel.channel.id, StartThreadData(name: "Mappo Game"))
		return DiscordChannel(channel: thread)
	}
	func archive(_ id: Channel, state: DiscordState) async throws {
		_ = try await bot.modifyChannel(id.channel.id, with: ["archived": true, "locked": true])
	}
	func onJoined(_ user: UserID, state: DiscordState) async throws {
		states[user] = state
	}
	func onLeft(_ user: UserID, state: DiscordState) async throws {
		states.removeValue(forKey: user)
	}
}

typealias DiscordState = State<DiscordCommunication>

struct Config: Codable {
	var token: String
}

let config = try! JSONDecoder().decode(Config.self,  from: try! String(contentsOfFile: "config.json").data(using: .utf8)!)

extension Collection where Self.Element: Comparable {
	func except(_ item: Self.Element) -> [Self.Element] {
		self.filter({ $0 != item })
	}
}

// user -> state
var states: [Snowflake: DiscordState] = [:]

var comm: DiscordCommunication = DiscordCommunication()

extension Message {
	var state: DiscordState {
		if !states.keys.contains(self.channel.id) {
			states[self.channel.id] = DiscordState(for: DiscordChannel(channel: self.channel), in: comm, eventLoop: evGroup.next())
		}

		return states[self.channel.id]!
	}
}

extension SlashCommandEvent {
	func ensureState() async throws {
		if !states.keys.contains(self.channelId) {
			let chan = try await bot.getChannel(self.channelId)
			states[self.channelId] = DiscordState(for: DiscordChannel(channel: chan as! TextChannel), in: comm, eventLoop: evGroup.next())
		}
	}
	var state: DiscordState {
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
			try await event.state.join(who: author.id, interaction: DiscordInteraction(interaction: event))
		case "leave":
			try await event.state.leave(who: author.id, interaction: DiscordInteraction(interaction: event))
		case "party":
			try await event.state.party(who: author.id, interaction: DiscordInteraction(interaction: event))
		case "setup":
			try await event.state.setup(who: author.id, interaction: DiscordInteraction(interaction: event))
		case "unsetup":
			try await event.state.unsetup(who: author.id, interaction: DiscordInteraction(interaction: event))
		case "start":
			try await event.state.start(who: author.id, interaction: DiscordInteraction(interaction: event))
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
			event.setEphemeral(true)
			try await event.reply(message: "Oops, I didn't understand your target, sorry.")
			return
		}
		let target = Snowflake(targ)
		guard let state = states[event.user.id] else {
			event.setEphemeral(true)
			try await event.reply(message: "Oops, it doesn't look like you're in a game...")
			return
		}

		switch event.selectedValue.customId {
		case "werewolf-kill":
			try await state.werewolfKill(who: event.user.id, target: target, interaction: DiscordInteraction(interaction: event))
		case "guardianAngel-protect":
			try await state.guardianAngelProtect(who: event.user.id, target: target, interaction: DiscordInteraction(interaction: event))
		case "seer-investigate":
			try await state.seerInvestigate(who: event.user.id, target: target, interaction: DiscordInteraction(interaction: event))
		case "cookies-give":
			try await state.cookiesGive(who: event.user.id, target: target, interaction: DiscordInteraction(interaction: event))
		case "nominate":
			try await state.nominate(who: event.user.id, target: target, interaction: DiscordInteraction(interaction: event))
		case "goose":
			try await state.goose(who: event.user.id, target: target, interaction: DiscordInteraction(interaction: event))
		default:
			event.setEphemeral(true)
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
	func buttonClickEvent(event: ButtonEvent) async throws {
		guard let state = states[event.user.id] else {
			event.setEphemeral(true)
			try await event.reply(message: "Oops, it doesn't look like you're in a game...")
			return
		}

		switch event.selectedButton.customId {
		case "nominate-yes":
			try await state.nominateYes(who: event.user.id, interaction: DiscordInteraction(interaction: event))
		case "nominate-no":
			try await state.nominateNo(who: event.user.id, interaction: DiscordInteraction(interaction: event))
		case "vote-yes":
			try await state.voteYes(who: event.user.id, interaction: DiscordInteraction(interaction: event))
		case "vote-no":
			try await state.voteNo(who: event.user.id, interaction: DiscordInteraction(interaction: event))
		default:
			_ = try? await event.reply(message: "Oops, I don't understand which button you pressed...")
		}
	}
	override func onButtonClickEvent(event: ButtonEvent) async {
		do {
			try await buttonClickEvent(event: event)
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
