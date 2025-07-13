import SwiftUI

enum TeamRole: String, CaseIterable, Codable {
    case player = "플레이어"
    case coach = "코치"
    
    var description: String {
        switch self {
        case .player:
            return "팀에서 플레이어로 활동합니다"
        case .coach:
            return "팀의 코치로 활동합니다"
        }
    }
    
    var icon: String {
        switch self {
        case .player:
            return "figure.soccer"
        case .coach:
            return "person.2.circle"
        }
    }
}

struct RoleSelectionView: View {
    let team: Team
    let onRoleSelected: (TeamRole) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var selectedRole: TeamRole = .player
    
    var body: some View {
        NavigationStack {
            VStack(spacing: DesignConstants.largeSpacing) {
                // Team Info
                VStack(spacing: DesignConstants.smallSpacing) {
                    if let logoData = team.logo, let uiImage = UIImage(data: logoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.3.fill")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundColor(Color.secondaryText)
                    }
                    
                    Text(team.name)
                        .font(.title2.bold())
                        .foregroundColor(Color.primaryText)
                    
                    Text("팀에 참여할 역할을 선택해주세요")
                        .font(.subheadline)
                        .foregroundColor(Color.secondaryText)
                        .multilineTextAlignment(.center)
                }
                
                // Role Selection
                VStack(spacing: DesignConstants.spacing) {
                    ForEach(TeamRole.allCases, id: \.self) { role in
                        Button(action: { selectedRole = role }) {
                            HStack {
                                Image(systemName: role.icon)
                                    .foregroundColor(selectedRole == role ? .white : Color.primaryBlue)
                                    .font(.title2)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(role.rawValue)
                                        .font(.headline)
                                        .foregroundColor(selectedRole == role ? .white : Color.primaryText)
                                    
                                    Text(role.description)
                                        .font(.caption)
                                        .foregroundColor(selectedRole == role ? .white.opacity(0.8) : Color.secondaryText)
                                }
                                
                                Spacer()
                                
                                if selectedRole == role {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(DesignConstants.cardPadding)
                            .background(
                                RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                                    .fill(selectedRole == role ? Color.primaryBlue : Color.cardBackground)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                                    .stroke(selectedRole == role ? Color.primaryBlue : Color.borderColor, lineWidth: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                Spacer()
                
                // Join Button
                Button(action: {
                    onRoleSelected(selectedRole)
                    dismiss()
                }) {
                    Text("팀 참여하기")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.primaryBlue)
                        .cornerRadius(DesignConstants.cornerRadius)
                }
                .disabled(selectedRole == nil)
            }
            .padding(DesignConstants.horizontalPadding)
            .navigationTitle("역할 선택")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    RoleSelectionView(
        team: Team(name: "테스트 팀"),
        onRoleSelected: { _ in }
    )
} 