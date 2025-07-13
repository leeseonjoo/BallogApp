import SwiftUI

struct PersonalTrainingLogDetailView: View {
    let log: PersonalTrainingLog
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var personalTrainingStore: PersonalTrainingStore
    @State private var showEditView = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: DesignConstants.sectionSpacing) {
                // Header Section
                headerSection
                
                // Content Section
                contentSection
                
                // Goals Section
                if !log.goals.isEmpty {
                    goalsSection
                }
                
                // Achievements Section
                if !log.achievements.isEmpty {
                    achievementsSection
                }
                
                // Next Goals Section
                if !log.nextGoals.isEmpty {
                    nextGoalsSection
                }
            }
            .padding(DesignConstants.horizontalPadding)
        }
        .background(Color.pageBackground)
        .navigationTitle("훈련일지 상세")
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
            PersonalTrainingLogEditView(log: log)
                .environmentObject(personalTrainingStore)
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            Text("훈련 정보")
                .font(.title2.bold())
                .foregroundColor(Color.primaryText)
            
            VStack(spacing: DesignConstants.smallSpacing) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(log.title)
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundColor(Color.primaryText)
                        
                        Text(log.date, style: .date)
                            .font(.subheadline)
                            .foregroundColor(Color.secondaryText)
                    }
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(log.mood.emoji)
                            .font(.title2)
                        Text(log.mood.rawValue)
                            .font(.caption)
                            .foregroundColor(Color.secondaryText)
                    }
                }
                
                HStack(spacing: DesignConstants.largeSpacing) {
                    VStack(spacing: 4) {
                        Image(systemName: log.category.icon)
                            .font(.title2)
                            .foregroundColor(Color.primaryBlue)
                        Text(log.category.rawValue)
                            .font(.caption)
                            .foregroundColor(Color.secondaryText)
                    }
                    
                    VStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.title2)
                            .foregroundColor(Color.primaryBlue)
                        Text("\(log.duration)분")
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
    
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            Text("훈련 내용")
                .font(.title2.bold())
                .foregroundColor(Color.primaryText)
            
            VStack(alignment: .leading, spacing: DesignConstants.smallSpacing) {
                Text(log.content)
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
    
    private var goalsSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            Text("이번 훈련 목표")
                .font(.title2.bold())
                .foregroundColor(Color.primaryText)
            
            VStack(alignment: .leading, spacing: DesignConstants.smallSpacing) {
                ForEach(log.goals, id: \.self) { goal in
                    HStack(alignment: .top, spacing: DesignConstants.smallSpacing) {
                        Image(systemName: "target")
                            .font(.caption)
                            .foregroundColor(Color.primaryBlue)
                            .padding(.top, 2)
                        
                        Text(goal)
                            .font(.subheadline)
                            .foregroundColor(Color.primaryText)
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
    
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            Text("달성한 것들")
                .font(.title2.bold())
                .foregroundColor(Color.primaryText)
            
            VStack(alignment: .leading, spacing: DesignConstants.smallSpacing) {
                ForEach(log.achievements, id: \.self) { achievement in
                    HStack(alignment: .top, spacing: DesignConstants.smallSpacing) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(Color.successColor)
                            .padding(.top, 2)
                        
                        Text(achievement)
                            .font(.subheadline)
                            .foregroundColor(Color.primaryText)
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
    
    private var nextGoalsSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            Text("다음 훈련 목표")
                .font(.title2.bold())
                .foregroundColor(Color.primaryText)
            
            VStack(alignment: .leading, spacing: DesignConstants.smallSpacing) {
                ForEach(log.nextGoals, id: \.self) { goal in
                    HStack(alignment: .top, spacing: DesignConstants.smallSpacing) {
                        Image(systemName: "arrow.right.circle")
                            .font(.caption)
                            .foregroundColor(Color.primaryBlue)
                            .padding(.top, 2)
                        
                        Text(goal)
                            .font(.subheadline)
                            .foregroundColor(Color.primaryText)
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
}

struct PersonalTrainingLogEditView: View {
    let log: PersonalTrainingLog
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var personalTrainingStore: PersonalTrainingStore
    
    @State private var title: String
    @State private var content: String
    @State private var duration: Int
    @State private var selectedCategory: PersonalTrainingLog.TrainingCategory
    @State private var selectedMood: PersonalTrainingLog.TrainingMood
    @State private var goals: [String]
    @State private var achievements: [String]
    @State private var nextGoals: [String]
    @State private var selectedDate: Date
    
    init(log: PersonalTrainingLog) {
        self.log = log
        _title = State(initialValue: log.title)
        _content = State(initialValue: log.content)
        _duration = State(initialValue: log.duration)
        _selectedCategory = State(initialValue: log.category)
        _selectedMood = State(initialValue: log.mood)
        _goals = State(initialValue: log.goals)
        _achievements = State(initialValue: log.achievements)
        _nextGoals = State(initialValue: log.nextGoals)
        _selectedDate = State(initialValue: log.date)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignConstants.sectionSpacing) {
                    // Date Selection
                    dateSelectionSection
                    
                    // Basic Info Section
                    basicInfoSection
                    
                    // Training Details Section
                    trainingDetailsSection
                    
                    // Goals Section
                    goalsSection
                    
                    // Achievements Section
                    achievementsSection
                    
                    // Next Goals Section
                    nextGoalsSection
                }
                .padding(DesignConstants.horizontalPadding)
            }
            .background(Color.pageBackground)
            .navigationTitle("훈련일지 편집")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장") {
                        saveLog()
                    }
                    .disabled(title.isEmpty || content.isEmpty)
                }
            }
        }
    }
    
    private var dateSelectionSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            Text("훈련 날짜")
                .font(.title2.bold())
                .foregroundColor(Color.primaryText)
            
            DatePicker("날짜 선택", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(.compact)
                .padding(DesignConstants.cardPadding)
                .background(
                    RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                        .fill(Color.cardBackground)
                )
        }
    }
    
    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            Text("기본 정보")
                .font(.title2.bold())
                .foregroundColor(Color.primaryText)
            
            VStack(spacing: DesignConstants.smallSpacing) {
                TextField("훈련 제목", text: $title)
                    .textFieldStyle(.roundedBorder)
                
                TextEditor(text: $content)
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
    
    private var trainingDetailsSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            Text("훈련 세부사항")
                .font(.title2.bold())
                .foregroundColor(Color.primaryText)
            
            VStack(spacing: DesignConstants.smallSpacing) {
                // Duration
                HStack {
                    Text("훈련 시간")
                        .font(.subheadline)
                        .foregroundColor(Color.secondaryText)
                    Spacer()
                    Stepper("\(duration)분", value: $duration, in: 10...300, step: 10)
                        .font(.subheadline)
                        .foregroundColor(Color.primaryText)
                }
                
                // Category
                VStack(alignment: .leading, spacing: DesignConstants.smallSpacing) {
                    Text("훈련 카테고리")
                        .font(.subheadline)
                        .foregroundColor(Color.secondaryText)
                    
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
                
                // Mood
                VStack(alignment: .leading, spacing: DesignConstants.smallSpacing) {
                    Text("훈련 후 기분")
                        .font(.subheadline)
                        .foregroundColor(Color.secondaryText)
                    
                    HStack(spacing: DesignConstants.smallSpacing) {
                        ForEach(PersonalTrainingLog.TrainingMood.allCases, id: \.self) { mood in
                            Button(action: {
                                selectedMood = mood
                            }) {
                                VStack(spacing: 4) {
                                    Text(mood.emoji)
                                        .font(.title2)
                                    Text(mood.rawValue)
                                        .font(.caption2)
                                        .foregroundColor(selectedMood == mood ? .white : Color.primaryText)
                                }
                                .padding(.horizontal, DesignConstants.cardPadding)
                                .padding(.vertical, DesignConstants.smallSpacing)
                                .background(
                                    RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                                        .fill(selectedMood == mood ? Color.primaryBlue : Color.cardBackground)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
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
    
    private var goalsSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            HStack {
                Text("이번 훈련 목표")
                    .font(.title2.bold())
                    .foregroundColor(Color.primaryText)
                Spacer()
                Button("추가") {
                    goals.append("")
                }
                .font(.caption)
                .foregroundColor(Color.primaryBlue)
            }
            
            VStack(spacing: DesignConstants.smallSpacing) {
                ForEach(goals.indices, id: \.self) { index in
                    HStack {
                        TextField("목표 \(index + 1)", text: $goals[index])
                            .textFieldStyle(.roundedBorder)
                        
                        if goals.count > 1 {
                            Button(action: {
                                goals.remove(at: index)
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(Color.primaryRed)
                            }
                        }
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
    
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            HStack {
                Text("달성한 것들")
                    .font(.title2.bold())
                    .foregroundColor(Color.primaryText)
                Spacer()
                Button("추가") {
                    achievements.append("")
                }
                .font(.caption)
                .foregroundColor(Color.primaryBlue)
            }
            
            VStack(spacing: DesignConstants.smallSpacing) {
                ForEach(achievements.indices, id: \.self) { index in
                    HStack {
                        TextField("달성 \(index + 1)", text: $achievements[index])
                            .textFieldStyle(.roundedBorder)
                        
                        if achievements.count > 1 {
                            Button(action: {
                                achievements.remove(at: index)
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(Color.primaryRed)
                            }
                        }
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
    
    private var nextGoalsSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            HStack {
                Text("다음 훈련 목표")
                    .font(.title2.bold())
                    .foregroundColor(Color.primaryText)
                Spacer()
                Button("추가") {
                    nextGoals.append("")
                }
                .font(.caption)
                .foregroundColor(Color.primaryBlue)
            }
            
            VStack(spacing: DesignConstants.smallSpacing) {
                ForEach(nextGoals.indices, id: \.self) { index in
                    HStack {
                        TextField("다음 목표 \(index + 1)", text: $nextGoals[index])
                            .textFieldStyle(.roundedBorder)
                        
                        if nextGoals.count > 1 {
                            Button(action: {
                                nextGoals.remove(at: index)
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(Color.primaryRed)
                            }
                        }
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
    
    private func saveLog() {
        let updatedLog = PersonalTrainingLog(
            date: selectedDate,
            title: title,
            content: content,
            duration: duration,
            category: selectedCategory,
            mood: selectedMood,
            goals: goals.filter { !$0.isEmpty },
            achievements: achievements.filter { !$0.isEmpty },
            nextGoals: nextGoals.filter { !$0.isEmpty }
        )
        
        personalTrainingStore.updateLog(updatedLog)
        dismiss()
    }
}

#Preview {
    PersonalTrainingLogDetailView(
        log: PersonalTrainingLog(
            title: "개인 훈련",
            content: "오늘은 드리블 연습을 했습니다.",
            duration: 60,
            category: .dribbling,
            mood: .good
        )
    )
    .environmentObject(PersonalTrainingStore())
} 