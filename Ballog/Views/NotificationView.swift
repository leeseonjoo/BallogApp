import SwiftUI

private enum Layout {
    static let padding = DesignConstants.horizontalPadding
}

struct NotificationView: View {
    @State private var notifications: [NotificationItem] = [
        NotificationItem(
            id: UUID(),
            title: "오늘 개인 훈련을 마쳤어요!",
            message: "오늘 체력 훈련을 완료했습니다. 내일도 화이팅!",
            type: .training,
            time: Date().addingTimeInterval(-3600),
            isRead: false
        ),
        NotificationItem(
            id: UUID(),
            title: "팀 훈련에서 새로운 전술을 배웠습니다.",
            message: "오늘 팀 훈련에서 새로운 전술을 배웠어요. 다음 경기에 적용해보겠습니다.",
            type: .team,
            time: Date().addingTimeInterval(-7200),
            isRead: true
        ),
        NotificationItem(
            id: UUID(),
            title: "주말 경기 일정이 확정됐어요.",
            message: "이번 주 토요일 오후 2시에 경기가 있습니다. 모두 참석해주세요.",
            type: .match,
            time: Date().addingTimeInterval(-10800),
            isRead: true
        ),
        NotificationItem(
            id: UUID(),
            title: "새로운 팀원이 가입했습니다.",
            message: "김철수님이 팀에 가입하셨습니다. 환영합니다!",
            type: .team,
            time: Date().addingTimeInterval(-14400),
            isRead: false
        )
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignConstants.sectionSpacing) {
                    // Notification Stats
                    notificationStatsSection
                    
                    // Notifications List
                    notificationsListSection
                }
                .padding(DesignConstants.horizontalPadding)
            }
            .background(Color.pageBackground)
            .navigationTitle("알림")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("모두 읽음") {
                        markAllAsRead()
                    }
                    .foregroundColor(Color.primaryBlue)
                }
            }
        }
        .ballogTopBar(selectedTab: .constant(0))
    }
    
    private var notificationStatsSection: some View {
        HStack(spacing: DesignConstants.spacing) {
            NotificationStatCard(
                title: "전체",
                count: notifications.count,
                color: Color.primaryBlue
            )
            
            NotificationStatCard(
                title: "읽지 않음",
                count: notifications.filter { !$0.isRead }.count,
                color: Color.primaryOrange
            )
        }
    }
    
    private var notificationsListSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            HStack {
                Text("알림 목록")
                    .font(.title2.bold())
                    .foregroundColor(Color.primaryText)
                Spacer()
            }
            
            VStack(spacing: DesignConstants.smallSpacing) {
                ForEach(notifications) { notification in
                    NotificationCard(notification: notification) {
                        markAsRead(notification)
                    }
                }
            }
        }
    }
    
    private func markAsRead(_ notification: NotificationItem) {
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index].isRead = true
        }
    }
    
    private func markAllAsRead() {
        for index in notifications.indices {
            notifications[index].isRead = true
        }
    }
}

struct NotificationItem: Identifiable {
    let id: UUID
    let title: String
    let message: String
    let type: NotificationType
    let time: Date
    var isRead: Bool
}

enum NotificationType: CaseIterable {
    case training, team, match, system
    
    var icon: String {
        switch self {
        case .training:
            return "figure.walk"
        case .team:
            return "person.3"
        case .match:
            return "sportscourt"
        case .system:
            return "gear"
        }
    }
    
    var color: Color {
        switch self {
        case .training:
            return Color.primaryGreen
        case .team:
            return Color.primaryBlue
        case .match:
            return Color.primaryOrange
        case .system:
            return Color.secondaryText
        }
    }
}

struct NotificationStatCard: View {
    let title: String
    let count: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: DesignConstants.smallSpacing) {
            Text("\(count)")
                .font(.title.bold())
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(Color.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(DesignConstants.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                .fill(Color.cardBackground)
        )
    }
}

struct NotificationCard: View {
    let notification: NotificationItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: DesignConstants.spacing) {
                // Icon
                Image(systemName: notification.type.icon)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(notification.type.color)
                    .padding(DesignConstants.smallPadding)
                    .background(
                        Circle()
                            .fill(notification.type.color.opacity(0.1))
                    )
                
                // Content
                VStack(alignment: .leading, spacing: DesignConstants.smallSpacing) {
                    HStack {
                        Text(notification.title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(Color.primaryText)
                        
                        Spacer()
                        
                        if !notification.isRead {
                            Circle()
                                .fill(Color.primaryOrange)
                                .frame(width: 8, height: 8)
                        }
                    }
                    
                    Text(notification.message)
                        .font(.caption)
                        .foregroundColor(Color.secondaryText)
                        .lineLimit(2)
                    
                    Text(notification.time, style: .relative)
                        .font(.caption2)
                        .foregroundColor(Color.tertiaryText)
                }
                
                Spacer()
            }
            .padding(DesignConstants.cardPadding)
            .background(
                RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                    .fill(notification.isRead ? Color.cardBackground : Color.primaryOrange.opacity(0.05))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NotificationView()
}
