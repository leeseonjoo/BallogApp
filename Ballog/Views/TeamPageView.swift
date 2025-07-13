import SwiftUI

private enum TeamTab: String, CaseIterable {
    case manage = "팀 관리"
    case ranking = "팀 랭킹"
    case match = "매치 관리"
    case tactics = "전술"
}

struct TeamPageView: View {
    @State private var selection: TeamTab = .manage
    @EnvironmentObject private var teamStore: TeamStore
    @AppStorage("currentTeamID") private var currentTeamID: String = ""
    @AppStorage("hasTeam") private var hasTeam: Bool = true

    private var currentTeam: Team? {
        teamStore.teams.first { $0.id.uuidString == currentTeamID }
    }

    var body: some View {
        NavigationStack {
            if let team = currentTeam {
                VStack {
                    Picker("TeamTab", selection: $selection) {
                        ForEach(TeamTab.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    .padding()

                    switch selection {
                    case .manage:
                        TeamManagementView(team: team)
                    case .ranking:
                        TeamRankingView()
                    case .match:
                        MatchManagementView()
                    case .tactics:
                        TeamTacticsView()
                    }
                }
            } else {
                VStack(spacing: 16) {
                    if !hasTeam {
                        Text("팀에 가입해보세요")
                            .foregroundColor(.secondary)
                    }
                    TeamActionSelectionView()
                    if !teamStore.teams.isEmpty {
                        Text("추천 팀")
                            .font(.headline)
                        ForEach(teamStore.teams) { team in
                            NavigationLink(destination: TeamPreviewView(team: team)) {
                                VStack(alignment: .leading) {
                                    Text(team.name)
                                        .fontWeight(.bold)
                                    Text(team.region)
                                    Text(team.trainingTime)
                                        .font(.caption)
                                }
                            }
                        }
                    }
                    Spacer()
                }
            }
        }
        .ballogTopBar()
    }
}

#Preview {
    TeamPageView()
        .environmentObject(AttendanceStore())
        .environmentObject(TeamTrainingLogStore())
        .environmentObject(TeamTacticStore())
}

