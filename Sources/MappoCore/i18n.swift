protocol I18n {
    func roleName(_ role: Role) -> String
    func roleDescription(_ role: Role) -> String
    func timeOfYear(_ toy: TimeOfYear) -> String
    func nightTitle(_ toy: TimeOfYear, year: Int, day: Int) -> String
    func morningTitle(_ toy: TimeOfYear, year: Int, day: Int) -> String
    func votingTitle(numNominations: Int) -> String
    func getOverHere(_ list: String) -> String
    func beholderSeer(who: String) -> String

    var peopleJoinedParty: String { get }
    var peopleLeftParty: String { get }
    var nightHasFallen: String { get }
    var villagersGather: String { get }
    var itIsDaytime: String { get }
}

struct English: I18n {
    let peopleJoinedParty = "Some people have joined the party!"
    let peopleLeftParty = "Some people have joined the party!"
    let nightHasFallen = "Night has fallen. Everyone heads to bed, weary after another stressful day. Night players: you have 35 seconds to use your actions!"
    let villagersGather = "The villagers gather the next morning in the village center."
    let itIsDaytime = "It is now day time. All of you have at least 30 seconds to make your accusations, defenses, claim roles, or just talk."
    let eveningDraws = "Evening draws near, and it's now possible to start or skip nominations. Nominations will start or be skipped once a majority of people have indicated to do so."
    let nominateYes = "Nominate Someone"
    let nominateNo = "Don't Nominate Someone"
    let duskDrawsNobody = "Dusk draws near, and it looks like nobody's getting nominated tonight..."
    let duskDrawsNominating = "Dusk draws near, and the villagers gather to decide who they are nominating this evening..."
    let nominationTime = "Everyone has 15 seconds to nominate someone!"
    let nominationTitle = "Nominate people (or don't!)"
    let noNominations = "Oops, doesn't look like there's any nominees tonight... Off to bed it is, then."
    let voteYes = "Yes"
    let voteNo = "No"
    let timeToBed = "Dusk draws near, and it's time to get to bed... A little more discussion time (25 seconds) for you before that, though!"
    let jesterReminder = "Remember: get yourself exiled!"
    let aliveTitle = "Alive"

    func beholderSeer(who: String) -> String {
        return "The Seer is <@\(who)>"
    }
    func getOverHere(_ list: String) -> String {
        return "\(list), get over here!"
    }
    func exilingTitle(who: String) -> String {
        return "Looks like we're exiling <@\(who)> tonight! Bye-bye!"
    }
    func notExilingTitle(who: String) -> String {
        return "Looks like we're not exiling <@\(who)> tonight!"
    }
    func votingPersonTitle(who: String) -> String {
        return "Are we voting out <@\(who)> tonight? You have 15 seconds to vote."
    }
    func votingTitle(numNominations: Int) -> String {
        return "Let's go through all of the nominations! We have \(numNominations) of them tonight. We'll stop if and when we vote someone out."
    }
    func nightTitle(_ toy: TimeOfYear, year: Int, day: Int) -> String {
        return "Night of \(self.timeOfYear(toy)) of Year \(year) (Game Day \(day))"
    }
    func morningTitle(_ toy: TimeOfYear, year: Int, day: Int) -> String {
        return "Morning of \(self.timeOfYear(toy)) of Year \(year) (Game Day \(day))"
    }
    func timeOfYear(_ toy: TimeOfYear) -> String {
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
    func roleDescription(_ role: Role) -> String {
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
    func roleName(_ role: Role) -> String {
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
}
