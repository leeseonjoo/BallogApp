import SwiftUI

struct PersonalGoalListView: View {
    @EnvironmentObject private var personalTrainingStore: PersonalTrainingStore
    @State private var selectedFilter: GoalFilter = .all
    @State private var showGoalSettingView = false
    
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
    
    private var filteredGoals: [PersonalGoal] {
        let sortedGoals = personalTrainingStore.goals.sorted { $0.createdAt > $1.createdAt }
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
        NavigationStack {
            VStack(spacing: 0) {
                // Filter Section
                filterSection
                
                // Goals List
                if filteredGoals.isEmpty {
                    emptyStateView
                } else {
                    goalsList
                }
            }
            .background(Color.pageBackground)
            .navigationTitle("목표 관리")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("목표 추가") {
                        showGoalSettingView = true
                    }
                    .foregroundColor(Color.primaryBlue)
                }
            }
        }
        .ballogTopBar()
        .sheet(isPresented: $showGoalSettingView) {
            PersonalGoalSettingView()
                .environmentObject(personalTrainingStore)
        }
    }
    
    private var filterSection: some View {
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
            .padding(.horizontal, DesignConstants.horizontalPadding)
        }
        .padding(.vertical, DesignConstants.smallSpacing)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: DesignConstants.largeSpacing) {
            Spacer()
            
            Image(systemName: "target")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundColor(Color.secondaryText)
            
            Text("목표가 없습니다")
                .font(.title3.bold())
                .foregroundColor(Color.primaryText)
            
            Text("새로운 목표를 설정해보세요")
                .font(.subheadline)
                .foregroundColor(Color.secondaryText)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding(DesignConstants.horizontalPadding)
    }
    
    private var goalsList: some View {
        ScrollView {
            LazyVStack(spacing: DesignConstants.smallSpacing) {
                ForEach(filteredGoals) { goal in
                    NavigationLink(destination: PersonalGoalDetailView(goal: goal)) {
                        goalCard(goal: goal)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(DesignConstants.horizontalPadding)
        }
    }
    
    private func goalCard(goal: PersonalGoal) -> some View {
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

struct PersonalGoalDetailView: View {
    let goal: PersonalGoal
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var personalTrainingStore: PersonalTrainingStore
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
                
                // Related Logs Section
                relatedLogsSection
            }
            .padding(DesignConstants.horizontalPadding)
        }
        .background(Color.pageBackground)
        .navigationTitle("목표 상세")
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
            PersonalGoalEditView(goal: goal)
                .environmentObject(personalTrainingStore)
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
    
    private var relatedLogsSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            Text("관련 훈련일지")
                .font(.title2.bold())
                .foregroundColor(Color.primaryText)
            
            let relatedLogs = personalTrainingStore.logs.filter { $0.category == goal.category }
            
            if relatedLogs.isEmpty {
                VStack(spacing: DesignConstants.smallSpacing) {
                    Image(systemName: "doc.text")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(Color.secondaryText)
                    
                    Text("관련 훈련일지가 없습니다")
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
                    ForEach(relatedLogs.prefix(3)) { log in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(log.title)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(Color.primaryText)
                                
                                Text(log.date, style: .date)
                                    .font(.caption)
                                    .foregroundColor(Color.secondaryText)
                            }
                            Spacer()
                            
                            Text("\(log.duration)분")
                                .font(.caption)
                                .foregroundColor(Color.secondaryText)
                        }
                        .padding(DesignConstants.cardPadding)
                        .background(
                            RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                                .fill(Color.cardBackground.opacity(0.5))
                        )
                    }
                }
            }
        }
    }
}

struct PersonalGoalEditView: View {
    let goal: PersonalGoal
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var personalTrainingStore: PersonalTrainingStore
    
    @State private var title: String
    @State private var description: String
    @State private var targetDate: Date
    @State private var selectedCategory: PersonalTrainingLog.TrainingCategory
    @State private var progress: Int
    @State private var isCompleted: Bool
    
    init(goal: PersonalGoal) {
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
            .navigationTitle("목표 편집")
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
            Text("훈련 카테고리")
                .font(.title2.bold())
                .foregroundColor(Color.primaryText)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: DesignConstants.smallSpacing) {
                ForEach(PersonalTrainingLog.TrainingCategory.allCases, id: \.self) { category in
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
        let updatedGoal = PersonalGoal(
            title: title,
            description: description,
            targetDate: targetDate,
            category: selectedCategory,
            isCompleted: isCompleted,
            progress: progress
        )
        
        personalTrainingStore.updateGoal(updatedGoal)
        dismiss()
    }
}

#Preview {
    PersonalGoalListView()
        .environmentObject(PersonalTrainingStore())
} 