import SwiftUI

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
                    // 1. 개인 캘린더 최상단 배치
                    InteractiveCalendarView(selectedDate: $selectedDate, attendance: $personalTrainingStore.attendance, title: "개인 캘린더")
                        .environmentObject(personalTrainingStore)
                        .padding(.bottom, 8)
                    // 2. 대회/매치 일정 섹션
                    competitionEventsSection
                    // 3. 이번주 일정 섹션
                    thisWeekEventsSection
                    // 4. 통계(피트니스 스타일) 섹션 (실제 통계 뷰로 대체)
                    fitnessStatisticsSection
                }
                .padding(DesignConstants.horizontalPadding)
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
}


