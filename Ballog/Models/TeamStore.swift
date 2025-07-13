import Foundation

final class TeamStore: ObservableObject {
    @Published var teams: [Team] = []
    
    private let teamsKey = "Teams"
    
    init() {
        loadTeams()
    }
    
    func addTeam(_ team: Team) {
        teams.append(team)
        saveTeams()
    }
    
    func updateTeam(_ team: Team) {
        if let index = teams.firstIndex(where: { $0.id == team.id }) {
            teams[index] = team
            saveTeams()
        }
    }
    
    func removeTeam(_ team: Team) {
        teams.removeAll { $0.id == team.id }
        saveTeams()
    }
    
    func addMember(_ member: TeamCharacter, to teamId: UUID) {
        if let index = teams.firstIndex(where: { $0.id == teamId }) {
            teams[index].members.append(member)
            saveTeams()
        }
    }
    
    func removeMember(_ member: TeamCharacter, from teamId: UUID) {
        if let index = teams.firstIndex(where: { $0.id == teamId }) {
            teams[index].members.removeAll { $0.id == member.id }
            saveTeams()
        }
    }
    
    func updateMember(_ member: TeamCharacter, in teamId: UUID) {
        if let teamIndex = teams.firstIndex(where: { $0.id == teamId }),
           let memberIndex = teams[teamIndex].members.firstIndex(where: { $0.id == member.id }) {
            teams[teamIndex].members[memberIndex] = member
            saveTeams()
        }
    }
    
    private func saveTeams() {
        if let data = try? JSONEncoder().encode(teams) {
            UserDefaults.standard.set(data, forKey: teamsKey)
        }
    }
    
    private func loadTeams() {
        if let data = UserDefaults.standard.data(forKey: teamsKey),
           let decodedTeams = try? JSONDecoder().decode([Team].self, from: data) {
            teams = decodedTeams
        }
    }
}
