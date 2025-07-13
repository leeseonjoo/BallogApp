import SwiftUI

private enum TeamTab: String, CaseIterable {
    case manage = "팀 관리"
    case ranking = "팀 랭킹"
    case match = "매치 관리"
    case tactics = "전술"
}

struct TeamPageView: View {
    @State private var selection: TeamTab = .manage
    @EnvironmentObject private var teamStore: TeamStore
    @AppStorage("currentTeamID") private var currentTeamID: String = ""
    @AppStorage("hasTeam") private var hasTeam: Bool = true

    private var currentTeam: Team? {
        teamStore.teams.first { $0.id.uuidString == currentTeamID }
    }

    var body: some View {
        NavigationStack {
            if let team = currentTeam {
                VStack(spacing: 0) {
                    // Team Header
                    teamHeader(team: team)
                    
                    // Tab Picker
                    Picker("TeamTab", selection: $selection) {
                        ForEach(TeamTab.allCases, id: \.self) { tab in
                            Text(tab.rawValue).tag(tab)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(DesignConstants.horizontalPadding)
                    .padding(.vertical, DesignConstants.verticalPadding)
                    .background(Color.pageBackground)

                    // Tab Content
                    TabView(selection: $selection) {
                        TeamManagementView(team: team)
                            .tag(TeamTab.manage)
                        
                        TeamRankingView()
                            .tag(TeamTab.ranking)
                        
                        MatchManagementView()
                            .tag(TeamTab.match)
                        
                        TeamTacticsView()
                            .tag(TeamTab.tactics)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            } else {
                ScrollView {
                    VStack(spacing: DesignConstants.sectionSpacing) {
                        if !hasTeam {
                            noTeamSection
                        }
                        
                        TeamActionSelectionView()
                        
                        if !teamStore.teams.isEmpty {
                            recommendedTeamsSection
                        }
                    }
                    .padding(DesignConstants.horizontalPadding)
                }
            }
        }
        .ballogTopBar()
    }
    
    private func teamHeader(team: Team) -> some View {
        VStack(spacing: DesignConstants.smallSpacing) {
            HStack {
                VStack(alignment: .leading, spacing: DesignConstants.smallSpacing) {
                    Text(team.name)
                        .font(.title2.bold())
                        .foregroundColor(Color.primaryText)
                    
                    Text(team.region)
                        .font(.subheadline)
                        .foregroundColor(Color.secondaryText)
                    
                    Text(team.trainingTime)
                        .font(.caption)
                        .foregroundColor(Color.tertiaryText)
                }
                
                Spacer()
                
                Image(systemName: "person.3.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(Color.primaryBlue)
            }
            .padding(DesignConstants.cardPadding)
            .background(
                RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                    .fill(Color.cardBackground)
            )
        }
        .padding(DesignConstants.horizontalPadding)
        .padding(.vertical, DesignConstants.verticalPadding)
    }
    
    private var noTeamSection: some View {
        VStack(spacing: DesignConstants.smallSpacing) {
            Image(systemName: "person.3")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundColor(Color.secondaryText)
            
            Text("팀에 가입해보세요")
                .font(.headline)
                .foregroundColor(Color.primaryText)
            
            Text("팀에 가입하여 함께 성장하세요")
                .font(.subheadline)
                .foregroundColor(Color.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(DesignConstants.largePadding)
        .background(
            RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                .fill(Color.cardBackground)
        )
    }
    
    private var recommendedTeamsSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            Text("추천 팀")
                .font(.title2.bold())
                .foregroundColor(Color.primaryText)
            
            VStack(spacing: DesignConstants.smallSpacing) {
                ForEach(teamStore.teams) { team in
                    NavigationLink(destination: TeamPreviewView(team: team)) {
                        HStack {
                            VStack(alignment: .leading, spacing: DesignConstants.smallSpacing) {
                                Text(team.name)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color.primaryText)
                                
                                Text(team.region)
                                    .font(.caption)
                                    .foregroundColor(Color.secondaryText)
                                
                                Text(team.trainingTime)
                                    .font(.caption)
                                    .foregroundColor(Color.tertiaryText)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(Color.secondaryText)
                        }
                        .padding(DesignConstants.cardPadding)
                        .background(
                            RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                                .fill(Color.cardBackground)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}

#Preview {
    TeamPageView()
        .environmentObject(AttendanceStore())
        .environmentObject(TeamTrainingLogStore())
        .environmentObject(TeamTacticStore())
}

