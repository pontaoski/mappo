import NIO
import NIOCore
import Foundation
import AsyncKit
import MappoCore
import AsyncHTTPClient
import DiscordBM

extension CommunicationEmbed {
	var discord: Embed {
		switch self.color {
		case .bad:
			return .init(title: self.title, description: self.body, color: 0xFF0000, fields: self.fields.map { .init(name: $0.title, value: $0.body, inline: true)})
		case .good:
			return .init(title: self.title, description: self.body, color: 0x11FF11, fields: self.fields.map { .init(name: $0.title, value: $0.body, inline: true)})
		case .info:
			return .init(title: self.title, description: self.body, color: 0x3DAEE9, fields: self.fields.map { .init(name: $0.title, value: $0.body, inline: true)})
		}
	}
}

class DiscordMessage: Deletable {
	let client: any DiscordClient
	let channelID: ChannelSnowflake
	let messageID: MessageSnowflake

	init(client: any DiscordClient, channelID: ChannelSnowflake, messageID: MessageSnowflake) {
		self.client = client
		self.channelID = channelID
		self.messageID = messageID
	}
    func delete() async throws {
		_ = try await client.deleteMessage(channelId: channelID, messageId: messageID)
    }
}

struct GuildKey: Hashable {
	let guild: GuildSnowflake
	let subkey: UserSnowflake
}

extension UserSnowflake: Mentionable {
	public func mention() -> String {
		"<@\(self.rawValue)>"
	}
}

class CustomCache {
	var members: [GuildKey: Guild.Member] = [:]
}

class DiscordChannel: Sendable, I18nable {
	typealias Message = DiscordMessage
	typealias UserID = UserSnowflake
	let client: any DiscordClient
	let cache: DiscordCache
	let ccache: CustomCache
	let guildID: GuildSnowflake
	let channelID: ChannelSnowflake

	init(client: any DiscordClient, cache: DiscordCache, ccache: CustomCache, guildID: GuildSnowflake, channelID: ChannelSnowflake) {
		self.client = client
		self.cache = cache
		self.ccache = ccache
		self.guildID = guildID
		self.channelID = channelID
	}
	func i18n() -> I18n {
		if channelID == "1046573727732748359" || channelID == "1014242493056962570" {
			return TokiPona()
		}
		return English()
	}
	func send(_ text: String) async throws -> Message {
		let it = try await client.createMessage(channelId: channelID, payload: .init(content: text))
		let msg = try it.decode()
		return Message(client: client, channelID: channelID, messageID: msg.id)
	}
	func send(_ embed: CommunicationEmbed) async throws -> Message {
		let it = try await client.createMessage(channelId: channelID, payload: .init(embeds: [embed.discord]))
		let msg = try it.decode()
		return Message(client: client, channelID: channelID, messageID: msg.id)
	}
	func send(_ embed: CommunicationEmbed, _ buttons: [CommunicationButton]) async throws -> Message {
		let it = try await client.createMessage(channelId: channelID, payload: .init(embeds: [embed.discord], components: [.init(components: buttons.map(convertButton))]))
		let msg = try it.decode()
		return Message(client: client, channelID: channelID, messageID: msg.id)
	}
	private func convertButton(_ btn: CommunicationButton) -> Interaction.ActionRow.Component {
		let style: Interaction.ActionRow.Button.NonLinkStyle
		switch btn.color {
		case .bad:
			style = .danger
		case .good:
			style = .success
		case .bright:
			style = .primary
		case .neutral:
			style = .secondary
		}
		return .button(.init(style: style, label: btn.label, custom_id: btn.id.rawValue))
	}
	func send(_ buttons: [CommunicationButton]) async throws -> Message {
		let it = try await client.createMessage(
			channelId: channelID,
			payload: .init(
				components: [.init(components: buttons.map(convertButton))]
			)
		)
		let msg = try it.decode()
		return Message(client: client, channelID: channelID, messageID: msg.id)
	}
	func send(userSelection options: [UserID], id: SingleUserSelectionID, label: String, buttons: [CommunicationButton]) async throws -> Message {
		return try await sendInner(options: options, id: id.rawValue, label: label, buttons: buttons, multi: false)
	}
	func send(multiUserSelection options: [UserID], id: MultiUserSelectionID, label: String, buttons: [CommunicationButton]) async throws -> Message {
		return try await sendInner(options: options, id: id.rawValue, label: label, buttons: buttons, multi: true)
	}
	func sendInner(options: [UserID], id: String, label: String, buttons: [CommunicationButton], multi: Bool) async throws -> Message {
		var doptions: [(UserID, String)] = []
		for opt in options {
			if
				let member = await cache.guilds[guildID]?.member(withUserId: opt) ?? ccache.members[.init(guild: guildID, subkey: opt)],
				let nick = member.nick ?? member.user?.username
			{
				doptions.append((opt, nick))
				continue
			}
			guard let member = try? await client.getGuildMember(guildId: guildID, userId: opt).decode() else {
				doptions.append((opt, "Unknown user"))
				continue
			}
			ccache.members[.init(guild: guildID, subkey: opt)] = member
			guard let nick = member.nick ?? member.user?.username else {
				doptions.append((opt, "Unknown user"))
				continue
			}

			doptions.append((opt, nick))
		}
		let maxValues: Int?
		if multi {
			maxValues = doptions.count
		} else {
			maxValues = nil
		}
		let it = try await client.createMessage(
			channelId: channelID,
			payload: .init(
				content: label,
				components: [.init(components: [.stringSelect(.init(custom_id: id, options: doptions.map { (id, name) in
					return .init(label: name, value: id.rawValue)
				}, max_values: maxValues))]), .init(components: buttons.map(convertButton))].filter{$0.components.count > 0}
			)
		)
		let msg = try it.decode()
		return Message(client: client, channelID: channelID, messageID: msg.id)
	}
	func send(textSelection options: [(String, String)], id: TextSelectionID, label: String, buttons: [CommunicationButton]) async throws -> Message {
		let it = try await client.createMessage(
			channelId: channelID,
			payload: .init(
				content: label,
				components: [.init(components: [.stringSelect(.init(custom_id: id.rawValue, options: options.map { (name, id) in
					return .init(label: name, value: id)
				}, max_values: 1))]), .init(components: buttons.map(convertButton))].filter{$0.components.count > 0}
			)
		)
		let msg = try it.decode()
		return Message(client: client, channelID: channelID, messageID: msg.id)
	}
}

