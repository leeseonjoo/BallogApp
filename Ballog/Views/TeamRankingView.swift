import SwiftUI

struct TeamRankingView: View {
    var body: some View {
        List {
            Section(header: Text("지역 랭킹")) {
                ForEach(1..<6) { rank in
                    HStack {
                        Text("\(rank)위")
                        Spacer()
                        Text("팀 \(rank)")
                    }
                }
            }
        }
    }
}

#Preview {
    TeamRankingView()
}
