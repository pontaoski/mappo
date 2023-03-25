import NIO
import NIOCore
import Foundation
import AsyncKit
import MappoCore
import AsyncHTTPClient
import DiscordBM

typealias Snowflake = String

extension CommunicationEmbed {
	var discord: Embed {
		switch self.color {
		case .bad:
			return .init(title: self.title, description: self.body, color: 0xFF0000)
		case .good:
			return .init(title: self.title, description: self.body, color: 0x11FF11)
		case .info:
			return .init(title: self.title, description: self.body, color: 0x3DAEE9)
		}
	}
}

class DiscordMessage: Deletable {
	let client: any DiscordClient
	let channelID: Snowflake
	let messageID: Snowflake

	init(client: DiscordClient, channelID: Snowflake, messageID: Snowflake) {
		self.client = client
		self.channelID = channelID
		self.messageID = messageID
	}
    func delete() async throws {
		_ = try await client.deleteMessage(channelId: channelID, messageId: messageID)
    }
}

class DiscordChannel: Sendable, I18nable {
	typealias Message = DiscordMessage
	typealias UserID = Snowflake
	let client: any DiscordClient
	let cache: DiscordCache
	let guildID: Snowflake
	let channelID: Snowflake

	init(client: any DiscordClient, cache: DiscordCache, guildID: Snowflake, channelID: Snowflake) {
		self.client = client
		self.cache = cache
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
	func send(_ buttons: [CommunicationButton]) async throws -> Message {
		let it = try await client.createMessage(
			channelId: channelID,
			payload: .init(
				components: [.init(components: buttons.map { btn in
					let style: Interaction.ActionRow.Button.Style
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
					return .button(.init(style: style, label: btn.label, custom_id: btn.id))
				})]
			)
		)
		let msg = try it.decode()
		return Message(client: client, channelID: channelID, messageID: msg.id)
	}
	func send(userSelection options: [UserID], id: String, label: String) async throws -> Message {
		var doptions: [(UserID, String)] = []
		for opt in options {
			if let member = await cache.guilds[guildID]?.member(withUserId: opt), let nick = member.nick ?? member.user?.username {
				doptions.append((opt, nick))
			} else if
				let member = try? await client.getGuildMember(guildId: guildID, userId: opt).decode(),
				let nick = member.nick ?? member.user?.username {

				doptions.append((opt, nick))
			} else {
				doptions.append((opt, "Unknown user"))
			}
		}
		let it = try await client.createMessage(
			channelId: channelID,
			payload: .init(
				components: [.init(components: [.stringSelect(.init(custom_id: id, options: doptions.map { (id, name) in
					return .init(label: name, value: id)
				}))])]
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
			payload: .init(type: .channelMessageWithSource, data: .init(content: with, flags: epheremal ? [.ephemeral] : []))
		)
	}
	func reply(with embed: CommunicationEmbed, epheremal: Bool) async throws {
		_ = try await client.createInteractionResponse(
			id: event.id,
			token: event.token,
			payload: .init(type: .channelMessageWithSource, data: .init(embeds: [embed.discord], flags: epheremal ? [.ephemeral] : []))
		)
	}
}

final class DiscordCommunication: Communication {
	typealias Channel = DiscordChannel
	typealias Message = DiscordMessage
	typealias UserID = Snowflake
	typealias Interaction = DiscordInteraction

	let client: any DiscordClient
	let cache: DiscordCache
	let gs: GlobalState
	init(client: any DiscordClient, cache: DiscordCache, state: GlobalState) {
		self.client = client
		self.cache = cache
		self.gs = state
	}

	func getChannel(for user: UserID, state: DiscordState) async throws -> Channel? {
		let resp = try await client.createDM(recipient_id: user)
		let chan = try resp.decode()
		return DiscordChannel(client: client, cache: cache, guildID: state.channel.guildID, channelID: chan.id)
	}
	func createGameThread(state: DiscordState) async throws -> Channel? {
		let thread = try await client.createThread(in: state.channel.channelID, "Mappo Game", type: nil, invitable: nil, archiveAfter: nil, rateLimitPerUser: nil)
		let threadO = try thread.decode()
		return DiscordChannel(client: client, cache: cache, guildID: threadO.guild_id!, channelID: threadO.id)
	}
	func archive(_ id: Channel, state: DiscordState) async throws {
		// _ = try await bot.modifyChannel(id.channel.id, with: ["archived": true, "locked": true])
	}
	func onJoined(_ user: UserID, state: DiscordState) async throws {
		gs.states[user] = state
	}
	func onLeft(_ user: UserID, state: DiscordState) async throws {
		gs.states.removeValue(forKey: user)
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
	var states: [Snowflake: DiscordState] = [:]
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
	let comm: DiscordCommunication
	let ev: any EventLoop
	init(client: any DiscordClient, cache: DiscordCache, ev: any EventLoop) {
		self.gs = GlobalState()
		self.client = client
		self.cache = cache
		self.comm = DiscordCommunication(client: client, cache: cache, state: self.gs)
		self.ev = ev
	}
	func state(for channel: Snowflake) async throws -> DiscordState {
		if let chan = gs.states[channel] {
			return chan
		}

		let chan = try await client.getChannel(id: channel)
		let chann = try chan.decode()
		guard let gid = chann.guild_id else {
			throw NotFound()
		}
		self.gs.states[channel] = DiscordState(for: DiscordChannel(client: client, cache: cache, guildID: gid, channelID: channel), in: comm, eventLoop: ev)
		return self.gs.states[channel]!
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
				switch data.componentType {
				case .stringSelect:
					guard let value = data.values?.first?.asString else {
						return
					}
					try await selectMenuEvent(id: data.customID, target: value, user: user, intr: intr)
				case .button:
					try await buttonClickEvent(btn: data.customID, user: user, intr: intr)
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
	func slashCommandEvent(cmd: String, user: DiscordUser, opts: [Interaction.ApplicationCommandData.Option]?, intr: DiscordInteraction) async throws {
		let state = try await self.state(for: intr.event.channel_id!)

		switch cmd {
		case "join":
			try await state.join(who: user.id, interaction: intr)
		case "leave":
			try await state.leave(who: user.id, interaction: intr)
		case "party":
			try await state.party(who: user.id, interaction: intr)
		case "setup":
			try await state.setup(who: user.id, interaction: intr)
		case "unsetup":
			try await state.unsetup(who: user.id, interaction: intr)
		case "start":
			try await state.start(who: user.id, interaction: intr)
		case "remove":
			guard let opt = opts, let first = opt.first, let val = first.value?.asString else {
				try await intr.reply(with: "Oops, I had an error (Discord didn't send me an option...?)", epheremal: true)
				return
			}
			try await state.remove(who: user.id, target: val, interaction: intr)
		case "promote":
			guard let opt = opts, let first = opt.first, let val = first.value?.asString else {
				try await intr.reply(with: "Oops, I had an error (Discord didn't send me an option...?)", epheremal: true)
				return
			}
			try await state.promote(who: user.id, target: val, interaction: intr)
		case "role":
			guard let opt = opts, let first = opt.first, let val = first.value?.asString else {
				try await intr.reply(with: "Oops, I had an error (Discord didn't send me an option...?)", epheremal: true)
				return
			}
			try await state.role(who: user.id, what: val, interaction: intr)
		case "roles":
			try await state.sendRoles(who: user.id, interaction: intr)
		default:
			return
		}
	}
	func selectMenuEvent(id: String, target: String, user: DiscordUser, intr: DiscordInteraction) async throws {
		guard let targ = UInt64(target) else {
			try await intr.reply(with: "Oops, I didn't understand your target, sorry.", epheremal: true)
			return
		}
		let target = Snowflake(targ)
		guard let state = gs.states[user.id] else {
			try await intr.reply(with: "Oops, it doesnt look like you're in a game, sorry.", epheremal: true)
			return
		}

		switch id {
		case "werewolf-kill":
			try await state.werewolfKill(who: user.id, target: target, interaction: intr)
		case "guardianAngel-protect":
			try await state.guardianAngelProtect(who: user.id, target: target, interaction: intr)
		case "seer-investigate":
			try await state.seerInvestigate(who: user.id, target: target, interaction: intr)
		case "cookies-give":
			try await state.cookiesGive(who: user.id, target: target, interaction: intr)
		case "nominate":
			try await state.nominate(who: user.id, target: target, interaction: intr)
		case "goose":
			try await state.goose(who: user.id, target: target, interaction: intr)
		default:
			try await intr.reply(with: "Oops, I don't understand what you just did. Sorry.", epheremal: true)
		}
	}
	func buttonClickEvent(btn: String, user: DiscordUser, intr: DiscordInteraction) async throws {
		guard let state = gs.states[user.id] else {
			try await intr.reply(with: "Oops, it doesnt look like you're in a game, sorry.", epheremal: true)
			return
		}

		switch btn {
		case "nominate-yes":
			try await state.nominateYes(who: user.id, interaction: intr)
		case "nominate-no":
			try await state.nominateNo(who: user.id, interaction: intr)
		case "vote-yes":
			try await state.voteYes(who: user.id, interaction: intr)
		case "vote-no":
			try await state.voteNo(who: user.id, interaction: intr)
		default:
			_ = try? await intr.reply(with: "Oops, I don't understand which button you pressed...", epheremal: true)
		}
	}
}

@main
struct MappoMain {
	static func actualMain(client httpClient: HTTPClient) async {
		let config = try! JSONDecoder().decode(Config.self,  from: try! String(contentsOfFile: "config.json").data(using: .utf8)!)

		let bot = BotGatewayManager(
			eventLoopGroup: httpClient.eventLoopGroup,
			httpClient: httpClient,
			token: config.token,
			appId: config.appID,
			intents: [.guildMessages, .guildMembers, .messageContent]
		)
		let cache = await DiscordCache(
			gatewayManager: bot,
			intents: [.guildMembers],
			requestAllMembers: .enabled
		)
		let mappoBot = MyBot(client: bot.client, cache: cache, ev: httpClient.eventLoopGroup.next())

		await bot.addEventHandler { ev in
			let _ = httpClient.eventLoopGroup.makeFutureWithTask {
				do {
					try await mappoBot.dispatch(ev: ev)
				} catch {
					print(error)
				}
			}
		}

		await bot.connect()
	}
	static func main() {
		let httpClient = HTTPClient(eventLoopGroupProvider: .createNew)
		try! httpClient.eventLoopGroup.makeFutureWithTask {
			await actualMain(client: httpClient)
		}.wait()
		RunLoop.current.run()
	}
}

