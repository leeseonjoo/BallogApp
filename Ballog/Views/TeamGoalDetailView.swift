import SwiftUI

struct TeamGoalDetailView: View {
    let goal: TeamGoal
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var teamGoalStore: TeamGoalStore
    @State private var showEditView = false
    
    private var daysUntilTarget: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let target = calendar.startOfDay(for: goal.targetDate)
        return calendar.dateComponents([.day], from: today, to: target).day ?? 0
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: DesignConstants.sectionSpacing) {
                // Header Section
                headerSection
                
                // Progress Section
                progressSection
                
                // Description Section
                descriptionSection
                
                // Team Info Section
                teamInfoSection
            }
            .padding(DesignConstants.horizontalPadding)
        }
        .background(Color.pageBackground)
        .navigationTitle("팀 목표 상세")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("편집") {
                    showEditView = true
                }
                .foregroundColor(Color.primaryBlue)
            }
        }
        .sheet(isPresented: $showEditView) {
            TeamGoalEditView(goal: goal)
                .environmentObject(teamGoalStore)
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            Text("목표 정보")
                .font(.title2.bold())
                .foregroundColor(Color.primaryText)
            
            VStack(spacing: DesignConstants.smallSpacing) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(goal.title)
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundColor(Color.primaryText)
                            
                            if goal.isCompleted {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(Color.successColor)
                            }
                        }
                        
                        HStack(spacing: 8) {
                            Image(systemName: goal.category.icon)
                                .font(.caption)
                                .foregroundColor(Color.primaryBlue)
                            Text(goal.category.rawValue)
                                .font(.caption)
                                .foregroundColor(Color.secondaryText)
                        }
                    }
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(goal.progress)%")
                            .font(.title2.bold())
                            .foregroundColor(Color.primaryBlue)
                        Text("진행률")
                            .font(.caption)
                            .foregroundColor(Color.secondaryText)
                    }
                }
                
                if !goal.isCompleted {
                    HStack {
                        Image(systemName: "calendar")
                            .font(.caption)
                            .foregroundColor(Color.primaryBlue)
                        Text("목표일까지 \(daysUntilTarget)일 남음")
                            .font(.caption)
                            .foregroundColor(Color.secondaryText)
                    }
                }
            }
            .padding(DesignConstants.cardPadding)
            .background(
                RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                    .fill(Color.cardBackground)
            )
        }
    }
    
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            Text("진행 상황")
                .font(.title2.bold())
                .foregroundColor(Color.primaryText)
            
            VStack(spacing: DesignConstants.smallSpacing) {
                ProgressView(value: Double(goal.progress), total: 100)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color.primaryBlue))
                    .scaleEffect(y: 2)
                
                HStack {
                    Text("0%")
                        .font(.caption)
                        .foregroundColor(Color.secondaryText)
                    Spacer()
                    Text("100%")
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
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            Text("목표 설명")
                .font(.title2.bold())
                .foregroundColor(Color.primaryText)
            
            VStack(alignment: .leading, spacing: DesignConstants.smallSpacing) {
                Text(goal.description)
                    .font(.subheadline)
                    .foregroundColor(Color.primaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(DesignConstants.cardPadding)
            .background(
                RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                    .fill(Color.cardBackground)
            )
        }
    }
    
    private var teamInfoSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            Text("목표 정보")
                .font(.title2.bold())
                .foregroundColor(Color.primaryText)
            
            VStack(spacing: DesignConstants.smallSpacing) {
                HStack {
                    Text("생성자")
                        .font(.subheadline)
                        .foregroundColor(Color.secondaryText)
                    Spacer()
                    Text(goal.createdBy)
                        .font(.subheadline)
                        .foregroundColor(Color.primaryText)
                }
                
                Divider()
                
                HStack {
                    Text("생성일")
                        .font(.subheadline)
                        .foregroundColor(Color.secondaryText)
                    Spacer()
                    Text(goal.createdAt, style: .date)
                        .font(.subheadline)
                        .foregroundColor(Color.primaryText)
                }
                
                Divider()
                
                HStack {
                    Text("목표일")
                        .font(.subheadline)
                        .foregroundColor(Color.secondaryText)
                    Spacer()
                    Text(goal.targetDate, style: .date)
                        .font(.subheadline)
                        .foregroundColor(Color.primaryText)
                }
            }
            .padding(DesignConstants.cardPadding)
            .background(
                RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                    .fill(Color.cardBackground)
            )
        }
    }
}

struct TeamGoalEditView: View {
    let goal: TeamGoal
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var teamGoalStore: TeamGoalStore
    
    @State private var title: String
    @State private var description: String
    @State private var targetDate: Date
    @State private var selectedCategory: TeamGoal.GoalCategory
    @State private var progress: Int
    @State private var isCompleted: Bool
    
