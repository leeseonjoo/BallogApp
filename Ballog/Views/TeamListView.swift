import SwiftUI

private enum Layout {
    static let spacing = DesignConstants.spacing
    static let padding = DesignConstants.horizontalPadding
}

struct TeamListView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: Layout.spacing) {
            Text("My teams")
                .font(.headline)
                .padding(.top,100)

            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray)
                .frame(height: 100)
                .overlay(
                    HStack(spacing: 12) {
                        Image(systemName: "soccerball")
                            .resizable()
                            .frame(width: 40, height: 40)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("해그래 FS")
                                .fontWeight(.bold)
                            Text("여자 아마추어 풋살팀")
                            Text("No6")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding()
                )
            
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray)
                .frame(height: 100)
                .overlay(
                    HStack(spacing: 12) {
                        Image("team.png")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("시스터즈 FS")
                                .fontWeight(.bold)
                            Text("여자 아마추어 축구팀")
                            Text("No47")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding()
                )
            Spacer()
        }
        .padding(Layout.padding)
        .navigationTitle("팀 리스트")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "plus")
                }
            }
        }
        .background(Color.pageBackground)
        .ignoresSafeArea()
    }
}

#Preview {
    NavigationStack { TeamListView() }
}
