import SwiftUI

struct TeamPreviewView: View {
    let team: Team
    var body: some View {
        VStack(spacing: 16) {
            Text(team.name)
                .font(.largeTitle)
                .padding(.top)
            TeamCharacterBoardView(members: team.members)
            Spacer()
        }
        .navigationTitle("팀 미리보기")
        .padding()
    }
}

#Preview {
    TeamPreviewView(team: Team(name: "샘플", region: "서울", members: [TeamCharacter(name: "A", imageName: "soccer-player", isOnline: true)]))
}
