import SwiftUI

struct BallogTopBar: View {
    private var todayString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy M월 d일 EEEE"
        return formatter.string(from: Date())
    }

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                Text("볼로그")
                    .font(.title2.bold())
                Text(todayString)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.leading)

            Spacer()

            NavigationLink(destination: ProfileView()) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 28, height: 28)
            }
            NavigationLink(destination: NotificationView()) {
                Image(systemName: "bell")
                    .resizable()
                    .frame(width: 24, height: 24)
            }
            NavigationLink(destination: SettingsView()) {
                Image(systemName: "gearshape")
                    .resizable()
                    .frame(width: 24, height: 24)
            }
        }
        .padding(.vertical, 8)
        .background(Color.pageBackground)
    }
}

struct BallogTopBarModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
                .padding(.top, 50)
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
