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
    func laundrypersonStart(_ p1: String, _ p2: String, _ role: Role) -> String
    func gossip(_ p1: String, _ p2: String, _ p3: String) -> String
    func librarianStart(_ p1: String, _ p2: String, _ role: Role) -> String
    func gooseKillMessage(who: String) -> String
    func werewolfKillMessage(who: String) -> String
    func exilingTitle(who: String) -> String
    func notExilingTitle(who: String) -> String
    func votingPersonTitle(who: String) -> String
    func nightStatus(who: String, role: Role, alive: Bool) -> String
    func drVisitAlso(who: String) -> String
    func visitedWerewolf(who: String) -> String
    func visitedWerewolfEaten(who: String) -> String
    func visitedWerewolfProtected(who: String) -> String
    func visitedPersonBeingVisitedByWerewolf(who: String, visiting: String) -> String
    func visitedPersonBeingVisitedByWerewolfEaten(who: String) -> String
    func visitedPersonBeingVisitedByWerewolfProtected(who: String) -> String
    func pacifistIntervention(who: String) -> String
    func nominatedInnocent(who: String) -> String
    func protectedWerewolf(who: String) -> String
    func wasA(_ role: Role) -> String
    func check(who: String, is role: Role) -> String
    func check(who: String, isNot role: Role) -> String
    func victory(_ reason: VictoryReason) -> String
    func victoryTitle(_ reason: VictoryReason) -> String
    func necromancerRevivedAndDidntConvert(who: String) -> String
    func necromancerRevivedAndConverted(who: String) -> String

    var partyListTitle: String { get }
    var playerStatusTitle: String { get }
    var frozenByWerewolfDM: String { get }
    var frozenByWerewolfAnnouncement: String { get }
    var cursedIsWerewolfNow: String { get }
    var gooseIsViolentNow: String { get }
    var killSuccess: String { get }
    var killFailure: String { get }
    var killProtected: String { get }
    var killAwayFromHome: String { get }
    var peopleJoinedParty: String { get }
    var peopleLeftParty: String { get }
    var nightHasFallen: String { get }
    var villagersGather: String { get }
    var itIsDaytime: String { get }
    var eveningDraws: String { get }
    var nominateSkip: String { get }
    var duskDrawsSkip: String { get }
    var duskDrawsVoting: String { get }
    var nominationTitle: String { get }
    var voteYes: String { get }
    var voteNo: String { get }
    var timeToBed: String { get }
    var jesterReminder: String { get }
    var aliveTitle: String { get }
    var winterWolfAction: String { get }
    var normalWolfAction: String { get }
    var gaAction: String { get }
    var seerAction: String { get }
    var oracleAction: String { get }
    var cpAction: String { get }
    var gooseAction: String { get }
    var gaPrompt: String { get }
    var seerPrompt: String { get }
    var oraclePrompt: String { get }
    var cpPrompt: String { get }
    var goosePrompt: String { get } 
    var necromancerPrompt: String { get }
    var revivedNoChange: String { get }
    var revivedVampire: String { get }
    var drWerewolf: String { get }
    var drExile: String { get }
    var drVisit: String { get }
    var drProtect: String { get }
    var drInnocent: String { get }
    var drGoose: String { get }
    var leaveLeaveQueue: String { get }
    var addedJoinQueue: String { get }
    var alreadyInParty: String { get }
    var alreadyInAnotherParty: String { get }
    var joinedParty: String { get }
    var setupRequired: String { get }
    var leaveJoinQueue: String { get }
    var addedLeaveQueue: String { get }
    var notInParty: String { get }
    var leftParty: String { get }
}

public struct English: I18n {
    public func laundrypersonStart(_ p1: String, _ p2: String, _ role: Role) -> String { "You know that one of <@\(p1)> or <@\(p2)> is a \(roleName(role))." }
    public func gossip(_ p1: String, _ p2: String, _ p3: String) -> String { "You know that one of <@\(p1)>, <@\(p2)>, or <@\(p3)> is evil!" }
    public func librarianStart(_ p1: String, _ p2: String, _ role: Role) -> String { "You know that one of <@\(p1)> or <@\(p2)> is a \(roleName(role))." }

