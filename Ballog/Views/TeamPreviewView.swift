import SwiftUI

struct TeamPreviewView: View {
    let team: Team
    @State private var showJoinRequest = false
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: DesignConstants.smallSpacing) {
                Text(team.name)
                    .font(.largeTitle)
                    .padding(.top)
                
                HStack(spacing: 4) {
                    Image(systemName: "person.circle.fill")
                        .font(.caption)
                        .foregroundColor(Color.primaryBlue)
                    Text("생성자: \(team.creatorName)")
                        .font(.subheadline)
                        .foregroundColor(Color.secondaryText)
                }
            }
            
            TeamCharacterBoardView(members: team.members)
            
            // Join Request Button
            Button(action: { showJoinRequest = true }) {
                HStack {
                    Image(systemName: "person.badge.plus")
                    Text("팀 가입 신청")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.primaryBlue)
                .foregroundColor(.white)
                .cornerRadius(DesignConstants.cornerRadius)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .navigationTitle("팀 미리보기")
        .padding()
        .sheet(isPresented: $showJoinRequest) {
            TeamJoinRequestView(team: team)
        }
    }
}

#Preview {
    TeamPreviewView(team: Team(name: "샘플", region: "서울", members: [TeamCharacter(name: "A", imageName: "soccer-player", isOnline: true)]))
}
