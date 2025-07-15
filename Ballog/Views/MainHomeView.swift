import SwiftUI
import HealthKit

private enum Layout {
    static let spacing = DesignConstants.spacing
    static let padding = DesignConstants.horizontalPadding
}



struct MainHomeView: View {
    @EnvironmentObject private var eventStore: TeamEventStore
    @EnvironmentObject private var personalTrainingStore: PersonalTrainingStore
    @State private var selectedDate: Date? = nil
    @State private var showAllCompetitionEvents = false
    @State private var showAllWeekEvents = false
    @AppStorage("profileCard") private var storedCard: String = ""
    @State private var todayWorkouts: [WorkoutSession] = []
    @State private var isLoadingTodayWorkouts = false
    @State private var julyWorkouts: [WorkoutSession] = []
    @State private var isLoadingJulyWorkouts = false
    @State private var showMonthSheet = false
    @State private var selectedMonth: (year: Int, month: Int)? = nil
    @State private var monthWorkouts: [WorkoutSession] = []
    @State private var isLoadingMonthWorkouts = false

    private var card: ProfileCard? {
        guard let data = storedCard.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(ProfileCard.self, from: data)
    }

    private var competitionEvents: [TeamEvent] {
        let fiveMonthsLater = Calendar.current.date(byAdding: .month, value: 5, to: Date()) ?? Date()
        return eventStore.events.filter { 
            ($0.type == .match || $0.type == .tournament) && $0.date <= fiveMonthsLater
        }.sorted { $0.date < $1.date }
    }

    private var thisWeekEvents: [TeamEvent] {
        eventStore.events.filter {
            Calendar.current.isDate($0.date, equalTo: Date(), toGranularity: .weekOfYear)
        }.sorted { $0.date < $1.date }
    }

