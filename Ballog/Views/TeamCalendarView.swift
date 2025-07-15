import SwiftUI
import EventKit

// MARK: - 모델 구조
struct Availability: Identifiable, Hashable {
    let id = UUID()
    let day: String
    let timeRange: String
    let myTeamCount: Int
    let opponentTeamCount: Int
    
    var totalCount: Int {
        myTeamCount + opponentTeamCount
    }
}

struct FutsalCourt: Identifiable {
    let id = UUID()
    let name: String
    let location: String
    let availableTimeRanges: [String]
}

struct MatchInfo: Identifiable {
    let id = UUID()
    let date: String
    let timeRange: String
    let court: FutsalCourt
    let teamA: String
    let teamB: String?
    let isPrivate: Bool
}

struct CalendarEvent: Identifiable {
    let id = UUID()
    let title: String
    let date: Date
    let type: EventType
    let notes: String?
}

enum EventType {
    case match, training, personal
    
    var icon: String {
        switch self {
        case .match: return "sportscourt"
        case .training: return "figure.walk"
        case .personal: return "person"
        }
    }
    
    var color: Color {
        switch self {
        case .match: return .red
        case .training: return .blue
        case .personal: return .green
        }
    }
}

// MARK: - ViewModel
class TeamCalendarViewModel: ObservableObject {
    @Published var myTeamAvailability: [Availability] = []
    @Published var opponentTeamAvailability: [Availability] = []
    @Published var commonAvailability: [Availability] = []
    
    @Published var courts: [FutsalCourt] = []
    @Published var confirmedMatch: MatchInfo?
    @Published var publicMatches: [MatchInfo] = []
    @Published var events: [CalendarEvent] = []
    @Published var selectedDate: Date = Date()
    @Published var showingEventSheet = false
    @Published var showingCalendarIntegration = false
    
    private let eventStore = EKEventStore()
    
    init() {
        loadDummyData()
        calculateCommonAvailability()
        loadCourts()
        loadEvents()
    }
    
    func getCurrentWeekString() -> String {
        let calendar = Calendar.current
        let now = Date()
        let month = calendar.component(.month, from: now)
        let weekOfYear = calendar.component(.weekOfYear, from: now)
        let weekOfMonth = calendar.component(.weekOfMonth, from: now)
        
        return "\(month)월 \(weekOfMonth)주차"
    }
    
    func loadDummyData() {
        myTeamAvailability = [
            Availability(day: "월요일", timeRange: "18:00~20:00", myTeamCount: 6, opponentTeamCount: 0),
            Availability(day: "수요일", timeRange: "19:00~21:00", myTeamCount: 8, opponentTeamCount: 0)
        ]
        opponentTeamAvailability = [
            Availability(day: "수요일", timeRange: "19:00~21:00", myTeamCount: 0, opponentTeamCount: 7),
            Availability(day: "금요일", timeRange: "20:00~22:00", myTeamCount: 0, opponentTeamCount: 6)
        ]
    }
    
    func calculateCommonAvailability() {
        var commonDict: [String: (Int, Int)] = [:]
        
        for my in myTeamAvailability {
            for opponent in opponentTeamAvailability {
                if my.day == opponent.day && my.timeRange == opponent.timeRange {
                    commonDict["\(my.day)|\(my.timeRange)"] = (my.myTeamCount, opponent.opponentTeamCount)
                }
            }
        }
        
        commonAvailability = commonDict.map { key, value in
            let components = key.split(separator: "|")
            return Availability(day: String(components[0]), timeRange: String(components[1]), myTeamCount: value.0, opponentTeamCount: value.1)
        }
    }
    
    func loadCourts() {
        courts = [
            FutsalCourt(name: "OO풋살장 A코트", location: "서울", availableTimeRanges: ["19:00~21:00", "20:00~22:00"]),
            FutsalCourt(name: "XX풋살장 B코트", location: "서울", availableTimeRanges: ["18:00~20:00"])
        ]
    }
    
    func loadEvents() {
        // 샘플 이벤트들
        events = [
            CalendarEvent(title: "팀 훈련", date: Date().addingTimeInterval(86400), type: .training, notes: "기술 훈련"),
            CalendarEvent(title: "친선 경기", date: Date().addingTimeInterval(172800), type: .match, notes: "OO팀과 경기")
        ]
    }
    
    func addEvent(_ event: CalendarEvent) {
        events.append(event)
    }
    
