import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("profileMessage") private var profileMessage: String = "하나가 되어 정상을 향해가는 순간\n힘들어도 극복하면서 자신있게!! 나아가자!!"
    @AppStorage("profileCard") private var storedCard: String = ""
    
    private var card: ProfileCard? {
        guard let data = storedCard.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(ProfileCard.self, from: data)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignConstants.sectionSpacing) {
                    // Profile Card Section
                    if let card = card {
                        profileCardSection(card: card)
                    }
                    
                    // Profile Message Section
                    profileMessageSection
                    
                    // Settings Section
                    settingsSection
                }
                .padding(DesignConstants.horizontalPadding)
            }
            .background(Color.pageBackground)
            .navigationTitle("프로필")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("완료") {
                        dismiss()
                    }
                    .foregroundColor(Color.primaryBlue)
                }
            }
        }
    }
    
    private func profileCardSection(card: ProfileCard) -> some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            HStack {
                Text("내 캐릭터")
                    .font(.title2.bold())
                    .foregroundColor(Color.primaryText)
                Spacer()
            }
            
            ProfileCardView(card: card, showIcon: true, iconOnRight: false, showRecordButton: false)
        }
    }
    
    private var profileMessageSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            HStack {
                Text("응원 문구")
                    .font(.title2.bold())
                    .foregroundColor(Color.primaryText)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: DesignConstants.smallSpacing) {
                Text("나만의 응원 문구를 작성해보세요")
                    .font(.subheadline)
                    .foregroundColor(Color.secondaryText)
                
                TextEditor(text: $profileMessage)
                    .frame(minHeight: 120)
                    .padding(DesignConstants.cardPadding)
                    .background(
                        RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                            .fill(Color.cardBackground)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                            .stroke(Color.borderColor, lineWidth: 1)
                    )
            }
        }
    }
    
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            HStack {
                Text("프로필 설정")
                    .font(.title2.bold())
                    .foregroundColor(Color.primaryText)
                Spacer()
            }
            
            VStack(spacing: DesignConstants.smallSpacing) {
                NavigationLink(destination: ProfileCardCreationView()) {
                    ProfileSettingsItem(
                        icon: "person.crop.circle",
                        title: "캐릭터 수정",
                        subtitle: "캐릭터 정보 변경"
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                ProfileSettingsItem(
                    icon: "bell.badge",
                    title: "알림 설정",
                    subtitle: "알림 관리"
                )
                
                ProfileSettingsItem(
                    icon: "lock.shield",
                    title: "개인정보 보호",
                    subtitle: "개인정보 관리"
                )
            }
        }
    }
}

struct ProfileSettingsItem: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: DesignConstants.spacing) {
            Image(systemName: icon)
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(Color.primaryBlue)
                .padding(DesignConstants.smallPadding)
                .background(
                    Circle()
                        .fill(Color.primaryBlue.opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color.primaryText)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(Color.secondaryText)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(Color.secondaryText)
        }
        .padding(DesignConstants.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                .fill(Color.cardBackground)
        )
    }
}

#Preview {
    NavigationStack { ProfileView() }
}