    private var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "M월 d일"
        return f
    }

    private var timeFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }

    private func dDay(from date: Date) -> Int {
        let diff = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: date))
        return diff.day ?? 0
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignConstants.sectionSpacing) {
                    // 1. 캘린더 + 이번주 일정 알림 한 줄
                    HStack(alignment: .top, spacing: 12) {
                        InteractiveCalendarView(selectedDate: $selectedDate, attendance: $personalTrainingStore.attendance, title: "캘린더")
                            .environmentObject(personalTrainingStore)
                            .padding(.bottom, 8)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("이번주 일정")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            if let event = thisWeekEvents.first {
                                Text("이번 주 \(event.title) \(dateFormatter.string(from: event.date)) \(event.place)입니다")
                                    .font(.caption2)
                                    .foregroundColor(.primaryBlue)
                                    .lineLimit(1)
                            } else {
                                Text("예정된 일정 없음")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.top, 8)
                    }
                    // 2. 훈련일지 작성 프레임(카드)
                    TrainingLogQuickWriteCard()
                    // 3. 대회/매치 일정(가장 가까운 1개만)
                    if let nearestEvent = competitionEvents.first {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("가장 가까운 대회/매치 일정")
                                .font(.title3.bold())
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(dateFormatter.string(from: nearestEvent.date))  \(nearestEvent.title)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(Color.primaryText)
                                HStack(spacing: 4) {
                                    Text(nearestEvent.type.rawValue)
                                        .font(.caption)
                                        .foregroundColor(nearestEvent.type == .match ? .red : .orange)
                                    Text("•")
                                        .font(.caption)
                                        .foregroundColor(Color.secondaryText)
                                    Text(nearestEvent.place)
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
                    // 4. 통계(피트니스 스타일) 섹션 (실제 통계 뷰로 대체)
                    fitnessStatisticsSection
                }
                .padding(DesignConstants.horizontalPadding)
                .onAppear {
                    loadJulyWorkouts()
                }
                .sheet(isPresented: $showMonthSheet) {
                    MonthSelectorView(onSelect: { year, month in
                        selectedMonth = (year, month)
                        loadMonthWorkouts(year: year, month: month)
                    },
                    monthWorkouts: monthWorkouts,
                    isLoading: isLoadingMonthWorkouts,
                    selectedMonth: selectedMonth)
                }
            }
            .background(Color.pageBackground)
        }
        .ballogTopBar()
    }
    
    private func characterCardSection(card: ProfileCard) -> some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            HStack {
                HStack(spacing: DesignConstants.smallSpacing) {
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(Color.primaryBlue)
                    Text("내 캐릭터")
                        .font(.title2.bold())
                        .foregroundColor(Color.primaryText)
                }
                Spacer()
            }
            
            ProfileCardView(card: card, showIcon: true, iconOnRight: true, showRecordButton: true)
        }
    }

    // 대회/매치 일정 섹션 (최대 2개, 더보기)
    private var competitionEventsSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            HStack {
                Text("대회/매치 일정")
                    .font(.title2.bold())
                    .foregroundColor(Color.primaryText)
                Spacer()
                if competitionEvents.count > 2 {
                    Button(action: { showAllCompetitionEvents.toggle() }) {
                        Text(showAllCompetitionEvents ? "접기" : "더보기")
                            .font(.caption)
                            .foregroundColor(Color.primaryBlue)
                    }
                }
            }
            VStack(alignment: .leading, spacing: 0) {
                let eventsToShow = showAllCompetitionEvents ? competitionEvents : Array(competitionEvents.prefix(2))
                if eventsToShow.isEmpty {
                    Text("등록된 일정이 없습니다")
                        .foregroundColor(Color.secondaryText)
                        .padding(DesignConstants.cardPadding)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    ForEach(eventsToShow) { event in
                        VStack(alignment: .leading, spacing: DesignConstants.smallSpacing) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("\(dateFormatter.string(from: event.date)) \(event.title)")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(Color.primaryText)
                                    HStack(spacing: 4) {
                                        Text(event.type.rawValue)
                                            .font(.caption)
                                            .foregroundColor(event.type == .match ? .red : .orange)
                                        Text("•")
                                            .font(.caption)
                                            .foregroundColor(Color.secondaryText)
                                        Text(event.place)
                                            .font(.caption)
                                            .foregroundColor(Color.secondaryText)
                                    }
                                }
                                Spacer()
                                Text("D-day \(dDay(from: event.date))")
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: DesignConstants.smallCornerRadius)
                                            .fill(Color.primaryBlue.opacity(0.1))
                                    )
                                    .foregroundColor(Color.primaryBlue)
                            }
                        }
                        .padding(DesignConstants.cardPadding)
                        .background(
                            RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                                .fill(Color.cardBackground)
                        )
                        if event.id != eventsToShow.last?.id {
                            Divider().padding(.vertical, DesignConstants.smallSpacing)
                        }
                    }
                }
            }
        }
    }
    // 이번주 일정 섹션 (최대 2개, 더보기)
    private var thisWeekEventsSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            HStack {
                Text("이번주 일정")
                    .font(.title2.bold())
                    .foregroundColor(Color.primaryText)
                Spacer()
                if thisWeekEvents.count > 2 {
                    Button(action: { showAllWeekEvents.toggle() }) {
                        Text(showAllWeekEvents ? "접기" : "더보기")
                            .font(.caption)
                            .foregroundColor(Color.primaryBlue)
                    }
                }
            }
            VStack(alignment: .leading, spacing: 0) {
                let eventsToShow = showAllWeekEvents ? thisWeekEvents : Array(thisWeekEvents.prefix(2))
                if eventsToShow.isEmpty {
                    Text("등록된 일정이 없습니다")
                        .foregroundColor(Color.secondaryText)
                        .padding(DesignConstants.cardPadding)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    ForEach(eventsToShow) { event in
                        VStack(alignment: .leading, spacing: DesignConstants.smallSpacing) {
                            HStack {
                                Text("\(timeFormatter.string(from: event.date)) | \(event.title)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(Color.primaryText)
                                Spacer()
                            }
                            Text("장소: \(event.place)")
                                .font(.caption)
                                .foregroundColor(Color.secondaryText)
                        }
                        .padding(DesignConstants.cardPadding)
                        .background(
                            RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                                .fill(Color.cardBackground)
                        )
                        if event.id != eventsToShow.last?.id {
                            Divider().padding(.vertical, DesignConstants.smallSpacing)
                        }
                    }
                }
            }
        }
    }
    // 피트니스 스타일 통계 섹션 (실제 통계 뷰로 대체)
    private var fitnessStatisticsSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            HStack {
                Text("통계")
                    .font(.title2.bold())
                    .foregroundColor(Color.primaryText)
                Spacer()
            }
            TrainingStatisticsView()
                .padding(.top, 8)
        }
    }

    private func loadTodayWorkouts() {
        isLoadingTodayWorkouts = true
        HealthKitManager.shared.fetchTodayWorkouts { result in
            self.todayWorkouts = result
            self.isLoadingTodayWorkouts = false
        }
    }
    private func loadJulyWorkouts() {
        isLoadingJulyWorkouts = true
        let year = Calendar.current.component(.year, from: Date())
        HealthKitManager.shared.fetchWorkouts(forYear: year, month: 7) { result in
            self.julyWorkouts = result
            self.isLoadingJulyWorkouts = false
        }
    }
    private func loadMonthWorkouts(year: Int, month: Int) {
        isLoadingMonthWorkouts = true
        HealthKitManager.shared.fetchWorkouts(forYear: year, month: month) { result in
            self.monthWorkouts = result
            self.isLoadingMonthWorkouts = false
        }
    }
}

