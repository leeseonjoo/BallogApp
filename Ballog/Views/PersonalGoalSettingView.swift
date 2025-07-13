import SwiftUI

struct PersonalGoalSettingView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var personalTrainingStore: PersonalTrainingStore
    
    @State private var title = ""
    @State private var description = ""
    @State private var targetDate = Date().addingTimeInterval(30 * 24 * 60 * 60) // 30일 후
    @State private var selectedCategory: PersonalTrainingLog.TrainingCategory = .fitness
    @State private var progress = 0
    
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
                }
                .padding(DesignConstants.horizontalPadding)
            }
            .background(Color.pageBackground)
            .navigationTitle("목표 설정")
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
    
    private func saveGoal() {
        let goal = PersonalGoal(
            title: title,
            description: description,
            targetDate: targetDate,
            category: selectedCategory,
            progress: progress
        )
        
        personalTrainingStore.addGoal(goal)
        dismiss()
    }
}

#Preview {
    PersonalGoalSettingView()
        .environmentObject(PersonalTrainingStore())
} 