    func confirmMatch(selectedDay: String, selectedTimeRange: String, selectedCourt: FutsalCourt, isPrivate: Bool) {
        confirmedMatch = MatchInfo(
            date: selectedDay,
            timeRange: selectedTimeRange,
            court: selectedCourt,
            teamA: "팀 A",
            teamB: nil,
            isPrivate: isPrivate
        )
        if !isPrivate {
            publicMatches.append(confirmedMatch!)
        }
    }
    
    func requestCalendarAccess() async -> Bool {
        if #available(iOS 17.0, *) {
            return await withCheckedContinuation { continuation in
                eventStore.requestFullAccessToEvents { granted, error in
                    continuation.resume(returning: granted)
                }
            }
        } else {
            return await withCheckedContinuation { continuation in
                eventStore.requestAccess(to: .event) { granted, error in
                    continuation.resume(returning: granted)
                }
            }
        }
    }
    
    func addToExternalCalendar(_ event: CalendarEvent) {
        Task {
            let granted = await requestCalendarAccess()
            if granted {
                await MainActor.run {
                    let ekEvent = EKEvent(eventStore: eventStore)
                    ekEvent.title = event.title
                    ekEvent.startDate = event.date
                    ekEvent.endDate = event.date.addingTimeInterval(3600) // 1시간
                    ekEvent.notes = event.notes
                    ekEvent.calendar = eventStore.defaultCalendarForNewEvents
                    
                    do {
                        try eventStore.save(ekEvent, span: .thisEvent)
                        print("이벤트가 캘린더에 추가되었습니다")
                    } catch {
                        print("캘린더 추가 실패: \(error)")
                    }
                }
            }
        }
    }
    
    func getStickerCountForMonth() -> Int {
        let calendar = Calendar.current
        let now = Date()
        let month = calendar.component(.month, from: now)
        let year = calendar.component(.year, from: now)
        
        return events.filter { event in
            let eventMonth = calendar.component(.month, from: event.date)
            let eventYear = calendar.component(.year, from: event.date)
            return eventMonth == month && eventYear == year && event.type == .training
        }.count
    }
}

// MARK: - View
struct TeamCalendarView: View {
    @StateObject var viewModel = TeamCalendarViewModel()
    @State private var selectedAvailability: Availability?
    @State private var showCourtSheet = false
    @State private var showPublicMatchList = false
    @EnvironmentObject private var eventStore: TeamEventStore
    @State private var showEnhancedCalendar = false
    
