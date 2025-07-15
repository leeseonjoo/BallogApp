//
//  PersonalTrainingView.swift
//  Ballog
//
//  Created by 이선주 on 7/9/25.
//

import SwiftUI

private enum Layout {
    static let spacing = DesignConstants.spacing
    static let padding = DesignConstants.horizontalPadding
}



struct PersonalTrainingView: View {
    @AppStorage("profileCard") private var storedCard: String = ""
    @EnvironmentObject private var personalTrainingStore: PersonalTrainingStore
    
    @State private var selectedDate: Date? = nil
    @State private var showTrainingLogView = false
    @State private var showGoalSettingView = false

    private var card: ProfileCard? {
        guard let data = storedCard.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(ProfileCard.self, from: data)
    }
    
    private var recentLogs: [PersonalTrainingLog] {
        personalTrainingStore.logs.sorted { $0.date > $1.date }.prefix(3).map { $0 }
    }
    
    private var totalTrainingTime: Int {
        personalTrainingStore.logs.reduce(0) { $0 + $1.duration }
    }
    
    private var totalTrainingCount: Int {
        personalTrainingStore.logs.count
    }
    
    private var averageMood: PersonalTrainingLog.TrainingMood {
        let moods = personalTrainingStore.logs.map { $0.mood }
        let moodCounts = Dictionary(grouping: moods, by: { $0 }).mapValues { $0.count }
        return moodCounts.max(by: { $0.value < $1.value })?.key ?? .normal
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignConstants.sectionSpacing) {
                    // Profile Section
                    if let card = card {
                        profileSection(card: card)
                    }
                    
                    // Calendar Section
                    calendarSection
                    
                    // Training Log Section
                    trainingLogSection
                    
                    // Goals Section
                    goalsSection
                    
                    // Statistics Section
                    statisticsSection
                }
                .padding(DesignConstants.horizontalPadding)
            }
            .background(Color.pageBackground)
        }
        .ballogTopBar(selectedTab: .constant(0))
        .sheet(isPresented: $showTrainingLogView) {
            PersonalTrainingLogView()
                .environmentObject(personalTrainingStore)
        }
        .sheet(isPresented: $showGoalSettingView) {
            PersonalGoalSettingView()
                .environmentObject(personalTrainingStore)
        }
    }
    
    private func profileSection(card: ProfileCard) -> some View {
        VStack(spacing: DesignConstants.sectionHeaderSpacing) {
            HStack {
                VStack(alignment: .leading, spacing: DesignConstants.smallSpacing) {
                    Text("안녕하세요, \(card.nickname)님!")
                        .font(.title2.bold())
                        .foregroundColor(Color.primaryText)
                    
                    Text("오늘도 훈련에 집중해보세요 💪")
                        .font(.subheadline)
                        .foregroundColor(Color.secondaryText)
                }
                Spacer()
                
                Image(systemName: card.iconName)
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(Color.primaryBlue)
            }
            .padding(DesignConstants.cardPadding)
            .background(
                RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                    .fill(Color.cardBackground)
            )
        }
    }
    
    private var calendarSection: some View {
        VStack(spacing: DesignConstants.sectionHeaderSpacing) {
            HStack {
                Text(getCurrentWeekString())
                    .font(.title2.bold())
                    .foregroundColor(Color.primaryText)
                
                Spacer()
                
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("이번달: \(getMonthlyTrainingCount())개")
                        .font(.caption)
                        .foregroundColor(Color.secondaryText)
                }
            }
            
            InteractiveCalendarView(selectedDate: $selectedDate, attendance: $personalTrainingStore.attendance, title: "개인 캘린더")
                .padding(DesignConstants.cardPadding)
                .background(
                    RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                        .fill(Color.cardBackground)
                )
        }
    }
    
    private func getCurrentWeekString() -> String {
        let calendar = Calendar.current
        let now = Date()
        let month = calendar.component(.month, from: now)
        let weekOfMonth = calendar.component(.weekOfMonth, from: now)
        
        return "\(month)월 \(weekOfMonth)주차"
    }
    
    private func getMonthlyTrainingCount() -> Int {
        let calendar = Calendar.current
        let now = Date()
        let month = calendar.component(.month, from: now)
        let year = calendar.component(.year, from: now)
        
        return personalTrainingStore.logs.filter { log in
            let logMonth = calendar.component(.month, from: log.date)
            let logYear = calendar.component(.year, from: log.date)
            return logMonth == month && logYear == year
        }.count
    }
    
    private var trainingLogSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            trainingLogHeader
            trainingLogContent
        }
    }
    
    private var trainingLogHeader: some View {
        HStack {
            Text("📝 훈련일지")
                .font(.title2.bold())
                .foregroundColor(Color.primaryText)
            Spacer()
        }
    }
    
    private var trainingLogContent: some View {
        VStack(spacing: DesignConstants.smallSpacing) {
            writeLogButton
            recentLogsSection
        }
    }
    
    private var writeLogButton: some View {
        Button(action: {
            showTrainingLogView = true
        }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(Color.primaryBlue)
                Text("훈련일지 작성하기")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color.primaryBlue)
                Spacer()
            }
            .padding(DesignConstants.cardPadding)
            .background(
                RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                    .fill(Color.primaryBlue.opacity(0.1))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var recentLogsSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.smallSpacing) {
            Text("최근 훈련일지")
                .font(.headline)
                .foregroundColor(Color.primaryText)
            
            if recentLogs.isEmpty {
                emptyLogsView
            } else {
                logsListView
            }
        }
    }
    
    private var emptyLogsView: some View {
        VStack(spacing: DesignConstants.smallSpacing) {
            Image(systemName: "doc.text")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(Color.secondaryText)
            
            Text("훈련일지를 기록하세요")
                .font(.subheadline)
                .foregroundColor(Color.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(DesignConstants.largePadding)
        .background(
            RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                .fill(Color.cardBackground)
        )
    }
    
    private var logsListView: some View {
        VStack(spacing: 0) {
            ForEach(recentLogs) { log in
                logItemView(log: log)
            }
            
            NavigationLink(destination: PersonalTrainingLogListView()) {
                HStack {
                    Text("전체 보기 →")
                        .font(.caption)
                        .foregroundColor(Color.primaryBlue)
                    Spacer()
                }
                .padding(.top, DesignConstants.smallSpacing)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                .fill(Color.cardBackground)
        )
    }
    
    private func logItemView(log: PersonalTrainingLog) -> some View {
        VStack(alignment: .leading, spacing: DesignConstants.smallSpacing) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(log.title)
                        .font(.subheadline)
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
                Text(log.date, style: .date)
                    .font(.caption)
                    .foregroundColor(Color.secondaryText)
            }
            
            let isLastLog = log.id == recentLogs.last?.id
            if !isLastLog {
                Divider()
                    .padding(.vertical, DesignConstants.smallSpacing)
            }
        }
        .padding(DesignConstants.cardPadding)
    }
    
    private var goalsSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            HStack {
                Text("🎯 목표 관리")
                    .font(.title2.bold())
                    .foregroundColor(Color.primaryText)
                Spacer()
                Button("목표 설정") {
                    showGoalSettingView = true
                }
                .font(.caption)
                .foregroundColor(Color.primaryBlue)
            }
            
            let activeGoals = personalTrainingStore.goals.filter { !$0.isCompleted }
            
            if activeGoals.isEmpty {
                VStack(spacing: DesignConstants.smallSpacing) {
                    Image(systemName: "target")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(Color.secondaryText)
                    
                    Text("목표를 설정하고 달성해보세요")
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
                    ForEach(activeGoals.prefix(3)) { goal in
                        VStack(alignment: .leading, spacing: DesignConstants.smallSpacing) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(goal.title)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(Color.primaryText)
                                    
                                    Text(goal.description)
                                        .font(.caption)
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
                            
                            let isLastGoal = goal.id == activeGoals.prefix(3).last?.id
                            if !isLastGoal {
                                Divider()
                                    .padding(.vertical, DesignConstants.smallSpacing)
                            }
                        }
                        .padding(DesignConstants.cardPadding)
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                        .fill(Color.cardBackground)
                )
                
                if activeGoals.count > 3 {
                    NavigationLink(destination: PersonalGoalListView()) {
                        HStack {
                            Text("전체 목표 보기 →")
                                .font(.caption)
                                .foregroundColor(Color.primaryBlue)
                            Spacer()
                        }
                        .padding(.top, DesignConstants.smallSpacing)
                    }
                }
            }
        }
    }
    
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            HStack {
                Text("📊 훈련 통계")
                    .font(.title2.bold())
                    .foregroundColor(Color.primaryText)
                Spacer()
            }
            
            if personalTrainingStore.logs.isEmpty {
                VStack(spacing: DesignConstants.smallSpacing) {
                    Image(systemName: "chart.bar")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(Color.secondaryText)
                    
                    Text("훈련을 시작하고 통계를 확인해보세요")
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
                    HStack {
                        VStack(alignment: .leading, spacing: DesignConstants.smallSpacing) {
                            Text("총 횟수: \(totalTrainingCount)회")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(Color.primaryText)
                            Text("총 시간: \(totalTrainingTime / 60)시간 \(totalTrainingTime % 60)분")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(Color.primaryText)
                            Text("평균 기분: \(averageMood.emoji) \(averageMood.rawValue)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(Color.primaryText)
                        }
                        Spacer()
                        
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(Color.primaryBlue)
                    }
                    .padding(DesignConstants.cardPadding)
                    .background(
                        RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                            .fill(Color.cardBackground)
                    )
                    
                    NavigationLink(destination: TrainingStatisticsView()) {
                        HStack {
                            Text("상세 통계 보기")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(Color.primaryBlue)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(Color.primaryBlue)
                        }
                        .padding(DesignConstants.cardPadding)
                        .background(
                            RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                                .fill(Color.primaryBlue.opacity(0.1))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}

#Preview {
    PersonalTrainingView()
        .environmentObject(PersonalTrainingStore())
}

