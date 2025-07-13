import SwiftUI

struct TeamJoinView: View {
    @EnvironmentObject private var teamStore: TeamStore
    @AppStorage("currentTeamID") private var currentTeamID: String = ""
    @AppStorage("profileCard") private var storedCard: String = ""
    @Environment(\.dismiss) private var dismiss
    @State private var code: String = ""
    @State private var selectedRole: TeamRole = .player
    @State private var showRoleSelection = false
    @State private var selectedTeam: Team?

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
                    selectedTeam = team
                    showRoleSelection = true
                } label: {
                    HStack {
                        if let logoData = team.logo, let uiImage = UIImage(data: logoData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.3.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(Color.secondaryText)
                        }
                        
                        VStack(alignment: .leading) {
                            Text(team.name)
                                .font(.headline)
                            Text(team.region)
                            Text(team.trainingTime)
                                .font(.caption)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(Color.secondaryText)
                    }
                }
            }
        }
        .navigationTitle("추천 팀")
        .sheet(isPresented: $showRoleSelection) {
            RoleSelectionView(team: selectedTeam!, onRoleSelected: { role in
                selectedRole = role
                join(selectedTeam!)
            })
        }
    }

    private func join(_ team: Team) {
        guard code == team.code else { return }
        let member = TeamCharacter(
            name: userCard?.nickname ?? "나",
            imageName: userCard?.iconName ?? "soccer-player",
            isOnline: false,
            role: selectedRole
        )
        teamStore.addMember(member, to: team.id)
        currentTeamID = team.id.uuidString
        dismiss()
    }
}

#Preview {
    NavigationStack { TeamJoinView() }
}
