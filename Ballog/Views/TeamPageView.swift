import SwiftUI

private enum TeamTab: String, CaseIterable {
    case manage = "팀 관리"
    case training = "훈련일지/전술"
    case match = "매치 관리"
}

struct TeamPageView: View {
    @State private var selection: TeamTab = .manage
    @EnvironmentObject private var teamStore: TeamStore
    @AppStorage("currentTeamID") private var currentTeamID: String = ""
    @Binding var selectedTeam: Team?

    private var currentTeam: Team? {
        teamStore.teams.first { $0.id.uuidString == currentTeamID } ?? selectedTeam
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 상단 세그먼트
                Picker("TeamTab", selection: $selection) {
                    ForEach(TeamTab.allCases, id: \.self) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding(DesignConstants.horizontalPadding)
                .padding(.vertical, DesignConstants.verticalPadding)
                .background(Color.pageBackground)

                // 탭별 내용
                if let team = currentTeam {
                    switch selection {
                    case .manage:
                        TeamManagementView(team: team)
                    case .training:
                        TeamTacticsView()
                        // 팀 훈련일지 작성/전술 (필요시 TeamTrainingLogView 등 추가)
                    case .match:
                        MatchManagementView()
                        // 매치 관리(매치 잡기, 라인업, 통계, 팀 랭킹, 매너 평가, 스코어 동의 등)
                        // 필요시 TeamRankingView 등 추가
                    }
                } else {
                    Text("팀을 선택하거나 생성하세요.")
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
            .background(Color.pageBackground)
        }
    }
}

#Preview {
    TeamPageView(selectedTeam: .constant(nil))
        .environmentObject(AttendanceStore())
        .environmentObject(TeamTrainingLogStore())
        .environmentObject(TeamTacticStore())
        .environmentObject(TeamGoalStore())
}