    // 일정 변경 감지를 위한 상태
    @State private var eventUpdateTrigger = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignConstants.sectionSpacing) {
                    // 캘린더 헤더
                    calendarHeaderSection
                    
                    // 이번달 스티커 통계
                    stickerStatisticsSection
                    
                    // 캘린더 뷰
                    calendarViewSection
                    
                    // 이벤트 목록
                    eventsListSection
                    
                    // 우리 팀 가용 시간
                    availabilitySection(
                        title: "우리 팀 가용 시간",
                        availabilities: viewModel.myTeamAvailability,
                        isClickable: false
                    )
                    
                    // 상대 팀 가용 시간
                    availabilitySection(
                        title: "상대 팀 가용 시간",
                        availabilities: viewModel.opponentTeamAvailability,
                        isClickable: false
                    )
                    
                    // 공통 가용 시간
                    availabilitySection(
                        title: "공통 가용 시간",
                        availabilities: viewModel.commonAvailability,
                        isClickable: true
                    )
                }
                .padding(DesignConstants.horizontalPadding)
            }
            .background(Color.pageBackground)
            .navigationTitle(viewModel.getCurrentWeekString())
            .sheet(isPresented: $showCourtSheet) {
                if let availability = selectedAvailability {
                    CourtSelectionView(viewModel: viewModel, availability: availability, dismissTrigger: { showCourtSheet = false })
                }
            }
            .sheet(isPresented: $showPublicMatchList) {
                PublicMatchListView(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.showingEventSheet) {
                TeamEventCreationView()
                    .environmentObject(eventStore)
            }
            .sheet(isPresented: $viewModel.showingCalendarIntegration) {
                CalendarIntegrationView(viewModel: viewModel)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("일정 추가") {
                        viewModel.showingEventSheet = true
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("캘린더 연동") {
                        viewModel.showingCalendarIntegration = true
                    }
                }
            }
            .alert(item: $viewModel.confirmedMatch) { match in
                Alert(title: Text("매치 확정!"), message: Text("날짜: \(match.date)\n시간: \(match.timeRange)\n구장: \(match.court.name)\n팀: \(match.teamA) vs \(match.teamB ?? "?")"), dismissButton: .default(Text("확인")))
            }
            .onChange(of: viewModel.confirmedMatch?.id) { _ in
                if let match = viewModel.confirmedMatch,
                   let date = Self.date(from: match.date, timeRange: match.timeRange) {
                    let title = "매치 \(match.teamA) vs \(match.teamB ?? "?")"
                    let event = TeamEvent(title: title, date: date, place: match.court.name, type: .match)
                    eventStore.add(event)
                }
            }
            .onChange(of: eventStore.events.count) { _ in
                // 일정이 추가되면 캘린더 업데이트
                eventUpdateTrigger.toggle()
            }
            .onChange(of: eventUpdateTrigger) { _ in
                // 캘린더 강제 업데이트
            }
        }
        .ballogTopBar(selectedTab: .constant(0))
    }
    
    private var calendarHeaderSection: some View {
        VStack(spacing: DesignConstants.smallSpacing) {
            HStack {
                Text(viewModel.getCurrentWeekString())
                    .font(.title2.bold())
                    .foregroundColor(Color.primaryText)
                
                Spacer()
                
                Button("오늘") {
                    viewModel.selectedDate = Date()
                }
                .foregroundColor(Color.primaryBlue)
            }
        }
    }
    
    private var stickerStatisticsSection: some View {
        HStack {
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)
            Text("이번달 훈련일지: \(viewModel.getStickerCountForMonth())개")
                .font(.subheadline)
                .foregroundColor(Color.secondaryText)
            Spacer()
        }
        .padding(DesignConstants.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                .fill(Color.cardBackground)
        )
    }
    
    private var calendarViewSection: some View {
        VStack(spacing: DesignConstants.smallSpacing) {
            HStack {
                Text("캘린더 뷰")
                    .font(.headline)
                    .foregroundColor(Color.primaryText)
                
                Spacer()
                
                Button(showEnhancedCalendar ? "기본 캘린더" : "개선된 캘린더") {
                    showEnhancedCalendar.toggle()
                }
                .font(.caption)
                .foregroundColor(Color.primaryBlue)
            }
            
            if showEnhancedCalendar {
                EnhancedCalendarView()
            } else {
                // 기존 간단한 캘린더 뷰
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                    ForEach(["일", "월", "화", "수", "목", "금", "토"], id: \.self) { day in
                        Text(day)
                            .font(.caption)
                            .foregroundColor(Color.secondaryText)
                    }
                    ForEach(getDaysInMonth(), id: \.self) { date in
                        let _ = eventUpdateTrigger // 캐시 무효화를 위한 트리거
                        Button(action: {
                            viewModel.selectedDate = date
                            viewModel.showingEventSheet = true
                        }) {
                            VStack(spacing: 2) {
                                Text("\(Calendar.current.component(.day, from: date))")
                                    .font(.caption)
                                    .foregroundColor(isToday(date) ? .white : Color.primaryText)
                                if let event = hasEvent(on: date) {
                                    Image(systemName: getEventIcon(for: event))
                                        .font(.caption2)
                                        .foregroundColor(getEventColor(for: event))
                                }
                            }
                            .frame(width: 30, height: 30)
                            .background(
                                Circle()
                                    .fill(isToday(date) ? Color.primaryBlue : Color.clear)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
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
    
    private var eventsListSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            Text("일정 목록")
                .font(.title2.bold())
                .foregroundColor(Color.primaryText)
            
            VStack(spacing: DesignConstants.smallSpacing) {
                ForEach(eventStore.events.sorted(by: { $0.date < $1.date })) { event in
                    TeamEventCardWithActions(event: event, eventStore: eventStore) {
                        // 외부 캘린더에 추가
                        let calendarEvent = CalendarEvent(
                            title: event.title,
                            date: event.date,
                            type: event.type == .match ? .match : .training,
                            notes: event.notes
                        )
                        viewModel.addToExternalCalendar(calendarEvent)
                    }
                }
                
                if eventStore.events.isEmpty {
                    Text("등록된 일정이 없습니다")
                        .foregroundColor(Color.secondaryText)
                        .padding()
                }
            }
        }
    }
    
    private func getDaysInMonth() -> [Date] {
        let calendar = Calendar.current
        let now = Date()
        let month = calendar.component(.month, from: now)
        let year = calendar.component(.year, from: now)
        
        guard let monthStart = calendar.date(from: DateComponents(year: year, month: month, day: 1)) else {
            return []
        }
        
        // 해당 월의 첫 주 시작일 (일요일부터 시작)
        let firstWeekday = calendar.component(.weekday, from: monthStart)
        let daysToSubtract = firstWeekday - 1 // 일요일이 1이므로 조정
        
        guard let calendarStart = calendar.date(byAdding: .day, value: -daysToSubtract, to: monthStart) else {
            return []
        }
        
        // 해당 월의 마지막 날
        guard let monthEnd = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: monthStart) else {
            return []
        }
        
        // 마지막 주의 끝까지 포함 (토요일까지)
        let lastWeekday = calendar.component(.weekday, from: monthEnd)
        let daysToAdd = 7 - lastWeekday // 토요일이 7이므로 조정
        
        guard let calendarEnd = calendar.date(byAdding: .day, value: daysToAdd, to: monthEnd) else {
            return []
        }
        
        var dates: [Date] = []
        var currentDate = calendarStart
        
        while currentDate <= calendarEnd {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return dates
    }
    
    private func isToday(_ date: Date) -> Bool {
        Calendar.current.isDate(date, inSameDayAs: Date())
    }
    
    private func hasEvent(on date: Date) -> TeamEvent? {
        return eventStore.events.first { event in
            Calendar.current.isDate(event.date, inSameDayAs: date)
        }
    }
    
    private func getEventIcon(for event: TeamEvent) -> String {
        switch event.type {
        case .match: return "sportscourt"
        case .training: return "figure.walk"
        case .tournament: return "trophy"
        case .regularTraining: return "repeat"
        }
    }
    
    private func getEventColor(for event: TeamEvent) -> Color {
        switch event.type {
        case .match: return .red
        case .training: return .blue
        case .tournament: return .orange
        case .regularTraining: return .green
        }
    }
    
    private func availabilitySection(title: String, availabilities: [Availability], isClickable: Bool) -> some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            Text(title)
                .font(.title2.bold())
                .foregroundColor(Color.primaryText)
            
            VStack(spacing: DesignConstants.smallSpacing) {
                ForEach(availabilities) { availability in
                    if isClickable {
                        Button(action: {
                            selectedAvailability = availability
                            showCourtSheet = true
                        }) {
                            AvailabilityCard(availability: availability, isHighlighted: true)
                        }
                        .buttonStyle(PlainButtonStyle())
                    } else {
                        AvailabilityCard(availability: availability, isHighlighted: false)
                    }
                }
            }
        }
    }

    private static func date(from day: String, timeRange: String) -> Date? {
        let map = ["일요일":1, "월요일":2, "화요일":3, "수요일":4, "목요일":5, "금요일":6, "토요일":7]
        guard let weekday = map[day] else { return nil }
        let startTime = timeRange.split(separator: "~").first ?? "00:00"
        let comps = startTime.split(separator: ":")
        guard comps.count == 2,
              let hour = Int(comps[0]),
              let minute = Int(comps[1]) else { return nil }
        var dateComponents = DateComponents()
        dateComponents.weekday = weekday
        dateComponents.hour = hour
        dateComponents.minute = minute
        return Calendar.current.nextDate(after: Date(), matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)
    }
}

// MARK: - Event Card
struct EventCard: View {
    let event: CalendarEvent
    let onAddToCalendar: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: event.type.icon)
                .foregroundColor(event.type.color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.primaryText)
                
                Text(formatDate(event.date))
                    .font(.caption)
                    .foregroundColor(Color.secondaryText)
                
                if let notes = event.notes {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(Color.tertiaryText)
                }
            }
            
            Spacer()
            
            Button(action: onAddToCalendar) {
                Image(systemName: "calendar.badge.plus")
                    .foregroundColor(Color.primaryBlue)
            }
        }
        .padding(DesignConstants.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                .fill(Color.cardBackground)
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM월 dd일 HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - Event Creation View
struct EventCreationView: View {
    @ObservedObject var viewModel: TeamCalendarViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var selectedType: EventType = .training
    @State private var notes = ""
    @State private var selectedDate: Date
    
    init(viewModel: TeamCalendarViewModel) {
        self.viewModel = viewModel
        self._selectedDate = State(initialValue: viewModel.selectedDate)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("일정 정보") {
                    TextField("제목", text: $title)
                    
                    Picker("유형", selection: $selectedType) {
                        Text("훈련").tag(EventType.training)
                        Text("경기").tag(EventType.match)
                        Text("개인").tag(EventType.personal)
                    }
                    .pickerStyle(.segmented)
                    
                    DatePicker("날짜", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                    
                    TextField("메모", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("일정 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장") {
                        let event = CalendarEvent(
                            title: title,
                            date: selectedDate,
                            type: selectedType,
                            notes: notes.isEmpty ? nil : notes
                        )
                        viewModel.addEvent(event)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

// MARK: - Calendar Integration View
struct CalendarIntegrationView: View {
    @ObservedObject var viewModel: TeamCalendarViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedEvents: Set<UUID> = []
    
    var body: some View {
        NavigationStack {
            List {
                Section("외부 캘린더에 추가할 일정을 선택하세요") {
                    ForEach(viewModel.events) { event in
                        HStack {
                            Image(systemName: event.type.icon)
                                .foregroundColor(event.type.color)
                            
                            VStack(alignment: .leading) {
                                Text(event.title)
                                    .font(.subheadline)
                                Text(formatDate(event.date))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if selectedEvents.contains(event.id) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedEvents.contains(event.id) {
                                selectedEvents.remove(event.id)
                            } else {
                                selectedEvents.insert(event.id)
                            }
                        }
                    }
                }
            }
            .navigationTitle("캘린더 연동")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("추가") {
                        for eventId in selectedEvents {
                            if let event = viewModel.events.first(where: { $0.id == eventId }) {
                                viewModel.addToExternalCalendar(event)
                            }
                        }
                        dismiss()
                    }
                    .disabled(selectedEvents.isEmpty)
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM월 dd일 HH:mm"
        return formatter.string(from: date)
    }
}

struct CourtSelectionView: View {
    @ObservedObject var viewModel: TeamCalendarViewModel
    let availability: Availability
    let dismissTrigger: () -> Void
    @State private var isPrivateMatch = false
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignConstants.sectionSpacing) {
                    // Toggle Section
                    VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
                        Text("매치 설정")
                            .font(.title2.bold())
                            .foregroundColor(Color.primaryText)
                        
                        Toggle("비공개 초대 매치", isOn: $isPrivateMatch)
                            .padding(DesignConstants.cardPadding)
                            .background(
                                RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                                    .fill(Color.cardBackground)
                            )
                    }
                    
                    // Courts Section
                    VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
                        Text("구장 선택")
                            .font(.title2.bold())
                            .foregroundColor(Color.primaryText)
                        
                        VStack(spacing: DesignConstants.smallSpacing) {
                            ForEach(viewModel.courts.filter { $0.availableTimeRanges.contains(availability.timeRange) }) { court in
                                Button(action: {
                                    viewModel.confirmMatch(selectedDay: availability.day, selectedTimeRange: availability.timeRange, selectedCourt: court, isPrivate: isPrivateMatch)
                                    dismissTrigger()
                                }) {
                                    CourtCard(court: court)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                .padding(DesignConstants.horizontalPadding)
            }
            .background(Color.pageBackground)
            .navigationTitle("구장 선택")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct CourtCard: View {
    let court: FutsalCourt
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: DesignConstants.smallSpacing) {
                Text(court.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color.primaryText)
                
                Text(court.location)
                    .font(.caption)
                    .foregroundColor(Color.secondaryText)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(Color.secondaryText)
        }
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

struct PublicMatchListView: View {
    @ObservedObject var viewModel: TeamCalendarViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignConstants.sectionSpacing) {
                    if viewModel.publicMatches.isEmpty {
                        emptyMatchesView
                    } else {
                        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
                            Text("공개 매치")
                                .font(.title2.bold())
                                .foregroundColor(Color.primaryText)
                            
                            VStack(spacing: DesignConstants.smallSpacing) {
                                ForEach(viewModel.publicMatches) { match in
                                    PublicMatchCard(match: match)
                                }
                            }
                        }
                    }
                }
                .padding(DesignConstants.horizontalPadding)
            }
            .background(Color.pageBackground)
            .navigationTitle("공개 매치 리스트")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var emptyMatchesView: some View {
        VStack(spacing: DesignConstants.largeSpacing) {
            Image(systemName: "sportscourt")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundColor(Color.secondaryText)
            
            VStack(spacing: DesignConstants.smallSpacing) {
                Text("공개 매치가 없습니다")
                    .font(.headline)
                    .foregroundColor(Color.primaryText)
                
                Text("새로운 공개 매치를 만들어보세요")
                    .font(.subheadline)
                    .foregroundColor(Color.secondaryText)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(DesignConstants.largePadding)
        .background(
            RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                .fill(Color.cardBackground)
        )
    }
}

struct AvailabilityCard: View {
    let availability: Availability
    let isHighlighted: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: DesignConstants.smallSpacing) {
                Text("\(availability.day) \(availability.timeRange)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color.primaryText)
                
                Text("우리팀 \(availability.myTeamCount)명, 상대팀 \(availability.opponentTeamCount)명")
                    .font(.caption)
                    .foregroundColor(Color.secondaryText)
            }
            
            Spacer()
            
            if isHighlighted {
                Text("합계 \(availability.totalCount)명")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Color.primaryGreen)
            }
        }
        .padding(DesignConstants.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                .fill(isHighlighted ? Color.primaryGreen.opacity(0.1) : Color.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                .stroke(isHighlighted ? Color.primaryGreen.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }
}

struct PublicMatchCard: View {
    let match: MatchInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignConstants.smallSpacing) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(match.date) \(match.timeRange)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Color.primaryText)
                    
                    Text(match.court.name)
                        .font(.caption)
                        .foregroundColor(Color.secondaryText)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(match.teamA) vs ?")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(Color.primaryBlue)
                    
                    Text(match.isPrivate ? "비공개" : "공개")
                        .font(.caption2)
                        .foregroundColor(Color.secondaryText)
                }
            }
        }
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

// MARK: - TeamEventCard
struct TeamEventCard: View {
    let event: TeamEvent
    let onAddToCalendar: () -> Void
    
    private var eventIcon: String {
        switch event.type {
        case .match: return "sportscourt"
        case .training: return "figure.walk"
        case .tournament: return "trophy"
        case .regularTraining: return "repeat"
        }
    }
    
    private var eventColor: Color {
        switch event.type {
        case .match: return .red
        case .training: return .blue
        case .tournament: return .orange
        case .regularTraining: return .green
        }
    }
    

    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignConstants.smallSpacing) {
            HStack {
                Image(systemName: eventIcon)
                    .foregroundColor(eventColor)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(event.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Color.primaryText)
                    
                    HStack(spacing: 4) {
                        Text(event.date, style: .date)
                            .font(.caption)
                            .foregroundColor(Color.secondaryText)
                        
                        Text("•")
                            .font(.caption)
                            .foregroundColor(Color.secondaryText)
                        
                        Text(event.place)
                            .font(.caption)
                            .foregroundColor(Color.secondaryText)
                    }
                }
                
                Spacer()
                
                Button(action: onAddToCalendar) {
                    Image(systemName: "calendar.badge.plus")
                        .foregroundColor(Color.primaryBlue)
                        .font(.caption)
                }
            }
            
            if let notes = event.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(Color.secondaryText)
                    .padding(.leading, 24)
            }
            
            // 매치 정보
            if event.type == .match, let opponent = event.opponent {
                HStack {
                    Text("상대팀: \(opponent)")
                        .font(.caption)
                        .foregroundColor(Color.secondaryText)
                    
                    if let matchType = event.matchType {
                        Text("• \(matchType)")
                            .font(.caption)
                            .foregroundColor(Color.secondaryText)
                    }
                }
                .padding(.leading, 24)
            }
            
            // 대회 정보
            if event.type == .tournament, let tournamentName = event.tournamentName {
                HStack {
                    Text("대회: \(tournamentName)")
                        .font(.caption)
                        .foregroundColor(Color.secondaryText)
                    
                    if let round = event.tournamentRound {
                        Text("• \(round)")
                            .font(.caption)
                            .foregroundColor(Color.secondaryText)
                    }
                }
                .padding(.leading, 24)
            }
            
            // 훈련 정보
            if (event.type == .training || event.type == .regularTraining), let trainingType = event.trainingType {
                HStack {
                    Text("훈련 종류: \(trainingType.rawValue)")
                        .font(.caption)
                        .foregroundColor(Color.secondaryText)
                    
                    if event.isRecurring {
                        Text("• 반복")
                            .font(.caption)
                            .foregroundColor(Color.secondaryText)
                    }
                }
                .padding(.leading, 24)
            }
        }
        .padding(DesignConstants.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                .fill(Color.cardBackground)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}

// MARK: - TeamEventCardWithActions
struct TeamEventCardWithActions: View {
    let event: TeamEvent
    let eventStore: TeamEventStore
    let onAddToCalendar: () -> Void
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignConstants.smallSpacing) {
            HStack {
                Image(systemName: getEventIcon(for: event))
                    .foregroundColor(getEventColor(for: event))
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(event.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Color.primaryText)
                    
                    HStack(spacing: 4) {
                        Text(event.date, style: .date)
                            .font(.caption)
                            .foregroundColor(Color.secondaryText)
                        
                        Text("•")
                            .font(.caption)
                            .foregroundColor(Color.secondaryText)
                        
                        Text(event.place)
                            .font(.caption)
                            .foregroundColor(Color.secondaryText)
                    }
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    Button(action: onAddToCalendar) {
                        Image(systemName: "calendar.badge.plus")
                            .foregroundColor(Color.primaryBlue)
                            .font(.caption)
                    }
                    
                    Button(action: { showingEditSheet = true }) {
                        Image(systemName: "pencil")
                            .foregroundColor(Color.primaryBlue)
                            .font(.caption)
                    }
                    
                    Button(action: { showingDeleteAlert = true }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            
            if let notes = event.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(Color.secondaryText)
                    .padding(.leading, 24)
            }
            
            // 매치 정보
            if event.type == .match, let opponent = event.opponent {
                HStack {
                    Text("상대팀: \(opponent)")
                        .font(.caption)
                        .foregroundColor(Color.secondaryText)
                    
                    if let matchType = event.matchType {
                        Text("• \(matchType)")
                            .font(.caption)
                            .foregroundColor(Color.secondaryText)
                    }
                }
                .padding(.leading, 24)
            }
            
            // 대회 정보
            if event.type == .tournament, let tournamentName = event.tournamentName {
                HStack {
                    Text("대회: \(tournamentName)")
                        .font(.caption)
                        .foregroundColor(Color.secondaryText)
                    
                    if let round = event.tournamentRound {
                        Text("• \(round)")
                            .font(.caption)
                            .foregroundColor(Color.secondaryText)
                    }
                }
                .padding(.leading, 24)
            }
            
            // 훈련 정보
            if (event.type == .training || event.type == .regularTraining), let trainingType = event.trainingType {
                HStack {
                    Text("훈련 종류: \(trainingType.rawValue)")
                        .font(.caption)
                        .foregroundColor(Color.secondaryText)
                    
                    if event.isRecurring {
                        Text("• 반복")
                            .font(.caption)
                            .foregroundColor(Color.secondaryText)
                    }
                }
                .padding(.leading, 24)
            }
        }
        .padding(DesignConstants.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                .fill(Color.cardBackground)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
        .sheet(isPresented: $showingEditSheet) {
            TeamEventEditView(event: event, eventStore: eventStore)
        }
        .alert("일정 삭제", isPresented: $showingDeleteAlert) {
            Button("취소", role: .cancel) { }
            Button("삭제", role: .destructive) {
                eventStore.removeEvent(event)
            }
        } message: {
            Text("이 일정을 삭제하시겠습니까?")
        }
    }
    
    private func getEventIcon(for event: TeamEvent) -> String {
        switch event.type {
        case .match: return "sportscourt"
        case .training: return "figure.walk"
        case .tournament: return "trophy"
        case .regularTraining: return "repeat"
        }
    }
    
    private func getEventColor(for event: TeamEvent) -> Color {
        switch event.type {
        case .match: return .red
        case .training: return .blue
        case .tournament: return .orange
        case .regularTraining: return .green
        }
    }
}

// MARK: - TeamEventEditView
struct TeamEventEditView: View {
    let event: TeamEvent
    let eventStore: TeamEventStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String
    @State private var selectedDate: Date
    @State private var place: String
    @State private var selectedEventType: TeamEvent.EventType
    @State private var selectedTrainingType: TeamEvent.TrainingType
    @State private var isRecurring: Bool
    @State private var selectedWeekday: Int
    @State private var endDate: Date
    @State private var opponent: String
    @State private var matchType: String
    @State private var tournamentName: String
    @State private var tournamentRound: String
    @State private var notes: String
    
    private let weekdays = [
        (1, "일요일"), (2, "월요일"), (3, "화요일"), (4, "수요일"),
        (5, "목요일"), (6, "금요일"), (7, "토요일")
    ]
    
    init(event: TeamEvent, eventStore: TeamEventStore) {
        self.event = event
        self.eventStore = eventStore
        
        // 초기값 설정
        self._title = State(initialValue: event.title)
        self._selectedDate = State(initialValue: event.date)
        self._place = State(initialValue: event.place)
        self._selectedEventType = State(initialValue: event.type)
        self._selectedTrainingType = State(initialValue: event.trainingType ?? .technical)
        self._isRecurring = State(initialValue: event.isRecurring)
        self._selectedWeekday = State(initialValue: event.recurringWeekday ?? 2)
        self._endDate = State(initialValue: event.endDate ?? Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date())
        self._opponent = State(initialValue: event.opponent ?? "")
        self._matchType = State(initialValue: event.matchType ?? "")
        self._tournamentName = State(initialValue: event.tournamentName ?? "")
        self._tournamentRound = State(initialValue: event.tournamentRound ?? "")
        self._notes = State(initialValue: event.notes ?? "")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // 기본 정보
                Section("기본 정보") {
                    TextField("일정 제목", text: $title)
                    
                    DatePicker("날짜", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                    
                    TextField("장소 (풋살장 이름)", text: $place)
                }
                
                // 일정 타입
                Section("일정 타입") {
                    Picker("타입", selection: $selectedEventType) {
                        ForEach(TeamEvent.EventType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // 훈련 타입 (훈련이나 정기훈련일 때만)
                if selectedEventType == .training || selectedEventType == .regularTraining {
                    Section("훈련 종류") {
                        Picker("훈련 종류", selection: $selectedTrainingType) {
                            ForEach(TeamEvent.TrainingType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                
                // 정기 훈련 설정
                if selectedEventType == .regularTraining {
                    Section("반복 설정") {
                        Toggle("매주 반복", isOn: $isRecurring)
                        
                        if isRecurring {
                            Picker("요일", selection: $selectedWeekday) {
                                ForEach(weekdays, id: \.0) { weekday in
                                    Text(weekday.1).tag(weekday.0)
                                }
                            }
                            .pickerStyle(.menu)
                            
                            DatePicker("종료일", selection: $endDate, displayedComponents: .date)
                        }
                    }
                }
                
                // 매치 정보
                if selectedEventType == .match {
                    Section("매치 정보") {
                        TextField("상대팀", text: $opponent)
                        TextField("경기 종류", text: $matchType)
                    }
                }
                
                // 대회 정보
                if selectedEventType == .tournament {
                    Section("대회 정보") {
                        TextField("대회명", text: $tournamentName)
                        TextField("라운드", text: $tournamentRound)
                    }
                }
                
                // 메모
                Section("메모") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("일정 수정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장") {
                        updateEvent()
                        dismiss()
                    }
                    .disabled(title.isEmpty || place.isEmpty)
                }
            }
        }
    }
    
    private func updateEvent() {
        var updatedEvent = event
        
        // 기본 정보 업데이트
        updatedEvent.title = title
        updatedEvent.date = selectedDate
        updatedEvent.place = place
        updatedEvent.type = selectedEventType
        updatedEvent.notes = notes
        
        // 타입별 정보 업데이트
        switch selectedEventType {
        case .training:
            updatedEvent.trainingType = selectedTrainingType
            
        case .regularTraining:
            if isRecurring {
                updatedEvent.trainingType = selectedTrainingType
                updatedEvent.isRecurring = true
                updatedEvent.recurringWeekday = selectedWeekday
                updatedEvent.endDate = endDate
            } else {
                updatedEvent.trainingType = selectedTrainingType
                updatedEvent.isRecurring = false
            }
            
        case .match:
            updatedEvent.opponent = opponent.isEmpty ? nil : opponent
            updatedEvent.matchType = matchType.isEmpty ? nil : matchType
            
        case .tournament:
            updatedEvent.tournamentName = tournamentName.isEmpty ? nil : tournamentName
            updatedEvent.tournamentRound = tournamentRound.isEmpty ? nil : tournamentRound
        }
        
        eventStore.updateEvent(updatedEvent)
    }
}

// MARK: - 프리뷰
struct TeamCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        TeamCalendarView()
    }
}
