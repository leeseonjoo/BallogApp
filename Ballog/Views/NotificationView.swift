import SwiftUI

private enum Layout {
    static let padding = DesignConstants.horizontalPadding
}

struct NotificationView: View {
    let posts = [
        "오늘 개인 훈련을 마쳤어요!",
        "팀 훈련에서 새로운 전술을 배웠습니다.",
        "주말 경기 일정이 확정됐어요."
    ]

    var body: some View {
        NavigationStack {
            List(posts, id: \.self) { post in
                Text(post)
            }
            .listStyle(.plain)
            .padding(.horizontal, Layout.padding)
            .navigationTitle("알림")
            .scrollContentBackground(.hidden)
        }
        .background(Color.pageBackground)
        .ignoresSafeArea()
        .ballogTopBar()
    }
}

#Preview {
    NotificationView()
}
