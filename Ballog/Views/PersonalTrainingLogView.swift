import SwiftUI

struct PersonalTrainingLogView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var personalTrainingStore: PersonalTrainingStore
    
    @State private var title = ""
    @State private var coachingNotes = ""
    @State private var duration = 60
    @State private var selectedCategories: [PersonalTrainingLog.TrainingCategory] = []
    @State private var selectedCondition: PersonalTrainingLog.TrainingCondition = .good
    @State private var achievements: [String] = [""]
    @State private var shortcomings: [String] = [""]
    @State private var nextGoals: [String] = [""]
    @State private var selectedDate = Date()
    @State private var isTeam = false
    @State private var startTime = Date()
    @State private var endTime = Date()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignConstants.sectionSpacing) {
                    // 팀/개인 토글
                    teamToggleSection
                    // 날짜
                    dateSelectionSection
                    // 기본 정보
                    basicInfoSection
                    // 훈련 세부사항
                    trainingDetailsSection
                    // 오늘 훈련 중 잘한 것들
                    achievementsSection
                    // 부족한 것들
                    shortcomingsSection
                    // 다음 훈련 목표
                    nextGoalsSection
                }
                .padding(DesignConstants.horizontalPadding)
            }
            .background(Color.pageBackground)
            .navigationTitle("훈련일지 작성")
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
    
    private var teamToggleSection: some View {
        HStack {
            Text("개인")
                .foregroundColor(isTeam ? .secondary : .primary)
            Toggle("", isOn: $isTeam)
                .labelsHidden()
            Text("팀")
                .foregroundColor(isTeam ? .primary : .secondary)
        }
        .padding(.vertical, 8)
    }
    
    private var dateSelectionSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            Text("훈련 정보")
                .font(.title2.bold())
                .foregroundColor(Color.primaryText)
            VStack(alignment: .leading, spacing: 8) {
                DatePicker("날짜 선택", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .environment(\.locale, Locale(identifier: "ko_KR"))
                    .onTapGesture(count: 2) {
                        // SwiftUI DatePicker는 완전한 더블클릭 지정 지원은 없으나, 이 방식으로 최대한 반영
                    }
                HStack {
                    Text("운동 시작 시간")
                        .font(.subheadline)
                    Spacer()
                    DatePicker("시작 시간", selection: $startTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .environment(\.locale, Locale(identifier: "ko_KR"))
                }
                HStack {
                    Text("운동 끝 시간")
                        .font(.subheadline)
                    Spacer()
                    DatePicker("끝 시간", selection: $endTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .environment(\.locale, Locale(identifier: "ko_KR"))
                }
            }
            .padding(DesignConstants.cardPadding)
            .background(
                RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                    .fill(Color.cardBackground)
            )
        }
    }
    
    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            // '기본 정보' 텍스트 삭제
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
    }
    
    private var trainingDetailsSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            Text("훈련 세부사항")
                .font(.title2.bold())
                .foregroundColor(Color.primaryText)
            VStack(spacing: DesignConstants.smallSpacing) {
                // 훈련 시간 Stepper 삭제
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
        let log = PersonalTrainingLog(
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
        personalTrainingStore.addLog(log)
        dismiss()
    }
}

#Preview {
    PersonalTrainingLogView()
        .environmentObject(PersonalTrainingStore())
} 