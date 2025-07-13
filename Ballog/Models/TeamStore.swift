import Foundation

final class TeamStore: ObservableObject {
    @Published var teams: [Team] = []
    
    func add(_ team: Team) {
        teams.append(team)
    }
    
    func team(id: UUID) -> Team? {
        teams.first { $0.id == id }
    }
}
