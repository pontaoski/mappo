public protocol I18n {
    func roleName(_ role: Role) -> String
	func teamName(_ team: Team) -> String
	func dispositionName(_ disposition: Disposition) -> String
    func roleDescription(_ role: Role) -> String
    func timeOfYear(_ toy: TimeOfYear) -> String
    func nightTitle(_ toy: TimeOfYear, year: Int, day: Int) -> String
    func morningTitle(_ toy: TimeOfYear, year: Int, day: Int) -> String
    func votingTitle(numNominations: Int) -> String
    func getOverHere(_ list: String) -> String
    func beholderSeer(who: String) -> String
	func exilingTitle(who: String) -> String
	func notExilingTitle(who: String) -> String
	func votingPersonTitle(who: String) -> String
	func nightStatus(who: String, role: Role, alive: Bool) -> String
	func drVisitAlso(who: String) -> String

    var peopleJoinedParty: String { get }
    var peopleLeftParty: String { get }
    var nightHasFallen: String { get }
    var villagersGather: String { get }
    var itIsDaytime: String { get }
	var eveningDraws: String { get }
	var nominateYes: String { get }
	var nominateNo: String { get }
	var duskDrawsNobody: String { get }
	var duskDrawsNominating: String { get }
	var nominationTime: String { get }
	var nominationTitle: String { get }
	var noNominations: String { get }
	var voteYes: String { get }
	var voteNo: String { get }
	var timeToBed: String { get }
	var jesterReminder: String { get }
	var aliveTitle: String { get }
	var winterWolfAction: String { get }
	var normalWolfAction: String { get }
	var gaAction: String { get }
	var seerAction: String { get }
	var cpAction: String { get }
	var gooseAction: String { get }
	var gaPrompt: String { get }
	var seerPrompt: String { get }
	var cpPrompt: String { get }
	var goosePrompt: String { get }	
	var drWerewolf: String { get }
	var drExile: String { get }
	var drVisit: String { get }
	var drProtect: String { get }
	var drInnocent: String { get }
	var drGoose: String { get }
	var leaveLeaveQueue: String { get }
	var addedJoinQueue: String { get }
	var alreadyInParty: String { get }
	var joinedParty: String { get }
	var setupRequired: String { get }
	var leaveJoinQueue: String { get }
	var addedLeaveQueue: String { get }
	var notInParty: String { get }
	var leftParty: String { get }
}

public struct English: I18n {
    public let peopleJoinedParty = "Some people have joined the party!"
    public let peopleLeftParty = "Some people have joined the party!"
    public let nightHasFallen = "Night has fallen. Everyone heads to bed, weary after another stressful day. Night players: you have 35 seconds to use your actions!"
    public let villagersGather = "The villagers gather the next morning in the village center."
    public let itIsDaytime = "It is now day time. All of you have at least 30 seconds to make your accusations, defenses, claim roles, or just talk."
    public let eveningDraws = "Evening draws near, and it's now possible to start or skip nominations. Nominations will start or be skipped once a majority of people have indicated to do so."
    public let nominateYes = "Nominate Someone"
    public let nominateNo = "Don't Nominate Someone"
    public let duskDrawsNobody = "Dusk draws near, and it looks like nobody's getting nominated tonight..."
    public let duskDrawsNominating = "Dusk draws near, and the villagers gather to decide who they are nominating this evening..."
    public let nominationTime = "Everyone has 15 seconds to nominate someone!"
    public let nominationTitle = "Nominate people (or don't!)"
    public let noNominations = "Oops, doesn't look like there's any nominees tonight... Off to bed it is, then."
    public let voteYes = "Yes"
    public let voteNo = "No"
    public let timeToBed = "Dusk draws near, and it's time to get to bed... A little more discussion time (25 seconds) for you before that, though!"
    public let jesterReminder = "Remember: get yourself exiled!"
    public let aliveTitle = "Alive"
	public let winterWolfAction = "Looks like it's winter! With your snow coat, it's time to freeze someone tonight! This will prevent them from performing any action today."
	public let normalWolfAction = "Time to kill someone tonight!"
	public let gaAction = "Time to protect someone tonight!"
	public let seerAction = "Time to see someone tonight!"
	public let cpAction = "Time to visit someone tonight!"
	public let gooseAction = "Time to goose someone tonight!"
	public let gaPrompt = "Choose someone to protect"
	public let seerPrompt = "Choose someone to see their role"
	public let cpPrompt = "Choose someone to visit during the night and give them cookies"
	public let goosePrompt = "Choose someone to goose tonight!"
	public let drWerewolf = "You were killed by a werewolf!"
	public let drExile = "You were exiled by the village!"
	public let drVisit = "You died because you visited a werewolf!"
	public let drProtect = "You died because you protected a werewolf!"
	public let drInnocent = "You died because you were the first person to nominate an Innocent!"
	public let drGoose = "A goose killed you!"
	public let leaveLeaveQueue = "You have left the leave queue! You will stay in the game"
	public let addedJoinQueue = "You have been added to the join queue! You will join when the current game is over"
	public let alreadyInParty = "You're already in the party!"
	public let joinedParty = "You have joined the party!"
	public let setupRequired = "You need to setup again, since a new player joined"
	public let leaveJoinQueue = "You have left the leave queue"
	public let addedLeaveQueue = "You have been added to the leave queue! You will leave when the current game is over"
	public let notInParty = "You're not in the party!"
	public let leftParty = "You have left the party!"

