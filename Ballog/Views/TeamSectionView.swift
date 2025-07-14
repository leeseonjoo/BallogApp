import SwiftUI

struct TeamSectionView: View {
    @EnvironmentObject var teamStore: TeamStore
    @Binding var selectedTeam: Team?
    @State private var selectedTab = 0

    var body: some View {
        if teamStore.teams.isEmpty {
            TabView {
                TeamCreationView()
                    .tabItem { Label("팀 생성", systemImage: "plus.circle") }
                TeamJoinView()
                    .tabItem { Label("팀 조인", systemImage: "person.badge.plus") }
            }
        } else if let team = selectedTeam ?? teamStore.teams.first {
            TabView(selection: $selectedTab) {
                TeamManagementView(team: team)
                    .tabItem { Label("팀 관리", systemImage: "person.3") }
                    .tag(0)
                TeamGoalManagementView(team: team)
                    .tabItem { Label("목표 관리", systemImage: "target") }
                    .tag(1)
                TeamRankingView()
                    .tabItem { Label("팀 랭킹", systemImage: "crown") }
                    .tag(2)
                MatchManagementView()
                    .tabItem { Label("매치 관리", systemImage: "sportscourt") }
                    .tag(3)
                TeamTacticsView()
                    .tabItem { Label("전술", systemImage: "checkerboard.rectangle") }
                    .tag(4)
                TeamCalendarView()
                    .tabItem { Label("일정", systemImage: "calendar") }
                    .tag(5)
                FeedView()
                    .tabItem { Label("피드", systemImage: "bubble.left.and.bubble.right") }
                    .tag(6)
            }
            .toolbar {
                if teamStore.teams.count > 1 {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            ForEach(teamStore.teams) { t in
                                Button(t.name) { selectedTeam = t }
                            }
                        } label: {
                            Image(systemName: "list.bullet")
                        }
                    }
                }
            }
        }
    }
} 