public enum ClueMessage {
    case libraryIsEvil(_ player1: Mentionable, _ player2: Mentionable)
    case librarySeerOrBeholder(_ player1: Mentionable, _ player2: Mentionable)
    case libraryCookiePerson(_ player1: Mentionable, _ player2: Mentionable)

    case barIsEvil(_ player1: Mentionable, _ player2: Mentionable, _ player3: Mentionable)
    case barGuardianAngelOrInnocent(_ player1: Mentionable)
    case barVillager(_ player1: Mentionable, _ player2: Mentionable)

    case warehouseIsEvil(_ player1: Mentionable, _ player2: Mentionable)
    case warehouseJester(_ player1: Mentionable, _ player2: Mentionable)
    case warehouseOracle(_ player1: Mentionable, _ player2: Mentionable)

    case villageCenterIsEvil(_ player1: Mentionable, _ player2: Mentionable, _ player3: Mentionable)
    case villageCenterPacifist(_ player1: Mentionable, _ player2: Mentionable)
    case villageCenterFurry(_ player1: Mentionable, _ player2: Mentionable, _ player3: Mentionable)
    case villageCenterInnocent(_ player1: Mentionable, _ player2: Mentionable)
    case villageCenterBeholder(_ player1: Mentionable, _ player2: Mentionable)
    case villageCenterJester(_ player1: Mentionable, _ player2: Mentionable)
    case villageCenterCookiePerson(_ player1: Mentionable, _ player2: Mentionable)

    var tag: Tag {
        switch self {
        case .libraryIsEvil: .libraryIsEvil
        case .librarySeerOrBeholder: .librarySeerOrBeholder
        case .libraryCookiePerson: .libraryCookiePerson
        case .barIsEvil: .barIsEvil
        case .barGuardianAngelOrInnocent: .barGuardianAngelOrInnocent
        case .barVillager: .barVillager
        case .warehouseIsEvil: .warehouseIsEvil
        case .warehouseJester: .warehouseJester
        case .warehouseOracle: .warehouseOracle
        case .villageCenterIsEvil: .villageCenterIsEvil
        case .villageCenterPacifist: .villageCenterPacifist
        case .villageCenterFurry: .villageCenterFurry
        case .villageCenterInnocent: .villageCenterInnocent
        case .villageCenterBeholder: .villageCenterBeholder
        case .villageCenterJester: .villageCenterJester
        case .villageCenterCookiePerson: .villageCenterCookiePerson
        }
    }

    public enum Tag: Equatable {
        case libraryIsEvil
        case librarySeerOrBeholder
        case libraryCookiePerson
        case barIsEvil
        case barGuardianAngelOrInnocent
        case barVillager
        case warehouseIsEvil
        case warehouseJester
        case warehouseOracle
        case villageCenterIsEvil
        case villageCenterPacifist
        case villageCenterFurry
        case villageCenterInnocent
        case villageCenterBeholder
        case villageCenterJester
        case villageCenterCookiePerson
    }
}