class DiscordInteraction: Replyable {
	let client: any DiscordClient
	let event: Interaction

	init(client: any DiscordClient, interaction: Interaction) {
		self.client = client
		self.event = interaction
	}
	func reply(with: String, epheremal: Bool) async throws {
		_ = try await client.createInteractionResponse(
			id: event.id,
			token: event.token,
			payload: .channelMessageWithSource(.init(content: with, flags: epheremal ? [.ephemeral] : []))
		)
	}
	func reply(with embed: CommunicationEmbed, epheremal: Bool) async throws {
		_ = try await client.createInteractionResponse(
			id: event.id,
			token: event.token,
			payload: .channelMessageWithSource(.init(embeds: [embed.discord], flags: epheremal ? [.ephemeral] : []))
		)
	}
}

final class DiscordCommunication: Communication {
	typealias Channel = DiscordChannel
	typealias Message = DiscordMessage
	typealias UserID = UserSnowflake
	typealias Interaction = DiscordInteraction

	let client: any DiscordClient
	let cache: DiscordCache
	let ccache: CustomCache
	let gs: GlobalState
	init(client: any DiscordClient, cache: DiscordCache, ccache: CustomCache, state: GlobalState) {
		self.client = client
		self.cache = cache
		self.ccache = ccache
		self.gs = state
	}

