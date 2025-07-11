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
                .padding(.top)

            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray)
                .frame(height: 80)
                .overlay(
                    HStack(spacing: 12) {
                        Image(systemName: "soccerball")
                            .resizable()
                            .frame(width: 40, height: 40)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("해그래 FS")
                                .fontWeight(.bold)
                            Text("풋살팀")
                            Text("플레이어 (플레이어-코치)")
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
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                }
            }
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
