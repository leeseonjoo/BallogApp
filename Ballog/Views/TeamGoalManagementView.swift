import SwiftUI

struct TeamGoalManagementView: View {
    let team: Team
    @EnvironmentObject private var teamGoalStore: TeamGoalStore
    @AppStorage("profileCard") private var storedCard: String = ""
    @State private var showGoalSettingView = false
    @State private var showMotivationView = false
    @State private var selectedFilter: GoalFilter = .all
    
    enum GoalFilter: String, CaseIterable {
        case all = "전체"
        case active = "진행중"
        case completed = "완료"
        
        var icon: String {
            switch self {
            case .all: return "list.bullet"
            case .active: return "target"
            case .completed: return "checkmark.circle"
            }
        }
    }
    
    private var userCard: ProfileCard? {
        guard let data = storedCard.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(ProfileCard.self, from: data)
    }
    
    private var teamGoals: [TeamGoal] {
        teamGoalStore.getGoalsForTeam(team.id)
    }
    
    private var teamMotivations: [TeamMotivation] {
        teamGoalStore.getMotivationsForTeam(team.id)
    }
    
    private var filteredGoals: [TeamGoal] {
        let sortedGoals = teamGoals.sorted { $0.createdAt > $1.createdAt }
        switch selectedFilter {
        case .all:
            return sortedGoals
        case .active:
            return sortedGoals.filter { !$0.isCompleted }
        case .completed:
            return sortedGoals.filter { $0.isCompleted }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: DesignConstants.sectionSpacing) {
                // Motivation Section
                motivationSection
                
                // Goals Section
                goalsSection
            }
            .padding(DesignConstants.horizontalPadding)
        }
        .background(Color.pageBackground)
        .sheet(isPresented: $showGoalSettingView) {
            TeamGoalSettingView(team: team)
                .environmentObject(teamGoalStore)
        }
        .sheet(isPresented: $showMotivationView) {
            TeamMotivationView(team: team)
                .environmentObject(teamGoalStore)
        }
    }
    
    private var motivationSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            HStack {
                Text("💪 팀 동기부여")
                    .font(.title2.bold())
                    .foregroundColor(Color.primaryText)
                Spacer()
                Button("추가") {
                    showMotivationView = true
                }
                .font(.caption)
                .foregroundColor(Color.primaryBlue)
            }
            
            if teamMotivations.isEmpty {
                VStack(spacing: DesignConstants.smallSpacing) {
                    Image(systemName: "heart")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(Color.secondaryText)
                    
                    Text("팀 동기부여 메시지를 추가해보세요")
                        .font(.subheadline)
                        .foregroundColor(Color.secondaryText)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(DesignConstants.largePadding)
                .background(
                    RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                        .fill(Color.cardBackground)
                )
            } else {
                VStack(spacing: DesignConstants.smallSpacing) {
                    ForEach(teamMotivations.prefix(3)) { motivation in
                        motivationCard(motivation: motivation)
                    }
                }
            }
        }
    }
    
    private func motivationCard(motivation: TeamMotivation) -> some View {
        VStack(alignment: .leading, spacing: DesignConstants.smallSpacing) {
            HStack {
                Image(systemName: motivation.type.icon)
                    .font(.caption)
                    .foregroundColor(Color.primaryBlue)
                Text(motivation.type.rawValue)
                    .font(.caption)
                    .foregroundColor(Color.secondaryText)
                Spacer()
                Text(motivation.createdAt, style: .date)
                    .font(.caption)
                    .foregroundColor(Color.secondaryText)
            }
            
            Text(motivation.title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Color.primaryText)
            
            Text(motivation.content)
                .font(.subheadline)
                .foregroundColor(Color.secondaryText)
                .lineLimit(3)
        }
        .padding(DesignConstants.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                .fill(Color.cardBackground)
        )
    }
    
    private var goalsSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            HStack {
                Text("🎯 팀 목표")
                    .font(.title2.bold())
                    .foregroundColor(Color.primaryText)
                Spacer()
                Button("목표 설정") {
                    showGoalSettingView = true
                }
                .font(.caption)
                .foregroundColor(Color.primaryBlue)
            }
            
            // Filter Buttons
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignConstants.smallSpacing) {
                    ForEach(GoalFilter.allCases, id: \.self) { filter in
                        Button(action: {
                            selectedFilter = filter
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: filter.icon)
                                    .font(.caption)
                                Text(filter.rawValue)
                                    .font(.caption)
                            }
                            .padding(.horizontal, DesignConstants.cardPadding)
                            .padding(.vertical, DesignConstants.smallSpacing)
                            .background(
                                RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                                    .fill(selectedFilter == filter ? Color.primaryBlue : Color.cardBackground)
                            )
                            .foregroundColor(selectedFilter == filter ? .white : Color.primaryText)
                        }
                    }
                }
            }
            
            if filteredGoals.isEmpty {
                VStack(spacing: DesignConstants.smallSpacing) {
                    Image(systemName: "target")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(Color.secondaryText)
                    
                    Text("팀 목표를 설정해보세요")
                        .font(.subheadline)
                        .foregroundColor(Color.secondaryText)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(DesignConstants.largePadding)
                .background(
                    RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                        .fill(Color.cardBackground)
                )
            } else {
                VStack(spacing: DesignConstants.smallSpacing) {
                    ForEach(filteredGoals) { goal in
                        NavigationLink(destination: TeamGoalDetailView(goal: goal)) {
                            goalCard(goal: goal)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }
    
    private func goalCard(goal: TeamGoal) -> some View {
        VStack(alignment: .leading, spacing: DesignConstants.smallSpacing) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(goal.title)
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundColor(Color.primaryText)
                        
                        if goal.isCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(Color.successColor)
                        }
                    }
                    
                    Text(goal.description)
                        .font(.subheadline)
                        .foregroundColor(Color.secondaryText)
                        .lineLimit(2)
                }
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(goal.progress)%")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(Color.primaryBlue)
                    
                    ProgressView(value: Double(goal.progress), total: 100)
                        .progressViewStyle(LinearProgressViewStyle(tint: Color.primaryBlue))
                        .frame(width: 60)
                }
            }
            
            HStack(spacing: DesignConstants.smallSpacing) {
                HStack(spacing: 4) {
                    Image(systemName: goal.category.icon)
                        .font(.caption)
                        .foregroundColor(Color.primaryBlue)
                    Text(goal.category.rawValue)
                        .font(.caption)
                        .foregroundColor(Color.secondaryText)
                }
                
                Spacer()
                
                Text(goal.targetDate, style: .date)
                    .font(.caption)
                    .foregroundColor(Color.secondaryText)
            }
            
            if goal.isCompleted {
                HStack {
                    Image(systemName: "trophy.fill")
                        .font(.caption)
                        .foregroundColor(Color.successColor)
                    Text("목표 달성!")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(Color.successColor)
                    Spacer()
                }
                .padding(.top, DesignConstants.smallSpacing)
            }
        }
        .padding(DesignConstants.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                .fill(Color.cardBackground)
        )
    }
}

#Preview {
    TeamGoalManagementView(team: Team(name: "샘플팀", region: "서울", creatorName: "홍길동"))
        .environmentObject(TeamGoalStore())
} 