	func getChannel(for user: UserID, state: DiscordState) async throws -> Channel? {
		let resp = try await client.createDm(payload: .init(recipient_id: user))
		let chan = try resp.decode()
		return DiscordChannel(client: client, cache: cache, ccache: ccache, guildID: state.channel.guildID, channelID: chan.id)
	}
	func createGameThread(state: DiscordState) async throws -> Channel? {
		let thread = try await client.createThread(channelId: state.channel.channelID, payload: .init(name: "Mappo", type: .privateThread))
		let threadO = try thread.decode()
		return DiscordChannel(client: client, cache: cache, ccache: ccache, guildID: threadO.guild_id!, channelID: threadO.id)
	}
	func archive(_ id: Channel, state: DiscordState) async throws {
		_ = try await client.updateThreadChannel(id: id.channelID, reason: nil, payload: .init(archived: true, locked: true))
	}
	func currentParty(of user: UserID, state: DiscordState) async throws -> DiscordState? {
		return gs.userStates[user]
	}
	func onPrepareJoined(_ user: UserID, state: DiscordState) async throws {
		gs.userStates[user] = state
	}
	func onJoined(_ user: UserID, state: DiscordState) async throws {
		gs.userStates[user] = state
	}
	func onLeft(_ user: UserID, state: DiscordState) async throws {
		gs.userStates.removeValue(forKey: user)
	}
}

typealias DiscordState = State<DiscordCommunication>

struct Config: Codable {
	var token: String
	var appID: String
}

extension Collection where Self.Element: Comparable {
	func except(_ item: Self.Element) -> [Self.Element] {
		self.filter({ $0 != item })
	}
}

class GlobalState {
	var channelStates: [ChannelSnowflake: DiscordState] = [:]
	var userStates: [UserSnowflake: DiscordState] = [:]
}

// let commands = [
// 	try! SlashCommandBuilder(name: "join", description: "Join a lobby"),
// 	try! SlashCommandBuilder(name: "leave", description: "Leave a lobby"),
// 	try! SlashCommandBuilder(name: "party", description: "View the current party"),
// 	try! SlashCommandBuilder(name: "setup", description: "Set up a game, making it ready to play"),
// 	try! SlashCommandBuilder(name: "unsetup", description: "Un-set up a game, making it not ready to play, allowing people to leave"),
// 	try! SlashCommandBuilder(name: "start", description: "Start a game"),
// ]

struct NotFound: Error {}

