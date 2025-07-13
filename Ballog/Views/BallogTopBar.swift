import SwiftUI

struct BallogTopBar: View {
    private var todayString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy M월 d일 EEEE"
        return formatter.string(from: Date())
    }

    var body: some View {
        HStack(spacing: DesignConstants.spacing) {
            VStack(alignment: .leading, spacing: DesignConstants.smallSpacing) {
                Text("볼로그")
                    .font(.title2.bold())
                    .foregroundColor(Color.primaryText)
                Text(todayString)
                    .font(.caption)
                    .foregroundColor(Color.secondaryText)
            }
            .padding(.leading, DesignConstants.horizontalPadding)

            Spacer()

            HStack(spacing: DesignConstants.largeSpacing) {
                NavigationLink(destination: ProfileView()) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(Color.primaryBlue)
                }
                
                NavigationLink(destination: NotificationView()) {
                    Image(systemName: "bell")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(Color.primaryText)
                }
                
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gearshape")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(Color.primaryText)
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