	public init()
	{

	}
	public func drVisitAlso(who: String) -> String {
		"You died because you were visiting <@\(who)>, but unfortunately, a werewolf was visiting them too!"
	}
	public func nightStatus(who: String, role: Role, alive: Bool) -> String {
		if alive {
			return ":slight_smile: <@\(who)>"
		} else {
			return ":skull: <@\(who)> (was a \(roleName(role)))" // TODO: should we show people's roles when they die?
		}
	}
    public func beholderSeer(who: String) -> String {
        return "The Seer is <@\(who)>"
    }
    public func getOverHere(_ list: String) -> String {
        return "\(list), get over here!"
    }
    public func exilingTitle(who: String) -> String {
        return "Looks like we're exiling <@\(who)> tonight! Bye-bye!"
    }
    public func notExilingTitle(who: String) -> String {
        return "Looks like we're not exiling <@\(who)> tonight!"
    }
    public func votingPersonTitle(who: String) -> String {
        return "Are we voting out <@\(who)> tonight? You have 15 seconds to vote."
    }
    public func votingTitle(numNominations: Int) -> String {
        return "Let's go through all of the nominations! We have \(numNominations) of them tonight. We'll stop if and when we vote someone out."
    }
    public func nightTitle(_ toy: TimeOfYear, year: Int, day: Int) -> String {
        return "Night of \(self.timeOfYear(toy)) of Year \(year) (Game Day \(day))"
    }
    public func morningTitle(_ toy: TimeOfYear, year: Int, day: Int) -> String {
        return "Morning of \(self.timeOfYear(toy)) of Year \(year) (Game Day \(day))"
    }
    public func timeOfYear(_ toy: TimeOfYear) -> String {
		switch toy {
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
    public func roleDescription(_ role: Role) -> String {
        switch role {
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
		case .innocent:
			return "You are such a beacon of purity that you have gained the protection of an army of angels. The first time you are nominated, the angels will kill them immediately if they aren't evil."
		case .pacifist:
			return "You are staunchly opposed to death, so much so that you run a secret program to help executed good players escape from the executioner. It doesn't always work, though..."
		case .goose:
			return "You only want to see one thing: to see the world burn. Every night, you choose someone neutral or good to goose. For that night, if they take a night action, they'll target a random person instead."
		case .cursed:
			return "You are cursed! You appear as a villager to the seer, but, when the werewolf dies, you become a werewolf!"
        }
    }
    public func roleName(_ role: Role) -> String {
        switch role {
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
		case .innocent:
			return "Innocent"
		case .pacifist:
			return "Pacifist"
		case .goose:
			return "Goose"
		case .cursed:
			return "Cursed"
        }
    }
	public func teamName(_ team: Team) -> String {
		switch team {
		case .jester:
			return "Jester"
		case .village:
			return "Village"
		case .werewolf:
			return "Werewolf"
		}
	}
	public func dispositionName(_ disposition: Disposition) -> String {
		switch disposition {
		case .evil:
			return "Evil"
		case .good:
			return "Good"
		case .neutral:
			return "Neutral"
		}
	}
}

public struct TokiPona: I18n {
    public let peopleJoinedParty = "jan li kama tawa kulupu!"
    public let peopleLeftParty = "jan li weka tan kulupu!"
    public let nightHasFallen = "tenpo pimeja li kama. jan ale li tawa supa lape li pilin pi wawa ala. jan musi pi tenpo pimeja o, pali lon tenpo pimeja ni a!"
    public let villagersGather = "tenpo suno la, jan li kama lon tomo toki."
    public let itIsDaytime = "sina ale li jo e tenpo lili tawa ni: toki utala, toki awen, toki pi pali sina, anu toki pona."
    public let eveningDraws = "tenpo pimeja li kama la, sina ken open weka e jan. jan mute li wile la, sina ken alasa weka e jan."
    public let nominateYes = "alasa weka"
    public let nominateNo = "alasa ala weka"
    public let duskDrawsNobody = "tenpo pimeja li kama la, jan ala li kama weka..."
    public let duskDrawsNominating = "tenpo pimeja li kama la, jan li kama tawa ni: ona li alasa e jan pi wile weka..."
    public let nominationTime = "sina ken pana e jan pi wile weka sina!"
    public let nominationTitle = "o alasa weka e jan (anu weka ala!)"
    public let noNominations = "ike a, jan ala li pana e jan pi wile weka... ni la, o lape pona"
    public let voteYes = "wile"
    public let voteNo = "wile ala"
    public let timeToBed = "tenpo pimeja en tenpo lape li kama... taso, sina ken awen toki lon tenpo lili!"
    public let jesterReminder = "o sona e ni: sina o kama weka!"
    public let aliveTitle = "moli ala"
	public let winterWolfAction = "tenpo lete li lon a li lete e wawa sina! wile sina la, jan li pali ala lon tenpo pimeja ni!."
	public let normalWolfAction = "o moli e jan!"
	public let gaAction = "o awen e jan!"
	public let seerAction = "o sona e jan!"
	public let cpAction = "o pan e jan!"
	public let gooseAction = "o waso e jan!"
	public let gaPrompt = "sina wile awen e jan seme?"
	public let seerPrompt = "sina wile sona e pali pi jan seme?"
	public let cpPrompt = "sina wile pana e pan tawa jan seme?"
	public let goosePrompt = "sina wile waso e jan seme?"
	public let drWerewolf = "soweli mun li moli e sina!"
	public let drExile = "jan li weka e sina!"
	public let drVisit = "sina tawa tomo pi soweli mun la, soweli mun li moli e sina!"
	public let drProtect = "sina kama moli tan ni: sina awen e soweli mun!"
	public let drInnocent = "sina wile weka e jan pi ike ala  la, sina kama moli!"
	public let drGoose = "waso li moli e sina!"
	public let leaveLeaveQueue = "sina kama weka tan tomo weka! sina awen lon musi."
	public let addedJoinQueue = "sina kama lon tomo kama! musi ni li pini la, sina kama lon musi."
	public let alreadyInParty = "sina awen lon tomo musi!"
	public let joinedParty = "sina kama lon tomo musi!"
	public let setupRequired = "jan sin li kama la, sina o sin e pali jan."
	public let leaveJoinQueue = "sina kama weka tan tomo kama! sina kama ala musi."
	public let addedLeaveQueue = "sina kama lon tomo weka! musi ni la pini la, sina kama weka tan musi ni."
	public let notInParty = "sina lon ala kulupu!"
	public let leftParty = "sina kama weka tan kulupu!"

	public init()
	{

	}
	public func drVisitAlso(who: String) -> String {
		"You died because you were visiting <@\(who)>, but unfortunately, a werewolf was visiting them too!"
	}
	public func nightStatus(who: String, role: Role, alive: Bool) -> String {
		if alive {
			return ":slight_smile: <@\(who)>"
		} else {
			return ":skull: <@\(who)> (li \(roleName(role)))" // TODO: should we show people's roles when they die?
		}
	}
    public func beholderSeer(who: String) -> String {
        return "jan lukin li <@\(who)>"
    }
    public func getOverHere(_ list: String) -> String {
        return "\(list), o kama ni!"
    }
    public func exilingTitle(who: String) -> String {
        return "lukin la, jan li wile weka e <@\(who)>! tawa pona a!"
    }
    public func notExilingTitle(who: String) -> String {
        return "lukin la, jan li wile ala weka e <@\(who)>!"
    }
    public func votingPersonTitle(who: String) -> String {
        return "sina wile ala wile weka e <@\(who)>? tenpo 15s li lon."
    }
    public func votingTitle(numNominations: Int) -> String {
        return "Let's go through all of the nominations! We have \(numNominations) of them tonight. We'll stop if and when we vote someone out."
    }
    public func nightTitle(_ toy: TimeOfYear, year: Int, day: Int) -> String {
        return "mun \(self.timeOfYear(toy)) pi sike \(year) (suno nanpa \(day))"
    }
    public func morningTitle(_ toy: TimeOfYear, year: Int, day: Int) -> String {
        return "suno \(self.timeOfYear(toy)) pi sike \(year) (suno nanpa \(day))"
    }
    public func timeOfYear(_ toy: TimeOfYear) -> String {
		switch toy {
		case .earlySpring:
			return "open pi tenpo kasi"
		case .lateSpring:
			return "pini pi tenpo kasi"
		case .earlySummer:
			return "open pi tenpo seli"
		case .lateSummer:
			return "pini pi tenpo seli"
		case .earlyFall:
			return "open pi tenpo moli kasi"
		case .lateFall:
			return "pini pi tenpo moli kasi"
		case .earlyWinter:
			return "open pi tenpo lete"
		case .lateWinter:
			return "pini pi tenpo lete"
		}
    }
    public func roleDescription(_ role: Role) -> String {
        switch role {
		case .villager:
			return "sina jan pi pali ala taso. sina ken weka e jan."
		case .werewolf:
			return "sina soweli mun! o moli e jan ale, taso o kama ala weka!"
		case .guardianAngel:
			return "tenpo pimeja la, sina ken awen e jan wan, taso o sona e ni: sina awen e soweli mun, sina ken kama moli!"
		case .seer:
			return "sona sina li ken e lukin pi poki jan lon tenpo pimeja ale. poki ona li kama lon tawa sina. taso, jan soweli li sona e poki sina, ona li ken wile moli e sina!"
		case .beholder:
			return "sina jo e pali wan: sina sona e jan lukin."
		case .jester:
			return "sina jo e wile wan: jan li weka e sina."
		case .cookiePerson:
			return "tenpo pimeja la, sina ken tawa jan li pana e pan suwi tawa ona. sina tawa soweli mun la, sina kama moli. taso, soweli li tawa tomo sina la, sina tawa jan ante la, sina moli ala! sina en soweli mun li lon tomo sama la, ona li moli kin e sina."
		case .furry:
			return "sina olin e len soweli! taso, ni li ike tan ni: jan lukin li sona ala e ni: sina soweli mun ala. pakala a."
		case .innocent:
			return "sina sewi mute la, sina jo e kulupu pi jan sewi. sina kama jan pi wile weka la, ni li lon: jan pi weka sina li ike ala la, jan sewi li moli e ona."
		case .pacifist:
			return "moli li ike mute tawa sina la, sina lawa e kulupu len tawa ni: jan pona li kama weka ala. taso, ona li ken pakala..."
		case .goose:
			return "sina wile lukin e ni taso: ale li kama pakala. tenpo pimeja la, sina wile e jan pi ike ala. tenpo pimeja ni la, ona li pali pi wile ona ala."
		case .cursed:
			return "sina jan pi kama ike! jan lukin li lukin e ni: sina jan pi pali ala. taso, soweli mun li moli la, sina kama soweli mun!"
        }
    }
    public func roleName(_ role: Role) -> String {
        switch role {
		case .villager:
			return "jan pi pali ala"
		case .werewolf:
			return "soweli mun"
		case .guardianAngel:
			return "jan awen sewi"
		case .seer:
			return "jan lukin"
		case .beholder:
			return "jan lukin lukin"
		case .jester:
			return "jan nasa"
		case .cookiePerson:
			return "jan pi pan suwi"
		case .furry:
			return "jan soweli"
		case .innocent:
			return "jan pi ike ala"
		case .pacifist:
			return "jan pi utala ala"
		case .goose:
			return "waso"
		case .cursed:
			return "jan pi kama ike"
        }
    }
	public func teamName(_ team: Team) -> String {
		switch team {
		case .jester:
			return "jan nasa"
		case .village:
			return "ma tomo"
		case .werewolf:
			return "soweli mun"
		}
	}
	public func dispositionName(_ disposition: Disposition) -> String {
		switch disposition {
		case .evil:
			return "ike"
		case .good:
			return "pona"
		case .neutral:
			return "ala"
		}
	}
}

