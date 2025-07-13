import SwiftUI

struct EnhancedCalendarView: View {
    @StateObject private var networkService = CalendarNetworkService()
    @State private var calendarData: CalendarMonthResponse?
    @State private var selectedDate: Date = Date()
    @State private var showingEventSheet = false
    @State private var isLoading = false
    @State private var events: [NetworkCalendarEvent] = []
    @State private var eventsLoading = false
    
    var body: some View {
        VStack(spacing: DesignConstants.sectionSpacing) {
            // 헤더
            calendarHeader
            
            // 로딩 상태
            if isLoading {
                ProgressView("달력 데이터를 불러오는 중...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let data = calendarData {
                // 달력 그리드
                calendarGrid(data: data)
                
                // 이벤트 목록
                eventsList
            } else {
                // 오류 상태
                errorView
            }
        }
        .padding(DesignConstants.horizontalPadding)
        .background(Color.pageBackground)
        .onAppear {
            loadCurrentCalendar()
            loadEvents()
        }
        .sheet(isPresented: $showingEventSheet) {
            EnhancedEventCreationView(networkService: networkService, onEventAdded: {
                loadEvents()
            })
        }
    }
    
    private var calendarHeader: some View {
        HStack {
            VStack(alignment: .leading) {
                if let data = calendarData {
                    Text("\(data.monthName) \(data.year)")
                        .font(.title2.bold())
                        .foregroundColor(Color.primaryText)
                    
                    Text("\(data.totalWeeks)주차")
                        .font(.subheadline)
                        .foregroundColor(Color.secondaryText)
                } else {
                    Text("달력")
                        .font(.title2.bold())
                        .foregroundColor(Color.primaryText)
                }
            }
            
            Spacer()
            
            Button("일정 추가") {
                showingEventSheet = true
            }
            .foregroundColor(Color.primaryBlue)
        }
    }
    
    private func calendarGrid(data: CalendarMonthResponse) -> some View {
        VStack(spacing: 8) {
            // 요일 헤더
            HStack(spacing: 0) {
                ForEach(["일", "월", "화", "수", "목", "금", "토"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .foregroundColor(Color.secondaryText)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // 달력 그리드
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 4) {
                ForEach(data.weeks, id: \.weekNumber) { week in
                    ForEach(week.days, id: \.date) { day in
                        CalendarDayView(day: day, isSelected: isSelectedDate(day))
                            .onTapGesture {
                                selectDate(day)
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
    
    private var eventsList: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            Text("이번달 일정")
                .font(.headline)
                .foregroundColor(Color.primaryText)
            
            if eventsLoading {
                ProgressView("일정 불러오는 중...")
            } else if events.isEmpty {
                Text("일정이 없습니다")
                    .font(.subheadline)
                    .foregroundColor(Color.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                LazyVStack(spacing: DesignConstants.smallSpacing) {
                    ForEach(events, id: \.id) { event in
                        EventRowView(event: event)
                    }
                }
            }
        }
    }
    
    private var errorView: some View {
        VStack(spacing: DesignConstants.largeSpacing) {
            Image(systemName: "exclamationmark.triangle")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundColor(Color.primaryOrange)
            
            VStack(spacing: DesignConstants.smallSpacing) {
                Text("달력을 불러올 수 없습니다")
                    .font(.headline)
                    .foregroundColor(Color.primaryText)
                
                if let errorMessage = networkService.errorMessage {
                    Text(errorMessage)
                        .font(.subheadline)
                        .foregroundColor(Color.secondaryText)
                        .multilineTextAlignment(.center)
                }
                
                Button("다시 시도") {
                    loadCurrentCalendar()
                    loadEvents()
                }
                .foregroundColor(Color.primaryBlue)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func loadCurrentCalendar() {
        Task {
            isLoading = true
            if let data = await networkService.getCurrentCalendar() {
                await MainActor.run {
                    calendarData = data
                }
            }
            await MainActor.run {
                isLoading = false
            }
        }
    }
    
    private func loadEvents() {
        Task {
            eventsLoading = true
            if let loaded = await networkService.getEvents() {
                await MainActor.run {
                    events = loaded
                }
            }
            await MainActor.run {
                eventsLoading = false
            }
        }
    }
    
    private func selectDate(_ day: CalendarDay) {
        // 날짜 선택 로직
        if let date = parseDate(day.date) {
            selectedDate = date
        }
    }
    
    private func isSelectedDate(_ day: CalendarDay) -> Bool {
        guard let date = parseDate(day.date) else { return false }
        return Calendar.current.isDate(date, inSameDayAs: selectedDate)
    }
    
    private func parseDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString)
    }
}

struct CalendarDayView: View {
    let day: CalendarDay
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 2) {
            Text("\(day.day)")
                .font(.caption)
                .foregroundColor(dayColor)
            
            if day.isToday {
                Circle()
                    .fill(Color.primaryBlue)
                    .frame(width: 4, height: 4)
            }
        }
        .frame(width: 35, height: 35)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isSelected ? Color.primaryBlue.opacity(0.2) : Color.clear)
        )
    }
    
    private var dayColor: Color {
        if day.isToday {
            return .white
        } else if day.isCurrentMonth {
            return Color.primaryText
        } else {
            return Color.secondaryText
        }
    }
}

struct EventRowView: View {
    let event: NetworkCalendarEvent
    
    var body: some View {
        HStack {
            Image(systemName: eventTypeIcon)
                .foregroundColor(eventTypeColor)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.primaryText)
                
                Text(event.date)
                    .font(.caption)
                    .foregroundColor(Color.secondaryText)
                
                if !event.description.isEmpty {
                    Text(event.description)
                        .font(.caption)
                        .foregroundColor(Color.tertiaryText)
                        .lineLimit(2)
                }
            }
            
            Spacer()
        }
        .padding(DesignConstants.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                .fill(Color.cardBackground)
        )
    }
    
    private var eventTypeIcon: String {
        switch event.type {
        case "training": return "figure.walk"
        case "match": return "sportscourt"
        case "personal": return "person"
        default: return "calendar"
        }
    }
    
    private var eventTypeColor: Color {
        switch event.type {
        case "training": return .blue
        case "match": return .red
        case "personal": return .green
        default: return .gray
        }
    }
}

struct EnhancedEventCreationView: View {
    @ObservedObject var networkService: CalendarNetworkService
    var onEventAdded: (() -> Void)? = nil
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var selectedType = "training"
    @State private var description = ""
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationStack {
            Form {
                Section("일정 정보") {
                    TextField("제목", text: $title)
                    
                    Picker("유형", selection: $selectedType) {
                        Text("훈련").tag("training")
                        Text("경기").tag("match")
                        Text("개인").tag("personal")
                    }
                    .pickerStyle(.segmented)
                    
                    DatePicker("날짜", selection: $selectedDate, displayedComponents: [.date])
                    
                    TextField("설명", text: $description, axis: .vertical)
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
                        saveEvent()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func saveEvent() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: selectedDate)
        
        Task {
            if await networkService.addEvent(title: title, date: dateString, type: selectedType, description: description) != nil {
                await MainActor.run {
                    dismiss()
                    onEventAdded?()
                }
            }
        }
    }
}

#Preview {
    EnhancedCalendarView()
} 