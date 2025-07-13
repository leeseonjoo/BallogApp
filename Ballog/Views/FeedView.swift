import SwiftUI

/// 피드 탭은 현재 준비 중이다.
struct FeedView: View {
    var body: some View {
        NavigationStack {
            Text("피드 준비 중")
        }
        .ballogTopBar()
    }
}

#Preview {
    FeedView()
}
