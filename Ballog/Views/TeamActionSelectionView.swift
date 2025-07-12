import SwiftUI

struct TeamActionSelectionView: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            NavigationLink("팀 만들기") {
                TeamCreationView()
            }
            .buttonStyle(.borderedProminent)
            NavigationLink("팀에 조인하기") {
                TeamJoinView()
            }
            .buttonStyle(.bordered)
            Spacer()
        }
        .navigationTitle("팀 설정")
    }
}

#Preview {
    NavigationStack { TeamActionSelectionView() }
}