class MyBot {
	let gs: GlobalState
	let client: any DiscordClient
	let cache: DiscordCache
	let ccache: CustomCache
	let comm: DiscordCommunication
	let ev: any EventLoop
	init(client: any DiscordClient, cache: DiscordCache, ev: any EventLoop) {
		self.gs = GlobalState()
		self.ccache = CustomCache()
		self.client = client
		self.cache = cache
		self.comm = DiscordCommunication(client: client, cache: cache, ccache: ccache, state: self.gs)
		self.ev = ev
	}
	func state(for channel: ChannelSnowflake) async throws -> DiscordState {
		if let chan = gs.channelStates[channel] {
			return chan
		}

		let chan = try await client.getChannel(id: channel)
		let chann = try chan.decode()
		guard let gid = chann.guild_id else {
			throw NotFound()
		}
		self.gs.channelStates[channel] = DiscordState(for: DiscordChannel(client: client, cache: cache, ccache: ccache, guildID: gid, channelID: channel), in: comm, eventLoop: ev)
		return self.gs.channelStates[channel]!
	}
	func dispatch(ev: Gateway.Event) async throws {
		guard case .interactionCreate(let woot) = ev.data else {
			return
		}
		guard let ev = woot.data else {
			return
		}
		guard let user = woot.member?.user ?? woot.user else {
			return
		}
		// _ = try await client.createInteractionResponse(
		// 	id: woot.id,
		// 	token: woot.token,
		// 	payload: .init(type: .deferredChannelMessageWithSource)
		// )
		let intr = DiscordInteraction(client: client, interaction: woot)
		do {
			switch ev {
			case .applicationCommand(let data):
				try await slashCommandEvent(cmd: data.name, user: user, opts: data.options, intr: intr)
			case .messageComponent(let data):
				switch data.component_type {
				case .stringSelect:
					guard let values = data.values, let value = values.first else {
						return
					}
					try await selectMenuEvent(id: data.custom_id, target: value, targets: values, user: user, intr: intr)
				case .button:
					try await buttonClickEvent(btn: data.custom_id, user: user, intr: intr)
				default:
					()
				}
			default:
				()
			}
		} catch {
			print("Error in dispatching: \(error)")
			_ = try await client.createMessage(channelId: intr.event.channel_id!, payload: .init(content: "I had an error: \(error)"))
		}
	}
	func slashCommandEvent(cmd: String, user: DiscordUser, opts: [Interaction.ApplicationCommand.Option]?, intr: DiscordInteraction) async throws {
		let state = try await self.state(for: intr.event.channel_id!)

		if let command = state.arglessCommands[cmd] {
			try await command(state)(user.id, intr)
		} else if let command = state.stringCommands[cmd] {
			guard let opt = opts, let first = opt.first, let val = first.value?.asString else {
				try await intr.reply(with: "Oops, I had an error (Discord didn't send me an option...?)", epheremal: true)
				return
			}
			try await command(state)(user.id, val, intr)
		} else if let command = state.userCommands[cmd] {
			guard let opt = opts, let first = opt.first, let val = first.value?.asString else {
				try await intr.reply(with: "Oops, I had an error (Discord didn't send me an option...?)", epheremal: true)
				return
			}
			try await command(state)(user.id, UserSnowflake(val), intr)
		} else {
			try await intr.reply(with: "Oops, I don't understand what you just did (\(cmd)). Sorry.", epheremal: true)
		}
	}
	func selectMenuEvent(id: String, target: String, targets: [String], user: DiscordUser, intr: DiscordInteraction) async throws {
		let userTarget = UserSnowflake(target)
		let userTargets = targets.map{UserSnowflake($0)}
		guard let state = gs.userStates[user.id] else {
			try await intr.reply(with: "Oops, it doesnt look like you're in a game, sorry.", epheremal: true)
			return
		}

		if let susID = SingleUserSelectionID.init(rawValue: id),
			let dropdown = state.singleUserDropdowns[susID] {
			try await dropdown(state)(user.id, userTarget, intr)
		} else if let musID = MultiUserSelectionID.init(rawValue: id),
			let dropdown = state.multiUserDropdowns[musID] {

			try await dropdown(state)(user.id, userTargets, intr)
		} else if let texID = TextSelectionID(rawValue: id),
			let dropdown = state.textDropdowns[texID] {

			try await dropdown(state)(user.id, target, intr)
		} else {
			try await intr.reply(with: "Oops, I don't understand what you just did (\(id)). Sorry.", epheremal: true)
		}
	}
	func buttonClickEvent(btn: String, user: DiscordUser, intr: DiscordInteraction) async throws {
		let channel = try await self.state(for: intr.event.channel_id!)
		let state = gs.userStates[user.id] ?? channel
		// guard  else {
		// 	try await intr.reply(with: "Oops, it doesnt look like you're in a game, sorry.", epheremal: true)
		// 	return
		// }

		if let buttonID = ButtonID(rawValue: btn),
			let button = state.buttons[buttonID] {
			try await button(state)(user.id, intr)
		} else {
			try await intr.reply(with: "Oops, I don't understand what you just did (\(btn)). Sorry.", epheremal: true)
		}
	}
}

@main
struct MappoMain {
	static func actualMain(client httpClient: HTTPClient) async {
		let config = try! JSONDecoder().decode(Config.self,  from: try! String(contentsOfFile: "config.json").data(using: .utf8)!)

		let bot = await BotGatewayManager(
			eventLoopGroup: httpClient.eventLoopGroup,
			httpClient: httpClient,
			token: config.token,
			appId: ApplicationSnowflake(config.appID),
			intents: [.guildMessages, .guildMembers, .messageContent]
		)
		let cache = await DiscordCache(
			gatewayManager: bot,
			intents: [.guildMembers],
			requestAllMembers: .enabled
		)
		let mappoBot = MyBot(client: bot.client, cache: cache, ev: httpClient.eventLoopGroup.next())

		await bot.connect()

		let stream = await bot.makeEventsStream()
		for await event in stream {
			let _ = httpClient.eventLoopGroup.makeFutureWithTask {
				do {
					try await mappoBot.dispatch(ev: event)
				} catch {
					print(error)
				}
			}
		}
	}
	static func main() {
		let httpClient = HTTPClient(eventLoopGroupProvider: .createNew)
		try! httpClient.eventLoopGroup.makeFutureWithTask {
			await actualMain(client: httpClient)
		}.wait()
		RunLoop.current.run()
	}
}

