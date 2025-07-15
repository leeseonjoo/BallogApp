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
                // 오늘 훈련 중 잘한 것들
                if !log.achievements.isEmpty {
                    achievementsSection
                }
                // 부족한 것들
                if !log.shortcomings.isEmpty {
                    shortcomingsSection
                }
                // 다음 훈련 목표
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
                        HStack(spacing: 4) {
                            ForEach(log.categories, id: \.self) { category in
                                HStack(spacing: 2) {
                                    Image(systemName: category.icon)
                                        .font(.caption)
                                        .foregroundColor(Color.primaryBlue)
                                    Text(category.rawValue)
                                        .font(.caption2)
                                        .foregroundColor(Color.secondaryText)
                                }
                            }
                            if log.isTeam {
                                Text("팀")
                                    .font(.caption2)
                                    .foregroundColor(.green)
                            } else {
                                Text("개인")
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(log.condition.emoji)
                            .font(.title2)
                        Text(log.condition.rawValue)
                            .font(.caption)
                            .foregroundColor(Color.secondaryText)
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.caption)
                                .foregroundColor(Color.primaryBlue)
                            Text("\(log.duration)분")
                                .font(.caption2)
                                .foregroundColor(Color.secondaryText)
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
    
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            Text("훈련 중 코칭 받은 내용")
                .font(.title2.bold())
                .foregroundColor(Color.primaryText)
            VStack(alignment: .leading, spacing: DesignConstants.smallSpacing) {
                Text(log.coachingNotes)
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
    
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            Text("오늘 훈련 중 잘한 것들")
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
    
    private var shortcomingsSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            Text("부족한 것들")
                .font(.title2.bold())
                .foregroundColor(Color.primaryText)
            VStack(alignment: .leading, spacing: DesignConstants.smallSpacing) {
                ForEach(log.shortcomings, id: \.self) { shortcoming in
                    HStack(alignment: .top, spacing: DesignConstants.smallSpacing) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                            .padding(.top, 2)
                        Text(shortcoming)
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
    @State private var coachingNotes: String
    @State private var duration: Int
    @State private var selectedCategories: [PersonalTrainingLog.TrainingCategory]
    @State private var selectedCondition: PersonalTrainingLog.TrainingCondition
    @State private var achievements: [String]
    @State private var shortcomings: [String]
    @State private var nextGoals: [String]
    @State private var selectedDate: Date
    @State private var isTeam: Bool
    
    init(log: PersonalTrainingLog) {
        self.log = log
        _title = State(initialValue: log.title)
        _coachingNotes = State(initialValue: log.coachingNotes)
        _duration = State(initialValue: log.duration)
        _selectedCategories = State(initialValue: log.categories)
        _selectedCondition = State(initialValue: log.condition)
        _achievements = State(initialValue: log.achievements)
        _shortcomings = State(initialValue: log.shortcomings)
        _nextGoals = State(initialValue: log.nextGoals)
        _selectedDate = State(initialValue: log.date)
        _isTeam = State(initialValue: log.isTeam)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignConstants.sectionSpacing) {
                    dateSelectionSection
                    basicInfoSection
                    trainingDetailsSection
                    achievementsSection
                    shortcomingsSection
                    nextGoalsSection
                }
                .padding(DesignConstants.horizontalPadding)
            }
            .background(Color.pageBackground)
            .navigationTitle("훈련일지 편집")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장") { saveLog() }
                        .disabled(title.isEmpty || coachingNotes.isEmpty || selectedCategories.isEmpty)
                }
            }
        }
    }
    
    private var dateSelectionSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            Text("훈련 정보")
                .font(.title2.bold())
                .foregroundColor(Color.primaryText)
            DatePicker("날짜 선택", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(.compact)
                .labelsHidden()
                .environment(\.locale, Locale(identifier: "ko_KR"))
        }
    }
    
    private var basicInfoSection: some View {
        VStack(spacing: DesignConstants.smallSpacing) {
            TextField("훈련 제목", text: $title)
                .textFieldStyle(.roundedBorder)
            TextEditor(text: $coachingNotes)
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
    
    private var trainingDetailsSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            Text("훈련 세부사항")
                .font(.title2.bold())
                .foregroundColor(Color.primaryText)
            VStack(spacing: DesignConstants.smallSpacing) {
                // Category (multi-select)
                VStack(alignment: .leading, spacing: DesignConstants.smallSpacing) {
                    Text("훈련 카테고리 (복수 선택)")
                        .font(.subheadline)
                        .foregroundColor(Color.secondaryText)
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: DesignConstants.smallSpacing) {
                        ForEach(PersonalTrainingLog.TrainingCategory.allCases, id: \.self) { category in
                            Button(action: {
                                if selectedCategories.contains(category) {
                                    selectedCategories.removeAll { $0 == category }
                                } else {
                                    selectedCategories.append(category)
                                }
                            }) {
                                HStack {
                                    Image(systemName: category.icon)
                                        .foregroundColor(selectedCategories.contains(category) ? .white : Color.primaryBlue)
                                    Text(category.rawValue)
                                        .font(.caption)
                                        .foregroundColor(selectedCategories.contains(category) ? .white : Color.primaryBlue)
                                }
                                .padding(.horizontal, DesignConstants.cardPadding)
                                .padding(.vertical, DesignConstants.smallSpacing)
                                .background(
                                    RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                                        .fill(selectedCategories.contains(category) ? Color.primaryBlue : Color.primaryBlue.opacity(0.1))
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                // Condition (emoji)
                VStack(alignment: .leading, spacing: DesignConstants.smallSpacing) {
                    Text("훈련 컨디션")
                        .font(.subheadline)
                        .foregroundColor(Color.secondaryText)
                    HStack(spacing: DesignConstants.smallSpacing) {
                        ForEach(PersonalTrainingLog.TrainingCondition.allCases, id: \.self) { condition in
                            Button(action: {
                                selectedCondition = condition
                            }) {
                                VStack(spacing: 4) {
                                    Text(condition.emoji)
                                        .font(.title2)
                                    Text(condition.rawValue)
                                        .font(.caption2)
                                        .foregroundColor(selectedCondition == condition ? .white : Color.primaryText)
                                }
                                .padding(.horizontal, DesignConstants.cardPadding)
                                .padding(.vertical, DesignConstants.smallSpacing)
                                .background(
                                    RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                                        .fill(selectedCondition == condition ? Color.primaryBlue : Color.cardBackground)
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
    
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            HStack {
                Text("오늘 훈련 중 잘한 것들")
                    .font(.title2.bold())
                    .foregroundColor(Color.primaryText)
                Spacer()
                Button("추가") { achievements.append("") }
                    .font(.caption)
                    .foregroundColor(Color.primaryBlue)
            }
            ForEach(achievements.indices, id: \.self) { idx in
                HStack {
                    TextField("잘한 점 입력", text: $achievements[idx])
                        .textFieldStyle(.roundedBorder)
                    if achievements.count > 1 {
                        Button(action: { achievements.remove(at: idx) }) {
                            Image(systemName: "minus.circle.fill").foregroundColor(.red)
                        }
                    }
                }
            }
        }
    }
    
    private var shortcomingsSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            HStack {
                Text("부족한 것들")
                    .font(.title2.bold())
                    .foregroundColor(Color.primaryText)
                Spacer()
                Button("추가") { shortcomings.append("") }
                    .font(.caption)
                    .foregroundColor(Color.primaryBlue)
            }
            ForEach(shortcomings.indices, id: \.self) { idx in
                HStack {
                    TextField("부족한 점 입력", text: $shortcomings[idx])
                        .textFieldStyle(.roundedBorder)
                    if shortcomings.count > 1 {
                        Button(action: { shortcomings.remove(at: idx) }) {
                            Image(systemName: "minus.circle.fill").foregroundColor(.red)
                        }
                    }
                }
            }
        }
    }
    
    private var nextGoalsSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            HStack {
                Text("다음 훈련 목표")
                    .font(.title2.bold())
                    .foregroundColor(Color.primaryText)
                Spacer()
                Button("추가") { nextGoals.append("") }
                    .font(.caption)
                    .foregroundColor(Color.primaryBlue)
            }
            ForEach(nextGoals.indices, id: \.self) { idx in
                HStack {
                    TextField("목표 입력", text: $nextGoals[idx])
                        .textFieldStyle(.roundedBorder)
                    if nextGoals.count > 1 {
                        Button(action: { nextGoals.remove(at: idx) }) {
                            Image(systemName: "minus.circle.fill").foregroundColor(.red)
                        }
                    }
                }
            }
        }
    }
    
    private func saveLog() {
        let updatedLog = PersonalTrainingLog(
            date: selectedDate,
            title: title,
            coachingNotes: coachingNotes,
            duration: duration,
            categories: selectedCategories,
            condition: selectedCondition,
            achievements: achievements.filter { !$0.isEmpty },
            shortcomings: shortcomings.filter { !$0.isEmpty },
            nextGoals: nextGoals.filter { !$0.isEmpty },
            isTeam: isTeam
        )
        personalTrainingStore.updateLog(updatedLog)
        dismiss()
    }
}

#Preview {
    PersonalTrainingLogDetailView(
        log: PersonalTrainingLog(
            title: "개인 훈련",
            coachingNotes: "오늘은 드리블 연습을 했습니다.",
            duration: 60,
            categories: [.dribbling],
            condition: .good,
            achievements: ["드리블 성공률 향상"],
            shortcomings: ["체력 부족"],
            nextGoals: ["슈팅 연습"],
            isTeam: false
        )
    )
    .environmentObject(PersonalTrainingStore())
} 