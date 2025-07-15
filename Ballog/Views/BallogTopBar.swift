import SwiftUI

struct BallogTopBar: View {
    @State private var showProfile = false
    @State private var showNotifications = false
    @State private var showSettings = false
    @State private var selectedTopTab: Int = 0 // 0: 풋살기록장, 1: 팀 매칭룸
    
    private var todayString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy M월 d일 EEEE"
        return formatter.string(from: Date())
    }

    var body: some View {
        HStack(spacing: DesignConstants.spacing) {
            VStack(alignment: .leading, spacing: 2) {
                Text("볼로그")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.primaryBlue)
            }
            .padding(.leading, DesignConstants.horizontalPadding)
            Spacer()
            VStack(spacing: 4) {
                HStack(spacing: 24) {
                    TopTabButton(title: "풋살기록장", isSelected: selectedTopTab == 0) {
                        selectedTopTab = 0
                    }
                    TopTabButton(title: "팀 매칭룸", isSelected: selectedTopTab == 1) {
                        selectedTopTab = 1
                    }
                }
                .frame(maxWidth: .infinity)
                Text(todayString)
                    .font(.caption2)
                    .foregroundColor(Color.secondaryText)
            }
            Spacer()
            HStack(spacing: DesignConstants.largeSpacing) {
                Button(action: { showProfile = true }) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(Color.primaryBlue)
                }
                .sheet(isPresented: $showProfile) {
                    ProfileView()
                }
                Button(action: { showNotifications = true }) {
                    Image(systemName: "bell")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(Color.primaryText)
                }
                .sheet(isPresented: $showNotifications) {
                    NotificationView()
                }
                Button(action: { showSettings = true }) {
                    Image(systemName: "gearshape")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(Color.primaryText)
                }
                .sheet(isPresented: $showSettings) {
                    SettingsView()
                }
            }
            .padding(.trailing, DesignConstants.horizontalPadding)
        }
        .padding(.vertical, DesignConstants.verticalPadding)
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
                .font(.headline)
                .fontWeight(isSelected ? .bold : .regular)
                .foregroundColor(isSelected ? Color.primaryBlue : Color.secondaryText)
                .padding(.vertical, 6)
                .padding(.horizontal, 16)
                .background(isSelected ? Color.primaryBlue.opacity(0.12) : Color.clear)
                .cornerRadius(12)
        }
    }
}

struct BallogTopBarModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
                .padding(.top, DesignConstants.topBarHeight + 20)
            BallogTopBar()
        }
    }
}

extension View {
    func ballogTopBar() -> some View {
        modifier(BallogTopBarModifier())
    }
}

#Preview {
    NavigationStack {
        Text("Preview")
            .ballogTopBar()
    }
}
