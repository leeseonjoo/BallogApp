import SwiftUI

private enum TeamTab: String, CaseIterable {
    case manage = "팀 관리"
    case ranking = "팀 랭킹"
    case match = "매치 관리"
}

struct TeamPageView: View {
    @State private var selection: TeamTab = .manage

    var body: some View {
        VStack {
            Picker("TeamTab", selection: $selection) {
                ForEach(TeamTab.allCases, id: \.self) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            .padding()

            switch selection {
            case .manage:
                TeamManagementView_hae()
            case .ranking:
                TeamRankingView()
            case .match:
                MatchManagementView()
            }
        }
    }
}

#Preview {
    TeamPageView()
        .environmentObject(AttendanceStore())
        .environmentObject(TeamTrainingLogStore())
}

