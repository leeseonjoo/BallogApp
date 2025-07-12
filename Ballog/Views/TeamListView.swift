import SwiftUI

private enum Layout {
    static let spacing = DesignConstants.spacing
    static let padding = DesignConstants.horizontalPadding
}

struct TeamListView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showAction = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: Layout.spacing) {
            Text("My teams")
                .font(.headline)
                .padding(.top,100)
            
            NavigationLink(destination: TeamManagementView_hae()) {
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
                                Text("여자 아마추어 풋살팀")
                                Text("플레이어 No.6")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                            .padding()
                    )
            }
            NavigationLink(destination: TeamManagementView_sis()) {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray)
                        .frame(height: 80)
                        .overlay(
                            HStack(spacing: 12) {
                                Image(systemName: "soccerball")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("시스터즈 FC")
                                        .fontWeight(.bold)
                                    Text("여자 아마추어 축구팀")
                                    Text("플레이어 No.47")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                                .padding()
                        )
                }

                Spacer()
            }
            .buttonStyle(.plain)
            .padding(Layout.padding)
            .navigationTitle("팀 리스트")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAction = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .background(
                NavigationLink(destination: TeamActionSelectionView(), isActive: $showAction) { EmptyView() }
            )
            .background(Color.pageBackground)
            .ignoresSafeArea()
        }
    }
    
    #Preview {
        NavigationStack { TeamListView() }
    }