    static var gooseDeathItems: [String] {
        [
            "an old rusty knife",
            "a pride flag",
            "a loaf of bread",
            "pure hatred",
            "a garden hose"
        ]
    }

    public func gooseKillMessage(who: String) -> String { "The Geese try to stab <@\(who)> with \(English.gooseDeathItems.randomElement()!)..." }
    public func werewolfKillMessage(who: String) -> String { "The Werewolves try to kill <@\(who)>..." }
    public func visitedWerewolf(who: String) -> String { "<@\(who)> decided to visit a Werewolf, uh-oh..." }
    public func visitedWerewolfEaten(who: String) -> String { "and <@\(who)> got eaten!" }
    public func visitedWerewolfProtected(who: String) -> String { "Luckily, <@\(who)> was protected by a Guardian Angel!" }
    public func visitedPersonBeingVisitedByWerewolf(who: String, visiting: String) -> String { "<@\(who)> was visiting <@\(visiting)>, but unfortunately, the werewolves were visiting them too!" }
    public func visitedPersonBeingVisitedByWerewolfEaten(who: String) -> String { "The werewolves had a tasty bonus snack! <@\(who)> got eaten by the werewolves!" }
    public func visitedPersonBeingVisitedByWerewolfProtected(who: String) -> String { "The werewolves were going to have a bonus snack, but <@\(who)> was protected by a Guardian Angel!" }
    public func pacifistIntervention(who: String) -> String { "The pacifist snuck <@\(who)> away from the executioner's hands! They get to live another day." }
    public func nominatedInnocent(who: String) -> String { "<@\(who)> drew the ire of the heavens by nominating their favourite Innocent, and collapses dead due to its intervention! Oops." }
    public func protectedWerewolf(who: String) -> String { "<@\(who)> used angelic magic to protect a werewolf. Unfortunately, the werewolf's evil magic killed <@\(who)> when the two magics collided! Oops." }
    public func wasA(_ role: Role) -> String { "was a \(roleName(role))" }
    public func check(who: String, is role: Role) -> String { "<@\(who)> is a \(roleName(role))!" }
    public func check(who: String, isNot role: Role) -> String { "<@\(who)> is not a \(roleName(role))!" }
    public func necromancerRevivedAndDidntConvert(who: String) -> String { "<@\(who)> got revived, but didn't become a vampire! "}
    public func necromancerRevivedAndConverted(who: String) -> String { "<@\(who)> got revived, and became a vampire! "}
    public func victory(_ reason: VictoryReason) -> String {
        switch reason {
        case .allWerewolvesDead: return "All the werewolves are dead!"
        case .werewolvesMajority: return "Ope, the werewolves outnumber the villagers!"
        case .jesterExiled: return "The jester got exiled!"
        }
    }
    public func victoryTitle(_ reason: VictoryReason) -> String {
        switch reason.winningTeam {
        case .village: return "The villagers won!"
        case .werewolf: return "The werewolves won!"
        case .jester: return "The jester won!"
        case .necromancer: return "The necromancer won!"
        }
    }
    public let partyListTitle = "Your Party"
    public let playerStatusTitle = "Players"
    public let frozenByWerewolfDM = "You were frozen by the Werewolf!"
    public let frozenByWerewolfAnnouncement = "You felt the chills of the werewolf's ice magic freezing someone in the night..."
    public let cursedIsWerewolfNow = "Looks like the werewolf died, so you're the werewolf now!"
    public let gooseIsViolentNow = "Looks like there aren't any werewolves, time to take matters into your own hands! Now, people will die when you goose them."
    public let killSuccess = "... and succeeded!"
    public let killFailure = "... and failed."
    public let killProtected = "... but a Guardian Angel protects them!"
    public let killAwayFromHome = "... but they were away from home!"
    public let peopleJoinedParty = "Some people have joined the party!"
    public let peopleLeftParty = "Some people have left the party!"
    public let nightHasFallen = "Night has fallen. Everyone heads to bed, weary after another stressful day. Night players: you have 35 seconds to use your actions!"
    public let villagersGather = "The villagers gather the next morning in the village center."
    public let itIsDaytime = "It is now day time. All of you have at least 30 seconds to make your accusations, defenses, claim roles, or just talk."
    public let eveningDraws = "Evening draws near, and it's now possible to nominate people (or skip). We will proceed when 3/4th of villagers have decided."
    public let nominateSkip = "Skip Nominations"
    public let duskDrawsSkip = "The people have decided to skip voting tonight."
    public let duskDrawsVoting = "It's getting dark... let's go through the nominations!"
    public let nominationTitle = "Nominate people (or don't!)"
    public let voteYes = "Yes"
    public let voteNo = "No"
    public let timeToBed = "Dusk draws near, and it's time to get to bed... A little more discussion time (25 seconds) for you before that, though!"
    public let jesterReminder = "Remember: get yourself exiled!"
    public let aliveTitle = "Alive"
    public let winterWolfAction = "Looks like it's winter! With your snow coat, it's time to freeze someone tonight! This will prevent them from performing any action today."
    public let normalWolfAction = "Time to kill someone tonight!"
    public let gaAction = "Time to protect someone tonight!"
    public let seerAction = "Time to see someone tonight!"
    public let oracleAction = "Time to ponder someone tonight!"
    public let cpAction = "Time to visit someone tonight!"
    public let gooseAction = "Time to goose someone tonight!"
    public let gaPrompt = "Choose someone to protect"
    public let seerPrompt = "Choose someone to see their role"
    public let oraclePrompt = "Choose someone to see what role they are not (from roles that are in the game)"
    public let cpPrompt = "Choose someone to visit during the night and give them cookies"
    public let goosePrompt = "Choose someone to goose tonight!"
    public let necromancerPrompt = "Choose someone to revive tonight! (They have a 50% chance to become a vampire...)"
    public let revivedVampire = "You were revived, but you became a vampire!"
    public let revivedNoChange = "You were revived!"
    public let drWerewolf = "You were killed by a werewolf!"
    public let drExile = "You were exiled by the village!"
    public let drVisit = "You died because you visited a werewolf!"
    public let drProtect = "You died because you protected a werewolf!"
    public let drInnocent = "You died because you were the first person to nominate an Innocent!"
    public let drGoose = "A goose killed you!"
    public let leaveLeaveQueue = "You have left the leave queue! You will stay in the game"
    public let addedJoinQueue = "You have been added to the join queue! You will join when the current game is over"
    public let alreadyInParty = "You're already in the party!"
    public let alreadyInAnotherParty = "You're in another party!"
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
        case .oracle:
            return "You are blessed by the deities with the gift of divination. Every night, you can choose a player. You will be told what role that player is *not*."
        case .laundryperson:
            return "You work the town's laundry, and realise that one of your clients left a doohickey in a basket for two. At the start of the game, you know that 1 of 2 players is a particular neutral or good role."
        case .gossip:
            return "You love to gossip! With your social savvy, you realise that one of three people in your favourite gossip circle is evil!"
        case .librarian:
            return "You're the sole person in the town's library. One of your recent patrons checked out an evil book, but you can't remember who. At the start of the game, you know that 1 of 2 players is a particular evil role."
        case .necromancer:
            return "You can bring people back from the dead, with a 50% chance to turn them into vampires. You win when you and your vampires outnumber everyone else."
        case .vampire:
            return "You were brought back from the dead to a new form by the Necromancer! Try not to return to the grave!"
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
        case .oracle:
            return "Oracle"
        case .laundryperson:
            return "Laundryperson"
        case .gossip:
            return "Gossip"
        case .librarian:
            return "Librarian"
        case .necromancer:
            return "Necromancer"
        case .vampire:
            return "Vampire"
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
        case .necromancer:
            return "Necromancer"
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
    public func laundrypersonStart(_ p1: String, _ p2: String, _ role: Role) -> String { "sina sona e ni: wan lon kulupu pi <@\(p1)> en <@\(p2)> li \(roleName(role))." }
    public func gossip(_ p1: String, _ p2: String, _ p3: String) -> String { "sina sona e ni: wan lon kulupu pi <@\(p1)> en <@\(p2)> en <@\(p3)> li ike!" }
    public func librarianStart(_ p1: String, _ p2: String, _ role: Role) -> String { "sina sona e ni: wan lon kulupu pi <@\(p1)> en <@\(p2)> li \(roleName(role))." }

