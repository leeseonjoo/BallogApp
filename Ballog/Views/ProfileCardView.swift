import SwiftUI

struct ProfileCardView: View {
    let card: ProfileCard
    var showIcon: Bool = true
    /// When `true`, displays the icon on the trailing side of the card.
    var iconOnRight: Bool = false
    var showRecordButton: Bool = false
    @State private var isPressed = false

    var body: some View {
        VStack(spacing: DesignConstants.cardSpacing) {
            // Main Card Content
            HStack(alignment: .top, spacing: DesignConstants.spacing) {
                if showIcon && !iconOnRight {
                    characterIcon
                }
                
                VStack(alignment: .leading, spacing: DesignConstants.smallSpacing) {
                    // Nickname and Level Badge
                    HStack {
                        Text(card.nickname)
                            .font(.title2.bold())
                            .foregroundColor(Color.primaryText)
                        
                        Spacer()
                        
                        levelBadge
                    }
                    
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
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.cardBackground,
                            Color.cardBackground.opacity(0.8)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
        }
    }
    
    private var characterIcon: some View {
        Image(card.iconName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 80, height: 80)
            .padding(DesignConstants.smallPadding)
            .background(
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.primaryBlue.opacity(0.2),
                                Color.primaryBlue.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                Circle()
                    .stroke(Color.primaryBlue.opacity(0.3), lineWidth: 1)
            )
    }
    
    private var levelBadge: some View {
        let levelColor = getLevelColor(for: card.plapLevel)
        let levelText = getLevelText(for: card.plapLevel)
        
        return Text(levelText)
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: DesignConstants.smallCornerRadius)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                levelColor,
                                levelColor.opacity(0.8)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .shadow(color: levelColor.opacity(0.3), radius: 2, x: 0, y: 1)
    }
    
    private func getLevelColor(for level: String) -> Color {
        if level.contains("프로") {
            return Color.primaryRed
        } else if level.contains("세미프로") {
            return Color.primaryOrange
        } else if level.contains("아마추어") {
            return Color.primaryGreen
        } else if level.contains("비기너") {
            return Color.primaryBlue
        } else {
            return Color.secondaryText
        }
    }
    
    private func getLevelText(for level: String) -> String {
        if level.contains("프로") {
            return "PRO"
        } else if level.contains("세미프로") {
            return "SEMI"
        } else if level.contains("아마추어") {
            return "AMATEUR"
        } else if level.contains("비기너") {
            return "BEGINNER"
        } else {
            return "NONE"
        }
    }
}

#Preview {
    ProfileCardView(card: ProfileCard(iconName: "fan", nickname: "홍길동", birthdate: Date(), hasTeam: true, plapLevel: "비기너1", athleteLevel: "선출아님"))
}
