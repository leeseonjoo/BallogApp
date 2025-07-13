import SwiftUI

struct InteractiveCalendarView: View {
    @Binding var selectedDate: Date?
    @Binding var attendance: [Date: Bool]
    var title: String = "팀 캘린더"
    @State private var showFullMonth = false
    @EnvironmentObject private var personalTrainingStore: PersonalTrainingStore

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                Button(showFullMonth ? "닫기" : "전체달력보기") {
                    showFullMonth.toggle()
                }
                .font(.caption)
            }
            DaysOfWeekHeader()
            CalendarGrid(selectedDate: $selectedDate, attendance: $attendance, showFullMonth: showFullMonth)
        }
    }
}

struct DaysOfWeekHeader: View {
    private let days = ["일", "월", "화", "수", "목", "금", "토"]

    var body: some View {
        let columns = Array(repeating: GridItem(.flexible()), count: 7)
        LazyVGrid(columns: columns) {
            ForEach(days, id: \.self) { day in
                Text(day)
                    .frame(maxWidth: .infinity)
                    .font(.caption)
                    .foregroundColor(Color.secondaryText)
            }
        }
    }
}

struct CalendarGrid: View {
    @Binding var selectedDate: Date?
    @Binding var attendance: [Date: Bool]
    var showFullMonth: Bool
    @EnvironmentObject private var personalTrainingStore: PersonalTrainingStore
    
    private let calendar = Calendar.current
    private var monthDays: [Date] {
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
    private var weekDays: [Date] {
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())!.start
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }
    private var days: [Date] { showFullMonth ? monthDays : weekDays }

    var body: some View {
        let columns = Array(repeating: GridItem(.flexible()), count: 7)
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(days, id: \.self) { date in
                let day = calendar.component(.day, from: date)
                VStack(spacing: 2) {
                    Text("\(day)")
                        .frame(maxWidth: .infinity)
                        .font(.caption)
                        .foregroundColor(isToday(date) ? .white : Color.primaryText)
                    
                    // 스티커 표시 (훈련일지가 있는 날)
                    if hasTrainingLog(on: date) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.yellow)
                    }
                    
                    // 정기 훈련 표시
                    if calendar.component(.weekday, from: date) == 3 {
                        Text("정기 훈련")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                    
                    // 출석 표시
                    if let result = attendance[calendar.startOfDay(for: date)] {
                        if result {
                            Circle().fill(Color.green).frame(width: 8, height: 8)
                        } else {
                            Text("X").font(.caption2).foregroundColor(.red)
                        }
                    }
                }
                .frame(minHeight: 60)
                .background(
                    Circle()
                        .fill(isToday(date) ? Color.primaryBlue : Color.clear)
                        .frame(width: 30, height: 30)
                )
                .onTapGesture { selectedDate = date }
            }
        }
    }
    
    private func isToday(_ date: Date) -> Bool {
        calendar.isDate(date, inSameDayAs: Date())
    }
    
    private func hasTrainingLog(on date: Date) -> Bool {
        personalTrainingStore.logs.contains { log in
            calendar.isDate(log.date, inSameDayAs: date)
        }
    }
}