public protocol I18n {
    func roleName(_ role: Role) -> String
    func roleSummary(_ role: Role) -> String
    func teamName(_ team: Team) -> String
    func roleDescription(_ role: Role) -> String
    func timeOfYear(_ toy: TimeOfYear) -> String
    func nightTitle(_ toy: TimeOfYear, year: Int, day: Int) -> String
    func morningTitle(_ toy: TimeOfYear, year: Int, day: Int) -> String
    func votingTitle(numNominations: Int) -> String
    func getOverHere(_ list: String) -> String
    func talkThreadGetOverHere(_ list: String) -> String
    func evilTalkThreadGetOverHere(_ list: String) -> String
    func beholderSeer(who: Mentionable) -> String
    func laundrypersonStart(_ p1: Mentionable, _ p2: Mentionable, _ role: Role) -> String
    func gossip(_ p1: Mentionable, _ p2: Mentionable, _ p3: Mentionable) -> String
    func librarianStart(_ p1: Mentionable, _ p2: Mentionable, _ role: Role) -> String
    func gooseKillMessage(who: Mentionable) -> String
    func werewolfKillMessage(who: Mentionable) -> String
    func exilingTitle(who: Mentionable) -> String
    func notExilingTitle(who: Mentionable) -> String
    func votingPersonTitle(who: Mentionable) -> String
    func nightStatus(who: Mentionable, role: Role, alive: Bool) -> String
    func drVisitAlso(who: Mentionable) -> String
    func visitedWerewolf(who: Mentionable) -> String
    func visitedWerewolfEaten(who: Mentionable) -> String
    func visitedWerewolfProtected(who: Mentionable) -> String
    func visitedPersonBeingVisitedByWerewolf(who: Mentionable, visiting: Mentionable) -> String
    func visitedPersonBeingVisitedByWerewolfEaten(who: Mentionable) -> String
    func visitedPersonBeingVisitedByWerewolfProtected(who: Mentionable) -> String
    func pacifistIntervention(who: Mentionable) -> String
    func nominatedInnocent(who: Mentionable) -> String
    func protectedWerewolf(who: Mentionable) -> String
    func wasA(_ role: Role) -> String
    func check(who: Mentionable, is role: Role) -> String
    func check(who: Mentionable, isNot role: Role) -> String
    func victory(_ reason: VictoryReason) -> String
    func victoryTitle(_ reason: VictoryReason) -> String
    func youAreNotA(_ role: Role) -> String
    func youAreGoingToInvestigate(_ user: Mentionable) -> String
    func locationName(_ location: DetectiveLocations) -> String
    func youAreGoingToInvestigate(_ location: DetectiveLocations) -> String
    func youAreGoingToFreeze(_ user: Mentionable) -> String
    func youAreGoingToKill(_ user: Mentionable) -> String
    func youAreGoingToProtect(_ user: Mentionable) -> String
    func youAreGoingToGiveCookies(to user: Mentionable) -> String
    func youAreGoingToGoose(_ user: Mentionable) -> String
    func youAreGoingToInebriate(_ user: Mentionable) -> String
    func bartenderRandomised(_ who: Mentionable) -> String
    func bartenderStopped(_ who: Mentionable) -> String
    func bartenderFailed(_ who: Mentionable) -> String
    func hasBeenRemoved(_ user: Mentionable) -> String
    func hasBeenPromoted(_ user: Mentionable) -> String
    func strategyBlurb(for role: Role) -> String
    func clue(_ clue: ClueMessage) -> String

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
    func nightHasFallen(seconds: Int) -> String
    var villagersGather: String { get }
    func itIsDaytime(seconds: Int) -> String
    func dayTimeRunningOut(seconds: Int) -> String
    func eveningDraws(seconds: Int) -> String
    var nominateSkip: String { get }
    var duskDrawsSkip: String { get }
    var duskDrawsVoting: String { get }
    var nominationTitle: String { get }
    func nominationEndingSoonTitle(seconds: Int) -> String
    var voteYes: String { get }
    var voteNo: String { get }
    var timeToBed: String { get }
    var jesterReminder: String { get }
    var aliveTitle: String { get }
    // action titles
    var winterWolfAction: String { get }
    var normalWolfAction: String { get }
    var gaAction: String { get }
    var seerAction: String { get }
    var oracleAction: String { get }
    var cpAction: String { get }
    var gooseAction: String { get }
    var detectiveAction: String { get }
    // action prompts
    var gaPrompt: String { get }
    var seerPrompt: String { get }
    var oraclePrompt: String { get }
    var cpPrompt: String { get }
    var goosePrompt: String { get } 
    var detectivePrompt: String { get }
    var detectiveNothingHere: String { get }
    var detectiveCouldntInvestigate: String { get }
    var drWerewolf: String { get }
    var drExile: String { get }
    var drVisit: String { get }
    var drProtect: String { get }
    var drInnocent: String { get }
    var drGoose: String { get }
    var alreadyInParty: String { get }
    var alreadyInAnotherParty: String { get }
    func joinedParty(who: Mentionable) -> String
    var setupRequired: String { get }
    var notInParty: String { get }
    var leftParty: String { get }
    var nobodyVoted: String { get }
    var voteWasTie: String { get }
    var mustBePartyLeader: String { get }
    var gameAlreadyInProgress: String { get }
    var atLeastFourPeopleNeeded: String { get }
    var lobbyNotInRightState: String { get }
    var gameHasBeenStarted: String { get }
    var targetNotInParty: String { get }
    var headerMinimumPlayerCount: String { get }
    var headerMaximumRoleCount: String { get }
    var headerTeam: String { get }
    var headerRoles: String { get }
    var mustBeAliveToVote: String { get }
    var voteHasBeenRecorded: String { get }
    var roleNotFound: String { get }
    var bartenderAction: String { get }
    var bartenderPrompt: String { get }
    var inebriatedFailureDM: String { get }
    var gameCreated: String { get }
    var joinGame: String { get }
    var assigningRoles: String { get }
    var readRoles: String { get }
    var gameStarting: String { get }
    var resumed: String { get }
}

public struct English: I18n {
    public func laundrypersonStart(_ p1: Mentionable, _ p2: Mentionable, _ role: Role) -> String { "You know that one of \(p1.mention()) or \(p2.mention()) is a \(roleName(role))." }
    public func gossip(_ p1: Mentionable, _ p2: Mentionable, _ p3: Mentionable) -> String { "You know that one of \(p1.mention()), \(p2.mention()), or \(p3.mention()) is evil!" }
    public func librarianStart(_ p1: Mentionable, _ p2: Mentionable, _ role: Role) -> String { "You know that one of \(p1.mention()) or \(p2.mention()) is a \(roleName(role))." }

    static var gooseDeathItems: [String] {
        [
            "an old rusty knife",
            "a pride flag",
            "a loaf of bread",
            "pure hatred",
            "a garden hose"
        ]
    }

