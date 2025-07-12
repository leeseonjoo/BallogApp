import SwiftUI
import UIKit

struct TeamLinkShareView: View {
    let teamName: String
    private let code: String = String(UUID().uuidString.prefix(8))
    private var link: String { "https://ballog.app/team/\(code)" }

    var body: some View {
        VStack(spacing: 20) {
            Text("팀 링크")
                .font(.headline)
            HStack {
                Text(link)
                    .font(.footnote)
                    .lineLimit(1)
                    .truncationMode(.middle)
                Button(action: { UIPasteboard.general.string = link }) {
                    Image(systemName: "doc.on.doc")
                }
            }
            if let url = URL(string: link) {
                ShareLink(item: url) {
                    Text("공유하기")
                }
                .buttonStyle(.bordered)
            }
            Text("팀 코드: \(code)")
        }
        .padding()
        .navigationTitle("팀 링크 공유")
    }
}

#Preview {
    NavigationStack { TeamLinkShareView(teamName: "해그래") }
}
