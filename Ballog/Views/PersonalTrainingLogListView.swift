import SwiftUI

struct PersonalTrainingLogListView: View {
    @EnvironmentObject private var personalTrainingStore: PersonalTrainingStore
    @State private var selectedCategory: PersonalTrainingLog.TrainingCategory? = nil
    
    private var filteredLogs: [PersonalTrainingLog] {
        let sortedLogs = personalTrainingStore.logs.sorted { $0.date > $1.date }
        if let category = selectedCategory {
            return sortedLogs.filter { $0.category == category }
        }
        return sortedLogs
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter Section
                filterSection
                
                // Logs List
                if filteredLogs.isEmpty {
                    emptyStateView
                } else {
                    logsList
                }
            }
            .background(Color.pageBackground)
            .navigationTitle("훈련일지")
            .navigationBarTitleDisplayMode(.large)
        }
        .ballogTopBar(selectedTab: .constant(0))
    }
    
    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignConstants.smallSpacing) {
                Button(action: {
                    selectedCategory = nil
                }) {
                    Text("전체")
                        .font(.caption)
                        .padding(.horizontal, DesignConstants.cardPadding)
                        .padding(.vertical, DesignConstants.smallSpacing)
                        .background(
                            RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                                .fill(selectedCategory == nil ? Color.primaryBlue : Color.cardBackground)
                        )
                        .foregroundColor(selectedCategory == nil ? .white : Color.primaryText)
                }
                
                ForEach(PersonalTrainingLog.TrainingCategory.allCases, id: \.self) { category in
                    Button(action: {
                        selectedCategory = selectedCategory == category ? nil : category
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: category.icon)
                                .font(.caption)
                            Text(category.rawValue)
                                .font(.caption)
                        }
                        .padding(.horizontal, DesignConstants.cardPadding)
                        .padding(.vertical, DesignConstants.smallSpacing)
                        .background(
                            RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                                .fill(selectedCategory == category ? Color.primaryBlue : Color.cardBackground)
                        )
                        .foregroundColor(selectedCategory == category ? .white : Color.primaryText)
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
            
            Image(systemName: "doc.text")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundColor(Color.secondaryText)
            
            Text("훈련일지가 없습니다")
                .font(.title3.bold())
                .foregroundColor(Color.primaryText)
            
            Text("첫 번째 훈련일지를 작성해보세요")
                .font(.subheadline)
                .foregroundColor(Color.secondaryText)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding(DesignConstants.horizontalPadding)
    }
    
    private var logsList: some View {
        ScrollView {
            LazyVStack(spacing: DesignConstants.smallSpacing) {
                ForEach(filteredLogs) { log in
                    NavigationLink(destination: PersonalTrainingLogDetailView(log: log)) {
                        logCard(log: log)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(DesignConstants.horizontalPadding)
        }
    }
    
    private func logCard(log: PersonalTrainingLog) -> some View {
        VStack(alignment: .leading, spacing: DesignConstants.smallSpacing) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(log.title)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(Color.primaryText)
                    
                    HStack(spacing: 8) {
                        Image(systemName: log.category.icon)
                            .font(.caption)
                            .foregroundColor(Color.primaryBlue)
                        Text(log.category.rawValue)
                            .font(.caption)
                            .foregroundColor(Color.secondaryText)
                        Text("\(log.duration)분")
                            .font(.caption)
                            .foregroundColor(Color.secondaryText)
                        Text(log.mood.emoji)
                            .font(.caption)
                    }
                }
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(log.date, style: .date)
                        .font(.caption)
                        .foregroundColor(Color.secondaryText)
                    
                    Text(log.date, style: .time)
                        .font(.caption)
                        .foregroundColor(Color.secondaryText)
                }
            }
            
            if !log.content.isEmpty {
                Text(log.content)
                    .font(.subheadline)
                    .foregroundColor(Color.secondaryText)
                    .lineLimit(2)
            }
            
            if !log.goals.isEmpty || !log.achievements.isEmpty {
                HStack(spacing: DesignConstants.smallSpacing) {
                    if !log.goals.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "target")
                                .font(.caption)
                                .foregroundColor(Color.primaryBlue)
                            Text("목표 \(log.goals.count)개")
                                .font(.caption)
                                .foregroundColor(Color.primaryBlue)
                        }
                    }
                    
                    if !log.achievements.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle")
                                .font(.caption)
                                .foregroundColor(Color.successColor)
                            Text("달성 \(log.achievements.count)개")
                                .font(.caption)
                                .foregroundColor(Color.successColor)
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

#Preview {
    PersonalTrainingLogListView()
        .environmentObject(PersonalTrainingStore())
} 