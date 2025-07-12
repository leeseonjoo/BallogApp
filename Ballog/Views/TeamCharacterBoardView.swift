import SwiftUI

private enum Layout {
    static let padding = DesignConstants.horizontalPadding
}

struct TeamCharacter: Identifiable {
    enum Pose: CaseIterable {
        case wave
        case victory

        var emoji: String {
            switch self {
            case .wave: return "\u{1F44B}" // 👋
            case .victory: return "\u{270C}\u{FE0F}" // ✌️
            }
        }
    }

    var id = UUID()
    var name: String
    var imageName: String
    var isOnline: Bool
    var pose: Pose = .wave
}

struct TeamCharacterBoardView: View {
    let members: [TeamCharacter]
    var onSelect: (TeamCharacter) -> Void = { _ in }
    var backgroundImage: String?
    @State private var showField = false

    private var columns: [GridItem] {
        let count = members.count <= 3 ? members.count : 4
        return Array(repeating: GridItem(.flexible(), spacing: 12), count: max(count, 3))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle("축구장 배경", isOn: $showField)
                .padding(.horizontal, Layout.padding)
            ZStack {
                if let bg = backgroundImage {
                    Image(bg)
                        .resizable()
                        .scaledToFill()
                        .opacity(0.3)
                        .clipped()
                }
                RoundedRectangle(cornerRadius: 12)
                    .fill(showField ? Color.green.opacity(0.2) : Color(UIColor.systemGray6))
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(members) { member in
                        VStack(spacing: 4) {
                            ZStack(alignment: .topTrailing) {
                                Image(member.imageName)
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                Text(member.pose.emoji)
                                    .offset(x: 6, y: -6)
                            }
                            HStack(spacing: 4) {
                                Text(member.name)
                                if member.isOnline {
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 6, height: 6)
                                }
                            }
                            .font(.caption)
                        }
                        .onTapGesture { onSelect(member) }
                    }
                    Image(systemName: "leaf.fill")
                        .font(.title)
                        .foregroundColor(.green)
                    if members.count > 4 {
                        Image(systemName: "lamp.table.fill")
                            .font(.title2)
                            .foregroundColor(.yellow)
                    }
                }
                .padding()
            }
        }
    }
}

#Preview {
    TeamCharacterBoardView(members: [
        TeamCharacter(name: "샘플1", imageName: "soccer-player", isOnline: true),
        TeamCharacter(name: "샘플2", imageName: "football-player-2", isOnline: false, pose: .victory),
        TeamCharacter(name: "샘플3", imageName: "football-player-3", isOnline: true)
    ], backgroundImage: "summer")
}
