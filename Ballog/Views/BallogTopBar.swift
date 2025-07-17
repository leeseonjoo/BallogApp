import SwiftUI

struct BallogTopBar: View {
    @Binding var selectedTab: Int
    @State private var showProfile = false
    @State private var showNotifications = false
    @State private var showSettings = false
    // selectedTopTab은 selectedTab과 연동
    
    private var todayString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy M월 d일 EEEE"
        return formatter.string(from: Date())
    }

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            // 왼쪽: 볼로그 + 날짜/요일
            VStack(alignment: .leading, spacing: 2) {
                Text("볼로그")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.primaryBlue)
                Text(todayString)
                    .font(.caption2)
                    .foregroundColor(Color.secondaryText)
            }
            .frame(minWidth: 80, alignment: .leading)
            .padding(.leading, DesignConstants.horizontalPadding)
            Spacer()
            // 중앙: 개인 세션만 존재
            HStack(spacing: 16) {
                TopTabButton(title: "풋살기록장", isSelected: true) {
                    selectedTab = 0
                }
            }
            .frame(maxWidth: 220)
            Spacer()
            // 오른쪽: 프로필/알림/설정 아이콘 (더 작게)
            HStack(spacing: 16) {
                Button(action: { showProfile = true }) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(Color.primaryBlue)
                }
                .sheet(isPresented: $showProfile) {
                    ProfileView()
                }
                Button(action: { showNotifications = true }) {
                    Image(systemName: "bell")
                        .resizable()
                        .frame(width: 18, height: 18)
                        .foregroundColor(Color.primaryText)
                }
                .sheet(isPresented: $showNotifications) {
                    NotificationView()
                }
                Button(action: { showSettings = true }) {
                    Image(systemName: "gearshape")
                        .resizable()
                        .frame(width: 18, height: 18)
                        .foregroundColor(Color.primaryText)
                }
                .sheet(isPresented: $showSettings) {
                    SettingsView()
                }
            }
            .padding(.trailing, DesignConstants.horizontalPadding)
        }
        .padding(.vertical, 8)
        .background(
            Color.pageBackground
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color.borderColor),
            alignment: .bottom
        )
    }
}

struct TopTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .bold : .regular)
                .foregroundColor(isSelected ? Color.primaryBlue : Color.secondaryText)
                .padding(.vertical, 4)
                .padding(.horizontal, 12)
                .background(isSelected ? Color.primaryBlue.opacity(0.12) : Color.clear)
                .cornerRadius(10)
        }
    }
}

struct BallogTopBarModifier: ViewModifier {
    @Binding var selectedTab: Int
    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
                .padding(.top, DesignConstants.topBarHeight + 20)
            BallogTopBar(selectedTab: $selectedTab)
        }
    }
}

extension View {
    func ballogTopBar(selectedTab: Binding<Int>) -> some View {
        modifier(BallogTopBarModifier(selectedTab: selectedTab))
    }
}

#Preview {
    NavigationStack {
        Text("Preview")
            .ballogTopBar(selectedTab: .constant(0))
    }
}
