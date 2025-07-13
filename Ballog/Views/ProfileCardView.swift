import SwiftUI

struct ProfileCardView: View {
    let card: ProfileCard
    var showIcon: Bool = true
    /// When `true`, displays the icon on the trailing side of the card.
    var iconOnRight: Bool = false
    var showRecordButton: Bool = false

    var body: some View {
        VStack(spacing: DesignConstants.cardSpacing) {
            // Main Card Content
            HStack(alignment: .top, spacing: DesignConstants.spacing) {
                if showIcon && !iconOnRight {
                    characterIcon
                }
                
                VStack(alignment: .leading, spacing: DesignConstants.smallSpacing) {
                    // Nickname
                    Text(card.nickname)
                        .font(.title2.bold())
                        .foregroundColor(Color.primaryText)
                    
                    // Birthdate
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.caption)
                            .foregroundColor(Color.secondaryText)
                        Text(card.birthdate, style: .date)
                            .font(.subheadline)
                            .foregroundColor(Color.secondaryText)
                    }
                    
                    // Team Status
                    HStack(spacing: 4) {
                        Image(systemName: card.hasTeam ? "person.3.fill" : "person.3")
                            .font(.caption)
                            .foregroundColor(card.hasTeam ? Color.successColor : Color.secondaryText)
                        Text("소속팀: \(card.hasTeam ? "있음" : "없음")")
                            .font(.subheadline)
                            .foregroundColor(Color.secondaryText)
                    }
                    
                    // Plap Level
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(Color.primaryOrange)
                        Text("플랩 레벨: \(card.plapLevel)")
                            .font(.subheadline)
                            .foregroundColor(Color.secondaryText)
                    }
                    
                    // Athlete Level
                    HStack(spacing: 4) {
                        Image(systemName: "trophy.fill")
                            .font(.caption)
                            .foregroundColor(Color.primaryOrange)
                        Text("선출 여부: \(card.athleteLevel)")
                            .font(.subheadline)
                            .foregroundColor(Color.secondaryText)
                    }
                }
                
                Spacer()
                
                if showIcon && iconOnRight {
                    characterIcon
                }
            }
            
            // Record Button
            if showRecordButton {
                NavigationLink(destination: PersonalTrainingView()) {
                    HStack(spacing: DesignConstants.smallSpacing) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Color.primaryBlue)
                        Text("내 훈련일지 기록")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(Color.primaryBlue)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(Color.primaryBlue)
                    }
                    .padding(DesignConstants.cardPadding)
                    .background(
                        RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                            .fill(Color.primaryBlue.opacity(0.1))
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(DesignConstants.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                .fill(Color.cardBackground)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
    
    private var characterIcon: some View {
        Image(card.iconName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 80, height: 80)
            .padding(DesignConstants.smallPadding)
            .background(
                Circle()
                    .fill(Color.primaryBlue.opacity(0.1))
            )
    }
}

#Preview {
    ProfileCardView(card: ProfileCard(iconName: "fan", nickname: "홍길동", birthdate: Date(), hasTeam: true, plapLevel: "비기너1", athleteLevel: "선출아님"))
}
