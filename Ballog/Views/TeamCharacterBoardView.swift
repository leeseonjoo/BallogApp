import SwiftUI

private enum Layout {
    static let padding = DesignConstants.horizontalPadding
}

struct TeamCharacter: Identifiable, Codable {
    enum Pose: String, CaseIterable, Codable {
        case wave
        case victory
        case thumbsUp
        case peace

        var emoji: String {
            switch self {
            case .wave: return "\u{1F44B}" // 👋
            case .victory: return "\u{270C}\u{FE0F}" // ✌️
            case .thumbsUp: return "\u{1F44D}" // 👍
            case .peace: return "\u{270C}\u{FE0F}" // ✌️
            }
        }
    }

    var id = UUID()
    var name: String
    var imageName: String
    var isOnline: Bool
    var pose: Pose = .wave
    var recentAttendance: Bool = true
    var trainingLogs: Int = 0
    var role: TeamRole = .player
}

struct TeamCharacterBoardView: View {
    let members: [TeamCharacter]
    var onSelect: (TeamCharacter) -> Void = { _ in }
    var backgroundImage: String?
    @State private var showBackgroundOptions = false
    @State private var selectedBackground: BackgroundType = .livingRoom

    enum BackgroundType: String, CaseIterable {
        case livingRoom = "living_room"
        case footballField = "football_field"
        
        var displayName: String {
            switch self {
            case .livingRoom: return "거실"
            case .footballField: return "축구장"
            }
        }
        
        var imageName: String? {
            switch self {
            case .livingRoom: return nil
            case .footballField: return nil
            }
        }
    }

    private var columns: [GridItem] {
        let count = min(members.count, 4)
        return Array(repeating: GridItem(.flexible(), spacing: 16), count: max(count, 3))
    }
    
    private var rows: Int {
        let memberCount = members.count
        if memberCount <= 4 { return 1 }
        if memberCount <= 8 { return 2 }
        return 3
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            // Header with Team Name and Background Options
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("팀 멤버")
                        .font(.title2.bold())
                        .foregroundColor(Color.primaryText)
                    Text("\(members.count)명의 멤버")
                        .font(.caption)
                        .foregroundColor(Color.secondaryText)
                }
                
                Spacer()
                
                Button(action: { showBackgroundOptions = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "photo")
                            .font(.caption)
                        Text("배경 변경")
                            .font(.caption)
                    }
                    .foregroundColor(Color.primaryBlue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: DesignConstants.smallCornerRadius)
                            .fill(Color.primaryBlue.opacity(0.1))
                    )
                }
            }
            .padding(.horizontal, DesignConstants.horizontalPadding)
            
            // Character Board
            ZStack {
                // Background
                backgroundView
                
                // Characters Grid
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(members) { member in
                        CharacterCard(member: member) {
                            onSelect(member)
                        }
                    }
                    
                    // Decorative Elements
                    decorativeElements
                }
                .padding(DesignConstants.largePadding)
            }
            .frame(minHeight: 300)
            .background(
                RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                    .fill(Color.cardBackground)
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
            .padding(.horizontal, DesignConstants.horizontalPadding)
        }
        .confirmationDialog("배경 선택", isPresented: $showBackgroundOptions) {
            ForEach(BackgroundType.allCases, id: \.self) { background in
                Button(background.displayName) {
                    selectedBackground = background
                }
            }
            Button("취소", role: .cancel) { }
        }
    }
    
    private var backgroundView: some View {
        Group {
            if let imageName = selectedBackground.imageName {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .opacity(0.3)
            } else {
                // Default living room background
                RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.primaryGreen.opacity(0.1),
                                Color.primaryBlue.opacity(0.05)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        }
    }
    
    private var decorativeElements: some View {
        Group {
            // Plants
            Image(systemName: "leaf.fill")
                .font(.title)
                .foregroundColor(.green)
                .offset(x: -50, y: 20)
            
            // Table/Lamp
            if members.count > 4 {
                Image(systemName: "lamp.table.fill")
                    .font(.title2)
                    .foregroundColor(.orange)
                    .offset(x: 50, y: -20)
            }
            
            // Additional decorations
            Image(systemName: "house.fill")
                .font(.caption)
                .foregroundColor(.brown)
                .offset(x: -30, y: -30)
        }
    }
}

struct CharacterCard: View {
    let member: TeamCharacter
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        VStack(spacing: DesignConstants.smallSpacing) {
            // Character Image with Pose
            ZStack(alignment: .topTrailing) {
                Image(member.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .padding(DesignConstants.smallPadding)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        member.isOnline ? Color.successColor.opacity(0.2) : Color.secondaryText.opacity(0.1),
                                        member.isOnline ? Color.successColor.opacity(0.1) : Color.secondaryText.opacity(0.05)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        Circle()
                            .stroke(member.isOnline ? Color.successColor : Color.borderColor, lineWidth: 1)
                    )
                
                // Pose Emoji
                Text(member.pose.emoji)
                    .font(.title2)
                    .offset(x: 8, y: -8)
                    .background(
                        Circle()
                            .fill(Color.white)
                            .frame(width: 24, height: 24)
                    )
                
                // Online Status
                if member.isOnline {
                    Circle()
                        .fill(Color.successColor)
                        .frame(width: 12, height: 12)
                        .offset(x: 20, y: -20)
                }
            }
            
            // Member Name and Status
            VStack(spacing: 2) {
                Text(member.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color.primaryText)
                
                HStack(spacing: 4) {
                    if member.isOnline {
                        Circle()
                            .fill(Color.successColor)
                            .frame(width: 6, height: 6)
                        Text("온라인")
                            .font(.caption2)
                            .foregroundColor(Color.successColor)
                    } else {
                        Text("최근 출석: \(member.recentAttendance ? "✅" : "❌")")
                            .font(.caption2)
                            .foregroundColor(Color.secondaryText)
                    }
                }
                
                if member.trainingLogs > 0 {
                    Text("훈련일지 \(member.trainingLogs)개")
                        .font(.caption2)
                        .foregroundColor(Color.primaryBlue)
                }
            }
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
                onTap()
            }
        }
    }
}

#Preview {
    TeamCharacterBoardView(members: [
        TeamCharacter(name: "김철수", imageName: "soccer-player", isOnline: true, pose: .wave, recentAttendance: true, trainingLogs: 5),
        TeamCharacter(name: "이영희", imageName: "football-player-2", isOnline: false, pose: .victory, recentAttendance: true, trainingLogs: 3),
        TeamCharacter(name: "박민수", imageName: "football-player-3", isOnline: true, pose: .thumbsUp, recentAttendance: false, trainingLogs: 0),
        TeamCharacter(name: "최지영", imageName: "goalkeeper", isOnline: true, pose: .peace, recentAttendance: true, trainingLogs: 7)
    ], backgroundImage: "rain")
}
