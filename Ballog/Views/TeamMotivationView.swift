import SwiftUI

struct TeamMotivationView: View {
    let team: Team
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var teamGoalStore: TeamGoalStore
    @AppStorage("profileCard") private var storedCard: String = ""
    
    @State private var title = ""
    @State private var content = ""
    @State private var selectedType: TeamMotivation.MotivationType = .encouragement
    
    private var userCard: ProfileCard? {
        guard let data = storedCard.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(ProfileCard.self, from: data)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignConstants.sectionSpacing) {
                    // Basic Info Section
                    basicInfoSection
                    
                    // Type Selection Section
                    typeSelectionSection
                    
                    // Content Section
                    contentSection
                    
                    // Preview Section
                    previewSection
                }
                .padding(DesignConstants.horizontalPadding)
            }
            .background(Color.pageBackground)
            .navigationTitle("팀 동기부여")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장") {
                        saveMotivation()
                    }
                    .disabled(title.isEmpty || content.isEmpty)
                }
            }
        }
    }
    
    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            Text("동기부여 정보")
                .font(.title2.bold())
                .foregroundColor(Color.primaryText)
            
            VStack(spacing: DesignConstants.smallSpacing) {
                TextField("제목", text: $title)
                    .textFieldStyle(.roundedBorder)
                    .placeholder(when: title.isEmpty) {
                        Text("동기부여 제목을 입력하세요")
                            .foregroundColor(Color.secondaryText)
                    }
            }
        }
    }
    
    private var typeSelectionSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            Text("동기부여 유형")
                .font(.title2.bold())
                .foregroundColor(Color.primaryText)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: DesignConstants.smallSpacing) {
                ForEach(TeamMotivation.MotivationType.allCases, id: \.self) { type in
                    Button(action: {
                        selectedType = type
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: type.icon)
                                .font(.title2)
                                .foregroundColor(selectedType == type ? .white : Color.primaryBlue)
                            Text(type.rawValue)
                                .font(.caption)
                                .foregroundColor(selectedType == type ? .white : Color.primaryBlue)
                        }
                        .padding(.horizontal, DesignConstants.cardPadding)
                        .padding(.vertical, DesignConstants.smallSpacing)
                        .background(
                            RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                                .fill(selectedType == type ? Color.primaryBlue : Color.primaryBlue.opacity(0.1))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            Text("동기부여 내용")
                .font(.title2.bold())
                .foregroundColor(Color.primaryText)
            
            VStack(spacing: DesignConstants.smallSpacing) {
                TextEditor(text: $content)
                    .frame(minHeight: 150)
                    .padding(DesignConstants.cardPadding)
                    .background(
                        RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                            .fill(Color.cardBackground)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                            .stroke(Color.borderColor, lineWidth: 1)
                    )
                
                HStack {
                    Text("\(content.count)자")
                        .font(.caption)
                        .foregroundColor(Color.secondaryText)
                    Spacer()
                    Text("최대 500자")
                        .font(.caption)
                        .foregroundColor(Color.secondaryText)
                }
            }
        }
    }
    
    private var previewSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            Text("미리보기")
                .font(.title2.bold())
                .foregroundColor(Color.primaryText)
            
            VStack(alignment: .leading, spacing: DesignConstants.smallSpacing) {
                HStack {
                    Image(systemName: selectedType.icon)
                        .font(.caption)
                        .foregroundColor(Color.primaryBlue)
                    Text(selectedType.rawValue)
                        .font(.caption)
                        .foregroundColor(Color.secondaryText)
                    Spacer()
                    Text(Date(), style: .date)
                        .font(.caption)
                        .foregroundColor(Color.secondaryText)
                }
                
                Text(title.isEmpty ? "제목을 입력하세요" : title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(title.isEmpty ? Color.secondaryText : Color.primaryText)
                
                Text(content.isEmpty ? "내용을 입력하세요" : content)
                    .font(.subheadline)
                    .foregroundColor(content.isEmpty ? Color.secondaryText : Color.primaryText)
                    .lineLimit(5)
            }
            .padding(DesignConstants.cardPadding)
            .background(
                RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                    .fill(Color.cardBackground)
            )
        }
    }
    
    private func saveMotivation() {
        guard let userCard = userCard else { return }
        
        let motivation = TeamMotivation(
            teamId: team.id,
            title: title,
            content: content,
            type: selectedType,
            createdBy: userCard.nickname
        )
        
        teamGoalStore.addMotivation(motivation)
        dismiss()
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

#Preview {
    TeamMotivationView(team: Team(name: "샘플팀", region: "서울", creatorName: "홍길동"))
        .environmentObject(TeamGoalStore())
} 