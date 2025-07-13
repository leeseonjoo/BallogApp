import SwiftUI

private enum Layout {
    static let spacing = DesignConstants.spacing
    static let padding = DesignConstants.horizontalPadding
}

struct TeamListView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showAction = false
    @EnvironmentObject private var teamStore: TeamStore

    var body: some View {
        VStack(alignment: .leading, spacing: Layout.spacing) {
            Text("My teams")
                .font(.headline)
                .padding(.top,100)

            ForEach(teamStore.teams) { team in
                NavigationLink(destination: TeamManagementView(team: team)) {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray)
                        .frame(height: 80)
                        .overlay(
                            HStack(spacing: 12) {
                                Image(systemName: "soccerball")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(team.name)
                                        .fontWeight(.bold)
                                    Text(team.sport)
                                    Text(team.gender)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                                .padding()
                        )
                }
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