    public func gooseKillMessage(who: Mentionable) -> String { "The Geese try to stab \(who.mention()) with \(English.gooseDeathItems.randomElement()!)..." }
    public func werewolfKillMessage(who: Mentionable) -> String { "The Werewolves try to kill \(who.mention())..." }
    public func visitedWerewolf(who: Mentionable) -> String { "\(who.mention()) decided to visit a Werewolf, uh-oh..." }
    public func visitedWerewolfEaten(who: Mentionable) -> String { "and \(who.mention()) got eaten!" }
    public func visitedWerewolfProtected(who: Mentionable) -> String { "Luckily, \(who.mention()) was protected by a Guardian Angel!" }
    public func visitedPersonBeingVisitedByWerewolf(who: Mentionable, visiting: Mentionable) -> String { "\(who.mention()) was visiting \(visiting.mention()), but unfortunately, the werewolves were visiting them too!" }
    public func visitedPersonBeingVisitedByWerewolfEaten(who: Mentionable) -> String { "The werewolves had a tasty bonus snack! \(who.mention()) got eaten by the werewolves!" }
    public func visitedPersonBeingVisitedByWerewolfProtected(who: Mentionable) -> String { "The werewolves were going to have a bonus snack, but \(who.mention()) was protected by a Guardian Angel!" }
    public func pacifistIntervention(who: Mentionable) -> String { "The pacifist snuck \(who.mention()) away from the executioner's hands! They get to live another day." }
    public func nominatedInnocent(who: Mentionable) -> String { "\(who.mention()) drew the ire of the heavens by nominating their favourite Innocent, and collapses dead due to its intervention! Oops." }
    public func protectedWerewolf(who: Mentionable) -> String { "\(who.mention()) used angelic magic to protect a werewolf. Unfortunately, the werewolf's evil magic killed \(who.mention()) when the two magics collided! Oops." }
    public func wasA(_ role: Role) -> String { "was a \(role.emoji) \(roleName(role))" }
    public func check(who: Mentionable, is role: Role) -> String { "\(who.mention()) is a \(role.emoji) \(roleName(role))!" }
    public func check(who: Mentionable, isNot role: Role) -> String { "\(who.mention()) is not a \(role.emoji) \(roleName(role))!" }
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
        }
    }
    public func youAreNotA(_ role: Role) -> String {
        "You aren't a \(role.emoji) \(roleName(role))!"
    }
    public func youAreGoingToInvestigate(_ user: Mentionable) -> String
    { "You are going to investigate \(user.mention()) tonight!" }
    public func locationName(_ location: DetectiveLocations) -> String {
        switch location {
        case .library:
            "Town Library"
        case .bar:
            "Bar"
        case .warehouse:
            "Abandoned Warehouse"
        case .villageSquare:
            "Village Square"
        }
    }
    public func youAreGoingToInvestigate(_ location: DetectiveLocations) -> String {
        switch location {
        case .library:
            "You are going to visit the library tonight."
        case .bar:
            "You're taking a visit to the town bar tonight."
        case .warehouse:
            "You're investigating the warehouse tonight."
        case .villageSquare:
            "You're looking around the village square tonight."
        }
    }
    public func youAreGoingToFreeze(_ user: Mentionable) -> String
    { "You are going to freeze \(user.mention()) tonight!" }
    public func youAreGoingToKill(_ user: Mentionable) -> String
    { "You are going to kill \(user.mention()) tonight!" }
    public func youAreGoingToProtect(_ user: Mentionable) -> String
    { "You are going to protect \(user.mention()) tonight!" }
    public func youAreGoingToGiveCookies(to user: Mentionable) -> String
    { "You are going to give cookies to \(user.mention()) tonight!" }
    public func youAreGoingToGoose(_ user: Mentionable) -> String
    { "You are going to goose \(user.mention()) tonight!" }
    public func hasBeenRemoved(_ user: Mentionable) -> String
    { "\(user.mention()) was removed from the party." }
    public func hasBeenPromoted(_ user: Mentionable) -> String
    { "\(user.mention()) has been promoted to party leader!" }
    public func youAreGoingToInebriate(_ user: Mentionable) -> String
    { "You're going to serve drinks to \(user.mention()) tonight!" }
    public func bartenderRandomised(_ user: Mentionable) -> String
    { "Your drinks distracted \(user.mention()) and made \(user.mention()) do something they didn't intend to do..." }
    public func bartenderStopped(_ user: Mentionable) -> String
    { "\(user.mention()) got too drunk to do anything from your drinks" }
    public func bartenderFailed(_ user: Mentionable) -> String
    { "Your drinks failed to do anything to \(user.mention())" }
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
    public func nightHasFallen(seconds: Int) -> String {
        [
            "Night has fallen. Everyone heads to bed, weary after another stressful day. Night players: you have \(seconds) seconds to use your actions!",
            "Darkness prevails as everyone retires for the day. The fatigue is palpable. Players of the night, you hold a time slot of \(seconds) seconds to wield your actions!",
            "The shroud of night descends. Our brave participants retreat to slumber, tired from the day's exploits. Tis time for the night players to shine, you've got \(seconds) seconds to execute your moves!",
            "As the veil of night drops, all are off to their chambers, exhausted from today's trials. Players thriving in midnight's ascendance, your \(seconds)-second countdown to act commences now!",
            "The day is done and darkness is upon us. Everyone surrenders to fatigue and retreats for some rest. But for night players, you have a window of \(seconds) seconds to demonstrate your skills!",
            "Nightfall has arrived and all weary souls retreat to their beds. Night agents, the spotlight is yours - you have \(seconds) brief seconds to strategize and act!",
            "The canvas of black stretches across the sky, and restless heads hit pillows. All eyes are on you night players - you're on a \(seconds)-second ticking clock to make your move!",
        ].randomElement()!
    }
    public var villagersGather: String {
        [
          "The next morning, the villagers convene in the town's heart.",
          "When morning comes, the villagers assemble in the village square.",
          "As the new day begins, the villagers gather in the center of the village.",
          "The villagers collect in the village center with the break of dawn.",
          "The villagers gather the next morning in the village center.",
        ].randomElement()!
    }
    public func itIsDaytime(seconds: Int) -> String {
        [
            "It is now day time. All of you have \(seconds) seconds to make your accusations, defenses, claim roles, or just talk.",
            "It's now daytime. You all have a minute to make any accusations, defenses, claim your roles, or just converse.",
            "The day has begun. You each have \(seconds) seconds to voice your accusations, establish your defenses, claim roles, or engage in conversation.",
            "Daylight is here. There's \(seconds) seconds for everyone to accuse, defend, declare roles, or just chat.",
            "It's day break time. You've all got a minute for accusations, defenses, role-claims or just plain conversation.",
            "The sun is up. A \(seconds)-second window has begun for you to make any accusations or defenses, state your roles, or simply discuss.",
            "Now begins the day. Each one of you has a span of \(seconds) seconds to present accusations, make defenses, declare roles, or just have casual talk.",
            "Day has dawned. Everyone has one minute to accuse, defend, present roles, or go for a general chat."
        ].randomElement()!
    }
    public func dayTimeRunningOut(seconds: Int) -> String {
        "It is the afternoon; you have \(seconds) seconds remaining before voting begins."
    }
    public func eveningDraws(seconds: Int) -> String {
        "Evening draws near, and it's now possible to nominate people (or skip). We will proceed in \(seconds) seconds."
    }
    public let nominateSkip = "Skip Nominations"
    public let duskDrawsSkip = "The people have decided to skip voting tonight."
    public let duskDrawsVoting = "It's getting dark... let's go through the nominations!"
    public let nominationTitle = "Nominate people (or don't!)"
    public func nominationEndingSoonTitle(seconds: Int) -> String {
        "\(seconds) seconds remain!"
    }
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
    public let detectiveAction = "Time to investigate somewhere tonight!"
    public let gaPrompt = "Choose someone to protect"
    public let seerPrompt = "Choose someone to see their role"
    public let oraclePrompt = "Choose someone to see what role they are not (from roles that are in the game)"
    public let cpPrompt = "Choose someone to visit during the night and give them cookies"
    public let goosePrompt = "Choose someone to goose tonight!"
    public let detectivePrompt = "Choose somewhere to visit tonight!"
    public let detectiveNothingHere = "Nothing to learn from this place. Perhaps somewhere else?"
    public let detectiveCouldntInvestigate = "You had issues investigating."
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
    public func joinedParty(who: Mentionable) -> String {
        "\(who.mention()) has joined the party!"
    }
    public let setupRequired = "You need to setup again, since a new player joined"
    public let leaveJoinQueue = "You have left the leave queue"
    public let addedLeaveQueue = "You have been added to the leave queue! You will leave when the current game is over"
    public let notInParty = "You're not in the party!"
    public let leftParty = "You have left the party!"
    public let nobodyVoted = "Nobody voted. Welp."
    public let voteWasTie = "The vote was a tie, nobody's being exiled tonight!"
    public let mustBePartyLeader = "You must be the party leader to do that!"
    public let gameAlreadyInProgress = "A game is already in progress!"
    public let atLeastFourPeopleNeeded = "You need at least 4 people to start playing!"
    public let gameHasBeenSetUp = "You're all set to go! You can start playing now."
    public let lobbyNotInRightState = "The lobby isn't in the right state for that"
    public let gameHasBeenUnSetUp = "The game has been un set up!"
    public let mustSetUpBeforeStarting = "You need to setup before you can start"
    public let gameHasBeenStarted = "A game has been started!"
    public let targetNotInParty = "That person isn't in the party!"
    public let headerMinimumPlayerCount = "Minimum Player Count"
    public let headerMaximumRoleCount = "Maximum Role Count"
    public let headerTeam = "Team"
    public let headerRoles = "Roles"
    public let mustBeAliveToVote = "You aren't alive to vote!"
    public let voteHasBeenRecorded = "Your votes have been recorded!"
    public let roleNotFound = "I couldn't find a role with that name!"
    public let bartenderAction = "Time to visit someone's house and give them drinks!"
    public let bartenderPrompt = "Pick someone to visit tonight."
    public let inebriatedFailureDM = "*hic*, you couldn't do anything *hic* tonight because you were *hic* drunk"
    public let gameCreated = "A game has been created! Everyone else, come join on in!"
    public let joinGame = "Join Game"
    public let assigningRoles = "Assigning roles..."
    public let readRoles = "Read the roles!"
    public let gameStarting = "The game is starting!"
    public let resumed = "The game is continuing!"

    public init()
    {

    }
    public func drVisitAlso(who: Mentionable) -> String {
        "You died because you were visiting \(who.mention()), but unfortunately, a werewolf was visiting them too!"
    }
    public func nightStatus(who: Mentionable, role: Role, alive: Bool) -> String {
        if alive {
            return "🙂 \(who.mention())"
        } else {
            return "💀 \(who.mention()) (was a \(role.emoji) \(roleName(role)))" // TODO: should we show people's roles when they die?
        }
    }
    public func beholderSeer(who: Mentionable) -> String {
        return "The Seer is \(who.mention())"
    }
    public func getOverHere(_ list: String) -> String {
        return "\(list), get over here!"
    }
    public func talkThreadGetOverHere(_ list: String) -> String {
        return "\(list), this is your private talk thread! Say whatever you want about the game here."
    }
    public func evilTalkThreadGetOverHere(_ list: String) -> String {
        return "\(list), this is your private talk thread! Say whatever you want about the game here. You are all evil!"
    }
    public func exilingTitle(who: Mentionable) -> String {
        return "Looks like we're exiling \(who.mention()) tonight! Bye-bye!"
    }
    public func notExilingTitle(who: Mentionable) -> String {
        return "Looks like we're not exiling \(who.mention()) tonight!"
    }
    public func votingPersonTitle(who: Mentionable) -> String {
        return "Are we voting out \(who.mention()) tonight? You have 15 seconds to vote."
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
        case .detective:
            return "You are the town's detective, trying to figure out who the criminals are. Every night, you can choose a place to investigate, which will give you a clue."
        case .bartender:
            return "You are the town's bartender! After hours, you can go to someone's house and give them a personal drink! Being drunk might make someone act silly, or pass out entirely. If you're out from home, and the werewolf tries to kill you, you'll survive because you weren't home. If the werewolves kill someone they're visiting, they'll kill you as well."
        }
    }
    public func strategyBlurb(for role: Role) -> String {
        switch role {
        case .villager:
            return "While you may not have any abilities, your unsuspectibility is also your strength! All you can rely on are your social skills to figure out who to exile."
        case .werewolf:
            return "Kill people who are the biggest threat to you first, such as seers, pacifists and guardian angels. Claim a role that is as believable as possible, such as innocent, instead of roles which are easily disprovable such as seer."
        case .guardianAngel:
            return "Try and protect people that you know may be targeted by the werewolves, such as the seer! If you don't know who to protect, you can always protect yourself. Be careful of protecting evil werewolves, though! "
        case .seer:
            return "Make sure that other people don't out themselves before you out them! This will help you prove to them that you are the seer."
        case .beholder:
            return "As the beholder, you can pave the way for the seer! Say who they are before they out themselves and you'll establish a bond of trust between you two. But, you might lure the werewolves to them."
        case .jester:
            return "Being the jester is a balancing act: act suspicious enough to get exiled, but don't go overboard, or the village might suspect you of being the jester!"
        case .cookiePerson:
            return "Announce who you're visiting in the day, so that if you die overnight, the village knows who's responsible!"
        case .furry:
            return "If the werewolves claim to be you, you know who they are! But, good luck convincing everyone else that you aren't a werewolf."
        case .innocent:
            return "Make sure the townspeople don't try to exile you! If someone tries to exile you and doesn't die, you know that they are evil."
        case .pacifist:
            return "With you in the mix, the townspeople will be protected from wrongly exiling others. This lets you all be more carefree in exiling people! But not too carefree, it's not guaranteed."
        case .goose:
            return "If someone says that they're going to do something, you can goose them and cause chaos!"
        case .cursed:
            return "If you can figure out who the werewolf is whilst they're still alive, you can help lie on their behalf to make their story more believable. Don't go too hard, or you might be suspected of being evil, though!"
        case .oracle:
            return "Make sure that other people don't out themselves before you tell them what they're not! This will help you prove to them that you are the oracle."
        case .bartender:
            return "You win with the village, so try and inebriate the werewolves! But, be careful not to confuse the seer."
        case .detective:
            return "Investigate as much as you can!"
        }
    }
    public func clue(_ clue: ClueMessage) -> String {
        switch clue {
        case .libraryIsEvil(let a, let b):
            "You see someone checking out an evil book from the library, but aren't sure who it is. **Either \(a.mention()) or \(b.mention()) is evil.**"
        case .librarySeerOrBeholder(let a, let b):
            "You see someone checking out a psychic book from the library, but aren't sure who it is. **Either \(a.mention()) or \(b.mention()) is the Seer or the Beholder.**"
        case .libraryCookiePerson(let a, let b):
            "You smell someone with cookies in the library, but aren't sure who it is. **Either \(a.mention()) or \(b.mention()) is the Cookie Person.**"
        case .barIsEvil(let a, let b, let c):
            "You see someone with a knife in the bar, but it's not clear who they are. **Either \(a.mention()), \(b.mention()), or \(c.mention()) is evil.**"
        case .barGuardianAngelOrInnocent(let a):
            "Someone in the bar has a heavenly aura to them, but you aren't sure who they are. **Either \(a.mention()) is the Guardian Angel or Innocent.**"
        case .barVillager(let a, let b):
            "Someone looked extremely ordinary. You forgot their exact details. **Either \(a.mention()) or \(b.mention()) is a Villager.**"
        case .warehouseIsEvil(let a, let b):
            "In the abandoned warehouse, you see someone plotting in the shadows. **Either \(a.mention()) or \(b.mention()) is evil.**"
        case .warehouseJester(let a, let b):
            "In the abandoned warehouse, you hear someone jesting loudly. **Either \(a.mention()) or \(b.mention()) is the Jester.**"
        case .warehouseOracle(let a, let b):
            "You see an old advertisement for an oracle with a vaguely familiar face. **Either \(a.mention()) or \(b.mention()) is the Oracle.**"
        case .villageCenterIsEvil(let a, let b, let c):
            "You overhear someone discussing murder plans by the fountain. **Either \(a.mention()), \(b.mention()), or \(c.mention()) is evil.**"
        case .villageCenterPacifist(let a, let b):
            "There's signs of tampering in the execution centre. **Either \(a.mention()) or \(b.mention()) is the Pacifist.**"
        case .villageCenterFurry(let a, let b, let c):
            "You see someone donning a fursuit in the woods. **Either \(a.mention()), \(b.mention()), or \(c.mention()) is a Furry.**"
        case .villageCenterInnocent(let a, let b):
            "Some people were really nice to you today. **Either \(a.mention()) or \(b.mention()) is the Innocent.**"
        case .villageCenterBeholder(let a, let b):
            "You overhear people discussing Seer training. **Either \(a.mention()) or \(b.mention()) is the Beholder.**"
        case .villageCenterJester(let a, let b):
            "Someone is juggling, menacingly. **Either \(a.mention()) or \(b.mention()) is the Jester.**"
        case .villageCenterCookiePerson(let a, let b):
            "You longingly gaze at the cookie shop from the village square and see someone inside. **Either \(a.mention()) or \(b.mention()) is the Cookie Person.**"
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
        case .bartender:
            return "Bartender"
        case .detective:
            return "Detective"
        }
    }
    public func roleSummary(_ role: Role) -> String {
        switch role {
        case .villager: "has no special abilities"
        case .werewolf: "kills one person a night"
        case .guardianAngel: "protects one person a night from being killed"
        case .seer: "can learn the role of one person a night"
        case .beholder: "knows who the Seer is"
        case .jester: "wants to get exiled"
        case .cookiePerson: "can visit people and know they aren't evil if they survive the visit"
        case .furry: "appears as a werewolf to the Seer"
        case .innocent: "the first person to nominate the Innocent gets smitten if they aren't evil"
        case .pacifist: "has a chance to save wrongly exiled people"
        case .goose: "randomises people's targets, gets violent when werewolves are dead"
        case .cursed: "turns into a werewolf when the werewolves die"
        case .oracle: "can learn one role someone is not every night"
        case .bartender: "can inebriate someone every night"
        case .detective: "can get a clue every night"
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
}

public struct TokiPona: I18n {
    public func laundrypersonStart(_ p1: Mentionable, _ p2: Mentionable, _ role: Role) -> String { "sina sona e ni: wan lon kulupu pi \(p1.mention()) en \(p2.mention()) li \(roleName(role))." }
    public func gossip(_ p1: Mentionable, _ p2: Mentionable, _ p3: Mentionable) -> String { "sina sona e ni: wan lon kulupu pi \(p1.mention()) en \(p2.mention()) en \(p3.mention()) li ike!" }
    public func librarianStart(_ p1: Mentionable, _ p2: Mentionable, _ role: Role) -> String { "sina sona e ni: wan lon kulupu pi \(p1.mention()) en \(p2.mention()) li \(roleName(role))." }

    static var gooseDeathItems: [String] {
        [
            "ilo kipisi jaki",
            "len kule",
            "pan",
            "pilin ike",
            "linja telo"
        ]
    }

    public func gooseKillMessage(who: Mentionable) -> String { "waso li alasa moli e \(who.mention()) kepeken \(TokiPona.gooseDeathItems.randomElement()!)..." }
    public func werewolfKillMessage(who: Mentionable) -> String { "soweli mun li alasa moli e \(who.mention())..." }
    public func visitedWerewolf(who: Mentionable) -> String { "\(who.mention()) li tawa tomo pi soweli mun, pakala..." }
    public func visitedWerewolfEaten(who: Mentionable) -> String { "\(who.mention()) li kama moku!" }
    public func visitedWerewolfProtected(who: Mentionable) -> String { "pona a! jan awen sewi li awen e \(who.mention())!" }
    public func visitedPersonBeingVisitedByWerewolf(who: Mentionable, visiting: Mentionable) -> String { "\(who.mention()) li tawa tomo pi \(visiting.mention()). ike la, soweli mun li tawa tomo sama!" }
    public func visitedPersonBeingVisitedByWerewolfEaten(who: Mentionable) -> String { "soweli mun li jo e moku kin! \(who.mention()) li kama moku a!" }
    public func visitedPersonBeingVisitedByWerewolfProtected(who: Mentionable) -> String { "tenpo ante la soweli mun li jo e moku kin. taso tenpo ni la jan awen sewi li awen e \(who.mention())!" }
    public func pacifistIntervention(who: Mentionable) -> String { "jan pi utala ala li weka e \(who.mention()) tan tomo moli! ona li moli ala!" }
    public func nominatedInnocent(who: Mentionable) -> String { "\(who.mention()) li wile weka e jan pi ike ala! ni li ike suli tawa kulupu sewi! ona li kama moli tan ni. pakala." }
    public func protectedWerewolf(who: Mentionable) -> String { "\(who.mention()) li awen e soweli mun. taso wawa ike pi soweli mun li moli e ona! pakala." }
    public func wasA(_ role: Role) -> String { "li \(role.emoji) \(roleName(role))" }
    public func check(who: Mentionable, is role: Role) -> String { "\(who.mention()) li \(role.emoji) \(roleName(role))!" }
    public func check(who: Mentionable, isNot role: Role) -> String { "\(who.mention()) li \(role.emoji) \(roleName(role)) ala!" }
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
        }
    }
    public func youAreNotA(_ role: Role) -> String {
        "sina \(roleName(role)) ala!"
    }
    public func youAreGoingToInvestigate(_ user: Mentionable) -> String
    { "\(user.mention()) la sina alasa sona." }
    public func locationName(_ location: DetectiveLocations) -> String {
        switch location {
        case .library:
            "tomo lipu"
        case .bar:
            "tomo pi telo nasa"
        case .warehouse:
            "tomo poki majuna"
        case .villageSquare:
            "ma suli pi ma tomo"
        }
    }
    public func youAreGoingToInvestigate(_ location: DetectiveLocations) -> String {
        switch location {
        case .library:
            "sina tawa tomo lipu li alasa lon ona."
        case .bar:
            "sina alasa sona e sona tan tomo pi telo nasa."
        case .warehouse:
            "sina lukin lon tomo poki majuna."
        case .villageSquare:
            "sina lukin lon ma suli."
        }
    }
    public func youAreGoingToFreeze(_ user: Mentionable) -> String
    { "tenpo mun la sina kama lete e \(user.mention())!" }
    public func youAreGoingToKill(_ user: Mentionable) -> String
    { "mun la sina kama moli e \(user.mention())!" }
    public func youAreGoingToProtect(_ user: Mentionable) -> String
    { "sina awen e \(user.mention())!" }
    public func youAreGoingToGiveCookies(to user: Mentionable) -> String
    { "tenpo ni la sina pana e pan suwi tawa \(user.mention())!" }
    public func youAreGoingToGoose(_ user: Mentionable) -> String
    { "sina waso e \(user.mention())!" }
    public func hasBeenRemoved(_ user: Mentionable) -> String
    { "\(user.mention()) li weka tan kulupu pali" }
    public func hasBeenPromoted(_ user: Mentionable) -> String
    { "\(user.mention()) li kama lawa pi kulupu musi!" }
    public func youAreGoingToInebriate(_ user: Mentionable) -> String
    { "sina pana e telo tawa \(user.mention())!"}
    public func bartenderRandomised(_ user: Mentionable) -> String
    { "telo sina li nasa e \(user.mention()) li nasa e pali ona..."}
    public func bartenderStopped(_ user: Mentionable) -> String
    { "telo sina li nasa e \(user.mention()) la ona li ken ala pali"}
    public func bartenderFailed(_ user: Mentionable) -> String
    { "telo sina li nasa ala e \(user.mention())"}
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
    public func joinedParty(who: Mentionable) -> String {
        "\(who.mention()) li kama kulupu a!"
    }
    public let peopleLeftParty = "jan li weka tan kulupu!"
    public func nightHasFallen(seconds: Int) -> String {
        "tenpo pimeja li kama. jan ale li tawa supa lape li pilin pi wawa ala. jan musi pi tenpo pimeja o, pali lon tenpo pimeja ni a!"
    }
    public let villagersGather = "tenpo suno la, jan li kama lon tomo toki."
    public func itIsDaytime(seconds: Int) -> String {
        "sina ale li jo e tenpo lili tawa ni: toki utala, toki awen, toki pi pali sina, anu toki pona."
    }
    public func dayTimeRunningOut(seconds: Int) -> String {
        "tenpo li kama lili a! tenpo kama pi weka lili la utala pi wile weka li open."
    }
    public func eveningDraws(seconds: Int) -> String {
        "tenpo pimeja li kama la, sina ken open weka e jan. tenpo li tawa la, sina ken alasa weka e jan."
    }
    public let nominateSkip = "alasa ala weka"
    public let duskDrawsSkip = "kulupu li wile ala alasa weka."
    public let duskDrawsVoting = "tenpo mun li kama la, mi o open alasa weka a!"
    public let nominationTitle = "o alasa weka e jan!"
    public func nominationEndingSoonTitle(seconds: Int) -> String {
        "o alasa weka e jan! tenpo weka li kama pini!"
    }
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
    public let detectiveAction = "o alasa lon ma ni!"
    public let gaPrompt = "sina wile awen e jan seme?"
    public let seerPrompt = "sina wile sona e pali pi jan seme?"
    public let oraclePrompt = "sina wile sona e pali ala pi jan seme?"
    public let cpPrompt = "sina wile pana e pan tawa jan seme?"
    public let goosePrompt = "sina wile waso e jan seme?"
    public let detectivePrompt = "sina wile alasa sona lon ma seme?"
    public let detectiveNothingHere = "ma ni li pana ala sona. o alasa lon ma ante."
    public let detectiveCouldntInvestigate = "pakala li pini e alasa sina."
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
    public let nobodyVoted = "wile weka li pana ala. a."
    public let voteWasTie = "wile weka pi mute sama li lon la, mi ken ala sona e wile weka suli. jan ala li weka tan kulupu."
    public let mustBePartyLeader = "sina nanpa wan lon kulupu ala la sina ken ala ni."
    public let gameAlreadyInProgress = "ni li ken ala tan ni: musi li lon a!"
    public let atLeastFourPeopleNeeded = "musi la sina wile e kulupu 4 anu mute."
    public let gameHasBeenSetUp = "musi li ken open a!"
    public let lobbyNotInRightState = "tenpo ni la kulupu li ken ala ni"
    public let gameHasBeenUnSetUp = "ken pi open musi li weka a!"
    public let mustSetUpBeforeStarting = "sina wile open musi la o /setup e musi"
    public let gameHasBeenStarted = "musi li kama open!"
    public let targetNotInParty = "ona li lon ala kulupu musi!"
    public let headerMinimumPlayerCount = "suli open (kulupu li suli ni la ijo ni li ken lon)"
    public let headerMaximumRoleCount = "suli pini (kulupu pi ijo ni li ken nanpa ni anu lili taso)"
    public let headerTeam = "kulupu"
    public let headerRoles = "ken pali"
    public let mustBeAliveToVote = "sina moli la sina ken ala pana e wile weka sina!"
    public let voteHasBeenRecorded = "mi sona e wile weka sina!"
    public let roleNotFound = "mi sona ala e pali pi nimi ni!"
    public let bartenderAction = "o tawa tomo a! sina pana e telo nasa sina tawa kulupu ona."
    public let bartenderPrompt = "sina wile tawa e tomo seme?"
    public let inebriatedFailureDM = "*a*, sina ken ala pali *a* lon mun tan ni: sina *a* nasa tan telo *a*"
    public let gameCreated = "musi li kama lon a! ale kulupu o, kama tawa musi ni a!"
    public let joinGame = "o kama musi a!"
    public let assigningRoles = "mi pana e pali..."
    public let readRoles = "o lukin e pali a!"
    public let gameStarting = "musi li open a!"
    public let resumed = "musi li awen tawa a!"

    public init()
    {

    }
    public func drVisitAlso(who: Mentionable) -> String {
        "You died because you were visiting \(who.mention()), but unfortunately, a werewolf was visiting them too!"
    }
    public func nightStatus(who: Mentionable, role: Role, alive: Bool) -> String {
        if alive {
            return "🙂 \(who.mention())"
        } else {
            return "💀 \(who.mention()) (li \(role.emoji) \(roleName(role)))" // TODO: should we show people's roles when they die?
        }
    }
    public func beholderSeer(who: Mentionable) -> String {
        return "jan lukin li \(who.mention())"
    }
    public func getOverHere(_ list: String) -> String {
        return "\(list), o kama ni!"
    }
    public func talkThreadGetOverHere(_ list: String) -> String {
        return "\(list), ni li tomo toki pi sina tu a! sina ken toki lon tomo ni a!"
    }
    public func evilTalkThreadGetOverHere(_ list: String) -> String {
        return "\(list), ni li tomo toki pi sina ale a! sina ale li wile moli e ma tomo a!"
    }
    public func exilingTitle(who: Mentionable) -> String {
        return "lukin la, jan li wile weka e \(who.mention())! tawa pona a!"
    }
    public func notExilingTitle(who: Mentionable) -> String {
        return "lukin la, jan li wile ala weka e \(who.mention())!"
    }
    public func votingPersonTitle(who: Mentionable) -> String {
        return "sina wile ala wile weka e \(who.mention())? tenpo 15s li lon."
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
        case .detective:
            return "sina jan alasa sona pi ma ni. sina alasa e ijo ike. mun la sina ken alasa sona lon tomo wile."
        case .bartender:
            return "sina tan pi telo nasa tawa tomo ni! tenpo pi tomo pali sina li pini la sina ken tawa tomo ante li ken pana e telo nasa tawa ona. telo nasa li ken nasa e pali ona li ken pini e pali ona. soweli li tawa tomo sina la, sina tawa jan ante la, sina moli ala! sina en soweli mun li lon tomo sama la, ona li moli kin e sina."
        }
    }
    public func strategyBlurb(for role: Role) -> String {
        switch role {
        case .villager:
            return "sina jo ala e pali la sina lili tawa kulupu ike. ni li wawa sina a! o kepeken e ken toki sina tawa alasa sona a!"
        case .werewolf:
            return "jan li ken pana sona e ike sina la o weka e ona a! sina wile e ni: jan li sona ala e powe sina. ni la, o toki ala e ni: sina jan lukin anu jan awen sewi. sina toki e ni la, jan li ken sona e ike sina."
        case .guardianAngel:
            return "kulupu ike li wile weka e jan pona wawa la o awen e ona! sina sona ala e jan awen la o awen e sina a! sina awen e jan ike la sina li ken kama moli a!"
        case .seer:
            return "jan li toki ala e pali ona la sina toki e pali ona la jan li sona e ni: sina ken kama sona e pali ona a!"
        case .beholder:
            return "sina sona e jan lukin a! sina toki e ni la ona li sona e ni: sina jan lukin lukin a! taso, sona ni li ken pona tawa kulupu ike kin."
        case .jester:
            return "pali pi jan nasa li pali meso a! sina pona lukin la jan li weka ala e sina. sina ike suli lukin la jan li sona e nasa sina. sina ike meso lukin la jan li weka e sina a!"
        case .cookiePerson:
            return "suno la o toki e tawa mun sina a! sina kama moli la kulupu li sona e tan moli a!"
        case .furry:
            return "soweli mun li wile kepeken e len sina la sina sona e ona a! taso kulupu pona li ken pilin e ni: sina soweli mun."
        case .innocent:
            return "kulupu pi ma tomo o weka ala e sina a! ona li weka e sina la ona li kama moli. jan li wile weka e sina li moli ala la ona li jan ike a!"
        case .pacifist:
            return "sina lon la weka pakala pi jan pona li ken kama pini. ni la sina ken weka kepeken sona lili a! taso, ken la pini li lon ala!"
        case .goose:
            return "jan li toki e pali ona la, sina ken nasa waso e pali ona!"
        case .cursed:
            return "sina sona e soweli mun la o toki powe o wawa e pali ona. taso sina pali ike suli la kulupu tomo li sona e ike sina li ken weka e sina a!"
        case .oracle:
            return "jan li toki ala e pali ona la sina toki e pali ala ona la jan li sona e ni: sina ken kama sona e pali ona a!"
        case .bartender:
            return "kulupu tomo li awen la sina awen kin. ni la o nasa e kulupu ike! taso, o nasa ala e jan lukin..."
        case .detective:
            return "o alasa sona lon ma mute a!"
        }
    }
    public func clue(_ clue: ClueMessage) -> String {
        switch clue {
        case .libraryIsEvil(let a, let b):
            "sina lukin e ni: jan li lukin e lipu ike. **\(a.mention()) anu \(b.mention()) li ike.**"
        case .librarySeerOrBeholder(let a, let b):
            "sina lukin e ni: jan li lukin e lipu pi lukin wawa. **\(a.mention()) anu \(b.mention()) li jan lukin anu jan lukin lukin.**"
        case .libraryCookiePerson(let a, let b):
            "kon pi pan suwi li pona tawa sina. jan li pana e ona tawa jan lipu. **\(a.mention()) anu \(b.mention()) li jan pi pan suwi.**"
        case .barIsEvil(let a, let b, let c):
            "jan lon tomo nasa li jo e palisa kiki ike. **\(a.mention()) anu \(b.mention()) anu \(c.mention()) li ike.**"
        case .barGuardianAngelOrInnocent(let a):
            "jan lon tomo telo li pana e pona. **\(a.mention()) li jan awen sewi anu jan pi ike ala.**"
        case .barVillager(let a, let b):
            "jan li lon tomo pi telo nasa. ona li ante lukin ala. **\(a.mention()) anu \(b.mention()) li pali ala.**"
        case .warehouseIsEvil(let a, let b):
            "sina oko e jan ike lon pimeja pi tomo poki. **\(a.mention()) anu \(b.mention()) li ike.**"
        case .warehouseJester(let a, let b):
            "sina kute e kalama nasa lon tomo poki. **\(a.mention()) anu \(b.mention()) li jan nasa.**"
        case .warehouseOracle(let a, let b):
            "lipu majuna lon tomo poki li toki e ni: o kama tawa jan oko a! **\(a.mention()) anu \(b.mention()) li jan oko.**"
        case .villageCenterIsEvil(let a, let b, let c):
            "jan li toki e pali moli lon poka telo pi lukin pona. **\(a.mention()) anu \(b.mention()) anu \(c.mention()) li ike.**"
        case .villageCenterPacifist(let a, let b):
            "poki pi wile kulupu li nasa lukin. sina sona lili e ni: seme li pali e ni? **\(a.mention()) anu \(b.mention()) li jan pi utala ala.**"
        case .villageCenterFurry(let a, let b, let c):
            "jan li len e ona kepeken len soweli. **\(a.mention()) anu \(b.mention()) anu \(c.mention()) li jan soweli.**"
        case .villageCenterInnocent(let a, let b):
            "jan li pana e pona suli tawa sina. **\(a.mention()) anu \(b.mention()) li jan pi ike ala.**"
        case .villageCenterBeholder(let a, let b):
            "sina kute e ni: jan li toki e wawa lukin. **\(a.mention()) anu \(b.mention()) li jan lukin lukin.**"
        case .villageCenterJester(let a, let b):
            "jan li nasa lukin lon ma tomo. **\(a.mention()) anu \(b.mention()) li jan nasa.**"
        case .villageCenterCookiePerson(let a, let b):
            "sina lukin e tomo pi pan suwi li wile e pan suwi. sina lukin lili e jan pali ona. **\(a.mention()) anu \(b.mention()) li jan pi pan suwi.**"
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
        case .bartender:
            return "jan pi telo nasa"
        case .detective:
            return "jan pi alasa sona"
        }
    }
    public func roleSummary(_ role: Role) -> String {
        switch role {
        case .villager: "ona li pali ala."
        case .werewolf: "ona li moli e jan."
        case .guardianAngel: "ona li awen e jan."
        case .seer: "ona li ken sona e pali jan."
        case .beholder: "ona li sona e jan lukin."
        case .jester: "ona li wile kama weka."
        case .cookiePerson: "ona li ken tawa tomo jan. ona li moli ala la ona li sona e ike ala ona."
        case .furry: "jan lukin la ona li soweli lukin."
        case .innocent: "jan pona li wile weka e ona la wawa sewi li moli e ni."
        case .pacifist: "kulupu li wile weka e jan pona la ona li ken awen e ona."
        case .goose: "ona li nasa e wile pali jan. soweli li moli la ona li utala."
        case .cursed: "soweli li moli la ona li kama soweli."
        case .oracle: "ona li ken sona e pali ala jan."
        case .bartender: "ona li ken telo nasa e jan."
        case .detective: "ona li ken alasa e sona lili."
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
}

