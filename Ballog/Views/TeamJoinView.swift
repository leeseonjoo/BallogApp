import SwiftUI

struct TeamJoinView: View {
    @EnvironmentObject private var teamStore: TeamStore
    @AppStorage("currentTeamID") private var currentTeamID: String = ""
    @AppStorage("profileCard") private var storedCard: String = ""
    @Environment(\.dismiss) private var dismiss
    @State private var code: String = ""

    private var userCard: ProfileCard? {
        guard let data = storedCard.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(ProfileCard.self, from: data)
    }

    var body: some View {
        VStack {
            TextField("팀 코드", text: $code)
                .textFieldStyle(.roundedBorder)
                .padding()
            List(teamStore.teams) { team in
                Button {
                    join(team)
                } label: {
                    VStack(alignment: .leading) {
                        Text(team.name)
                            .font(.headline)
                        Text(team.region)
                        Text(team.trainingTime)
                            .font(.caption)
                    }
                }
            }
        }
        .navigationTitle("추천 팀")
    }

    private func join(_ team: Team) {
        guard code == team.code else { return }
        let member = TeamCharacter(
            name: userCard?.nickname ?? "나",
            imageName: userCard?.iconName ?? "soccer-player",
            isOnline: false
        )
        teamStore.addMember(member, to: team.id)
        currentTeamID = team.id.uuidString
        dismiss()
    }
}

#Preview {
    NavigationStack { TeamJoinView() }
}