    static var gooseDeathItems: [String] {
        [
            "ilo kipisi jaki",
            "len kule",
            "pan",
            "pilin ike",
            "linja telo"
        ]
    }

    public func gooseKillMessage(who: String) -> String { "waso li alasa moli e <@\(who)> kepeken \(English.gooseDeathItems.randomElement()!)..." }
    public func werewolfKillMessage(who: String) -> String { "soweli mun li alasa moli e <@\(who)>..." }
    public func visitedWerewolf(who: String) -> String { "<@\(who)> li tawa tomo pi soweli mun, pakala..." }
    public func visitedWerewolfEaten(who: String) -> String { "<@\(who)> li kama moku!" }
    public func visitedWerewolfProtected(who: String) -> String { "pona a! jan awen sewi li awen e <@\(who)>!" }
    public func visitedPersonBeingVisitedByWerewolf(who: String, visiting: String) -> String { "<@\(who)> li tawa tomo pi <@\(visiting)>. ike la, soweli mun li tawa tomo sama!" }
    public func visitedPersonBeingVisitedByWerewolfEaten(who: String) -> String { "soweli mun li jo e moku kin! <@\(who)> li kama moku a!" }
    public func visitedPersonBeingVisitedByWerewolfProtected(who: String) -> String { "tenpo ante la soweli mun li jo e moku kin. taso tenpo ni la jan awen sewi li awen e <@\(who)>!" }
    public func pacifistIntervention(who: String) -> String { "jan pi utala ala li weka e <@\(who)> tan tomo moli! ona li moli ala!" }
    public func nominatedInnocent(who: String) -> String { "<@\(who)> li wile weka e jan pi ike ala! ni li ike suli tawa kulupu sewi! ona li kama moli tan ni. pakala." }
    public func protectedWerewolf(who: String) -> String { "<@\(who)> li awen e soweli mun. taso wawa ike pi soweli mun li moli e ona! pakala." }
    public func wasA(_ role: Role) -> String { "li \(roleName(role))" }
    public func check(who: String, is role: Role) -> String { "<@\(who)> li \(roleName(role))!" }
    public func check(who: String, isNot role: Role) -> String { "<@\(who)> li \(roleName(role)) ala!" }
    public func necromancerRevivedAndDidntConvert(who: String) -> String { "<@\(who)> li kama lon sin a li kama ala moli mun! "}
    public func necromancerRevivedAndConverted(who: String) -> String { "<@\(who)> li kama lon sin a li kama moli mun! "}
    public func victory(_ reason: VictoryReason) -> String {
        switch reason {
        case .allWerewolvesDead: return "kulupu ike li moli!"
        case .werewolvesMajority: return "kulupu ike li suli la kulupu pona li lili a!"
        case .jesterExiled: return "jan nasa li kama weka!"
        }
    }
    public func victoryTitle(_ reason: VictoryReason) -> String {
        switch reason.winningTeam {
        case .village: return "kulupu pi ma tomo li awen!"
        case .werewolf: return "soweli mun li moli e ma tomo!"
        case .jester: return "jan nasa li weka!"
        case .necromancer: return "kulupu pi jan pi wawa moli li kama suli!"
        }
    }
    public let partyListTitle = "kulupu musi"
    public let playerStatusTitle = "kulupu musi"
    public let frozenByWerewolfDM = "sina kama lete pi pali ala tan soweli mun!"
    public let frozenByWerewolfAnnouncement = "sina pilin e wawa lete pi soweli mun lon tenpo pimeja. sina sona e ni: soweli mun li lete e ijo."
    public let cursedIsWerewolfNow = "soweli mun li moli a la sina kama soweli mun sin!"
    public let gooseIsViolentNow = "soweli mun li moli a la sina o utala a! sina waso e ijo la ona li kama moli."
    public let killSuccess = "... ona li moli e ona!"
    public let killFailure = "... ona li moli ala e ona."
    public let killProtected = "... jan awen sewi li awen e ona!"
    public let killAwayFromHome = "... taso ona li weka tan tomo ona!"
    public let peopleJoinedParty = "jan li kama tawa kulupu!"
    public let peopleLeftParty = "jan li weka tan kulupu!"
    public let nightHasFallen = "tenpo pimeja li kama. jan ale li tawa supa lape li pilin pi wawa ala. jan musi pi tenpo pimeja o, pali lon tenpo pimeja ni a!"
    public let villagersGather = "tenpo suno la, jan li kama lon tomo toki."
    public let itIsDaytime = "sina ale li jo e tenpo lili tawa ni: toki utala, toki awen, toki pi pali sina, anu toki pona."
    public let eveningDraws = "tenpo pimeja li kama la, sina ken open weka e jan. jan mute li wile la, sina ken alasa weka e jan."
    public let nominateSkip = "alasa ala weka"
    public let duskDrawsSkip = "kulupu li wile ala alasa weka."
    public let duskDrawsVoting = "tenpo mun li kama la, mi o open alasa weka a!"
    public let nominationTitle = "o alasa weka e jan (anu weka ala!)"
    public let voteYes = "wile"
    public let voteNo = "wile ala"
    public let timeToBed = "tenpo pimeja en tenpo lape li kama... taso, sina ken awen toki lon tenpo lili!"
    public let jesterReminder = "o sona e ni: sina o kama weka!"
    public let aliveTitle = "moli ala"
    public let winterWolfAction = "tenpo lete li lon a li lete e wawa sina! wile sina la, jan li pali ala lon tenpo pimeja ni!."
    public let normalWolfAction = "o moli e jan!"
    public let gaAction = "o awen e jan!"
    public let seerAction = "o sona e jan!"
    public let oracleAction = "o sona e pali ala jan!"
    public let cpAction = "o pan e jan!"
    public let gooseAction = "o waso e jan!"
    public let gaPrompt = "sina wile awen e jan seme?"
    public let seerPrompt = "sina wile sona e pali pi jan seme?"
    public let oraclePrompt = "sina wile sona e pali ala pi jan seme?"
    public let cpPrompt = "sina wile pana e pan tawa jan seme?"
    public let goosePrompt = "sina wile waso e jan seme?"
    public let necromancerPrompt = "sina wile pana e lon sin tawa jan seme? (ken 50% la ona li kama moli mun...)"
    public let revivedVampire = "sina kama lon sin a! taso sina kama moli mun a!"
    public let revivedNoChange = "sina kama lon sin a!"
    public let drWerewolf = "soweli mun li moli e sina!"
    public let drExile = "jan li weka e sina!"
    public let drVisit = "sina tawa tomo pi soweli mun la, soweli mun li moli e sina!"
    public let drProtect = "sina kama moli tan ni: sina awen e soweli mun!"
    public let drInnocent = "sina wile weka e jan pi ike ala  la, sina kama moli!"
    public let drGoose = "waso li moli e sina!"
    public let leaveLeaveQueue = "sina kama weka tan tomo weka! sina awen lon musi."
    public let addedJoinQueue = "sina kama lon tomo kama! musi ni li pini la, sina kama lon musi."
    public let alreadyInParty = "sina awen lon tomo musi!"
    public let alreadyInAnotherParty = "sina lon tomo musi ante!"
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
        case .oracle:
            return "wawa sewi li pana e ken ni tawa sina: sina sona e pali ala jan. (pali toki li lon musi.)"
        case .laundryperson:
            return "sina telo e len la, sina oko e ni: ilo li lon poki len pi jan tu a! open musi la, sina sona e ni: jan wan tan kulupu tu li jo e ilo ni (e poki ona)."
        case .gossip:
            return "sina toki mute a! sina toki pona la, sina kama sona e ni: jan wan tan kulupu tuli li ike a!"
        case .librarian:
            return "sina pali lon tomo lipu. jan li alasa e lipu ike tan ona. sona pi nimi ona li weka tan lawa sina a... taso sina sona e jan pini tu a! wan tan tu ni li ike a!"
        case .necromancer:
            return "sina ken pana e lon sin tawa jan moli. ken 50% la ona li kama moli mun."
        case .vampire:
            return "jan pi wawa moli li pana e lon sin tawa sina a! o kama ala moli sin!"
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
        case .oracle:
            return "jan oko"
        case .laundryperson:
            return "jan pi telo len"
        case .gossip:
            return "jan toki"
        case .librarian:
            return "jan lipu"
        case .necromancer:
            return "jan pi wawa moli"
        case .vampire:
            return "moli mun"
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
        case .necromancer:
            return "kulupu jan pi wawa moli"
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