    init(goal: TeamGoal) {
        self.goal = goal
        _title = State(initialValue: goal.title)
        _description = State(initialValue: goal.description)
        _targetDate = State(initialValue: goal.targetDate)
        _selectedCategory = State(initialValue: goal.category)
        _progress = State(initialValue: goal.progress)
        _isCompleted = State(initialValue: goal.isCompleted)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignConstants.sectionSpacing) {
                    // Basic Info Section
                    basicInfoSection
                    
                    // Category Section
                    categorySection
                    
                    // Target Date Section
                    targetDateSection
                    
                    // Progress Section
                    progressSection
                    
                    // Completion Section
                    completionSection
                }
                .padding(DesignConstants.horizontalPadding)
            }
            .background(Color.pageBackground)
            .navigationTitle("팀 목표 편집")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장") {
                        saveGoal()
                    }
                    .disabled(title.isEmpty || description.isEmpty)
                }
            }
        }
    }
    
    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            Text("목표 정보")
                .font(.title2.bold())
                .foregroundColor(Color.primaryText)
            
            VStack(spacing: DesignConstants.smallSpacing) {
                TextField("목표 제목", text: $title)
                    .textFieldStyle(.roundedBorder)
                
                TextEditor(text: $description)
                    .frame(minHeight: 100)
                    .padding(DesignConstants.cardPadding)
                    .background(
                        RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                            .fill(Color.cardBackground)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                            .stroke(Color.borderColor, lineWidth: 1)
                    )
            }
        }
    }
    
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            Text("목표 카테고리")
                .font(.title2.bold())
                .foregroundColor(Color.primaryText)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: DesignConstants.smallSpacing) {
                ForEach(TeamGoal.GoalCategory.allCases, id: \.self) { category in
                    Button(action: {
                        selectedCategory = category
                    }) {
                        HStack {
                            Image(systemName: category.icon)
                                .foregroundColor(selectedCategory == category ? .white : Color.primaryBlue)
                            Text(category.rawValue)
                                .font(.caption)
                                .foregroundColor(selectedCategory == category ? .white : Color.primaryBlue)
                        }
                        .padding(.horizontal, DesignConstants.cardPadding)
                        .padding(.vertical, DesignConstants.smallSpacing)
                        .background(
                            RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                                .fill(selectedCategory == category ? Color.primaryBlue : Color.primaryBlue.opacity(0.1))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    private var targetDateSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            Text("목표 달성일")
                .font(.title2.bold())
                .foregroundColor(Color.primaryText)
            
            DatePicker("목표 달성일", selection: $targetDate, displayedComponents: .date)
                .datePickerStyle(.compact)
                .padding(DesignConstants.cardPadding)
                .background(
                    RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                        .fill(Color.cardBackground)
                )
        }
    }
    
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            Text("현재 진행률")
                .font(.title2.bold())
                .foregroundColor(Color.primaryText)
            
            VStack(spacing: DesignConstants.smallSpacing) {
                HStack {
                    Text("\(progress)%")
                        .font(.title2.bold())
                        .foregroundColor(Color.primaryBlue)
                    Spacer()
                }
                
                Slider(value: Binding(
                    get: { Double(progress) },
                    set: { progress = Int($0) }
                ), in: 0...100, step: 5)
                .accentColor(Color.primaryBlue)
                
                HStack {
                    Text("0%")
                        .font(.caption)
                        .foregroundColor(Color.secondaryText)
                    Spacer()
                    Text("100%")
                        .font(.caption)
                        .foregroundColor(Color.secondaryText)
                }
            }
            .padding(DesignConstants.cardPadding)
            .background(
                RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                    .fill(Color.cardBackground)
            )
        }
    }
    
    private var completionSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            Text("완료 상태")
                .font(.title2.bold())
                .foregroundColor(Color.primaryText)
            
            Toggle("목표 달성", isOn: $isCompleted)
                .padding(DesignConstants.cardPadding)
                .background(
                    RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                        .fill(Color.cardBackground)
                )
        }
    }
    
    private func saveGoal() {
        let updatedGoal = TeamGoal(
            teamId: goal.teamId,
            title: title,
            description: description,
            targetDate: targetDate,
            category: selectedCategory,
            isCompleted: isCompleted,
            progress: progress,
            createdBy: goal.createdBy
        )
        
        teamGoalStore.updateGoal(updatedGoal)
        dismiss()
    }
}

#Preview {
    TeamGoalDetailView(
        goal: TeamGoal(
            teamId: UUID(),
            title: "팀워크 향상",
            description: "팀원들과의 소통을 개선하고 협력 능력을 향상시킵니다.",
            targetDate: Date().addingTimeInterval(30 * 24 * 60 * 60),
            category: .teamBuilding,
            createdBy: "홍길동"
        )
    )
    .environmentObject(TeamGoalStore())
} 