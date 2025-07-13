import SwiftUI

struct TeamJoinView: View {
    @EnvironmentObject private var teamStore: TeamStore
    @AppStorage("currentTeamID") private var currentTeamID: String = ""
    
    var body: some View {
        List(teamStore.teams) { team in
            Button(team.name) {
                currentTeamID = team.id.uuidString
            }
        }
        .navigationTitle("추천 팀")
    }
}

#Preview {
    NavigationStack { TeamJoinView() }
}
