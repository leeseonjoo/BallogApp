import Foundation

final class TeamStore: ObservableObject {
    @Published var teams: [Team] = []
    
    func add(_ team: Team) {
        teams.append(team)
    }
    
    func team(id: UUID) -> Team? {
        teams.first { $0.id == id }
    }

    func addMember(_ member: TeamCharacter, to id: UUID) {
        guard let index = teams.firstIndex(where: { $0.id == id }) else { return }
        teams[index].members.append(member)
    }
}