// 최근 운동 세션 카드 (예쁘게 개선)
struct RecentWorkoutSection: View {
    @State private var sessions: [WorkoutSession] = []
    @State private var isLoading = false
    @State private var showMoreSessions = false
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                Text("최근 운동 세션")
                    .font(.title3.bold())
                Spacer()
            }
            if isLoading {
                ProgressView()
            } else if sessions.isEmpty {
                Text("운동 세션 기록이 없습니다.")
                    .foregroundColor(.secondary)
            } else {
                SessionCard(session: sessions[0])
                if sessions.count > 1 {
                    Button("더보기") { showMoreSessions = true }
                        .font(.subheadline)
                        .padding(.top, 4)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
        .sheet(isPresented: $showMoreSessions) {
            MoreSessionsSheet(sessions: Array(sessions.dropFirst()))
        }
        .onAppear {
            isLoading = true
            HealthKitManager.shared.fetchRecentWorkouts(limit: 10) { result in
                self.sessions = result
                self.isLoading = false
            }
        }
    }
}

struct MonthWorkoutSection: View {
    let title: String
    let workouts: [WorkoutSession]
    let isLoading: Bool
    let showMore: () -> Void
    let showMoreText: String
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.title3.bold())
                Spacer()
                Button(showMoreText, action: showMore)
                    .font(.subheadline)
            }
            if isLoading {
                ProgressView()
            } else if workouts.isEmpty {
                Text("해당 월에 기록된 운동 세션이 없습니다.")
                    .foregroundColor(.secondary)
            } else {
                ForEach(workouts) { session in
                    HStack {
                        Text(activityTypeName(session.activityType))
                            .font(.headline)
                        Spacer()
                        Text(String(format: "%.2f km", session.distance/1000))
                            .foregroundColor(.primaryBlue)
                        Text("\(Int(session.calories)) kcal")
                            .foregroundColor(.orange)
                    }
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
        }
        .padding(.vertical, 12)
    }
    private func activityTypeName(_ type: HKWorkoutActivityType) -> String {
        switch type {
        case .running: return "러닝"
        case .walking: return "걷기"
        case .cycling: return "사이클링"
        case .soccer: return "축구"
        case .traditionalStrengthTraining: return "근력운동"
        case .functionalStrengthTraining: return "코어/서킷"
        case .yoga: return "요가"
        case .swimming: return "수영"
        case .other: return "기타"
        default: return String(describing: type)
        }
    }
}

struct MonthSelectorView: View {
    let onSelect: (Int, Int) -> Void
    let monthWorkouts: [WorkoutSession]
    let isLoading: Bool
    let selectedMonth: (year: Int, month: Int)?
    @Environment(\.dismiss) private var dismiss
    @State private var year: Int = Calendar.current.component(.year, from: Date())
    @State private var month: Int = Calendar.current.component(.month, from: Date())
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                HStack {
                    Picker("연도", selection: $year) {
                        ForEach((2020...Calendar.current.component(.year, from: Date())), id: \.self) { y in
                            Text("\(y)년").tag(y)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    Picker("월", selection: $month) {
                        ForEach(1...12, id: \.self) { m in
                            Text("\(m)월").tag(m)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    Button("조회") {
                        onSelect(year, month)
                    }
                }
                .padding(.top, 16)
                Divider()
                MonthWorkoutSection(
                    title: selectedMonth != nil ? "\(selectedMonth!.month)월 세션 요약" : "월별 세션 요약",
                    workouts: monthWorkouts,
                    isLoading: isLoading,
                    showMore: {},
                    showMoreText: ""
                )
                Spacer()
            }
            .navigationTitle("월별 세션 조회")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("닫기") { dismiss() }
                }
            }
        }
    }
}

// 훈련일지 작성 프레임(카드)
struct TrainingLogQuickWriteCard: View {
    @State private var showWriteSheet = false
    var body: some View {
        Button(action: { showWriteSheet = true }) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("오늘 훈련일지 작성")
                        .font(.title3.bold())
                        .foregroundColor(.primaryText)
                    Text("한 번의 클릭으로 오늘의 훈련을 기록하세요!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "pencil.and.outline")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .foregroundColor(.primaryBlue)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 18).fill(Color.primaryBlue.opacity(0.08)))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.primaryBlue, lineWidth: 1)
            )
        }
        .sheet(isPresented: $showWriteSheet) {
            PersonalTrainingLogView() // 실제 훈련일지 작성 뷰로 연결
        }
        .padding(.vertical, 8)
    }
}

// 파일 하단에 MoreSessionsSheet 추가
struct MoreSessionsSheet: View {
    let sessions: [WorkoutSession]
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationView {
            List(sessions) { session in
                SessionCard(session: session)
            }
            .navigationTitle("운동 세션 전체보기")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("닫기") { dismiss() }
                }
            }
        }
    }
}


