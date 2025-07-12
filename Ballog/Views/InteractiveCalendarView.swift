import SwiftUI

struct InteractiveCalendarView: View {
    @Binding var selectedDate: Date?
    @Binding var attendance: [Date: Bool]
    var title: String = "팀 캘린더"
    @State private var showFullMonth = false

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
            }
        }
    }
}

struct CalendarGrid: View {
    @Binding var selectedDate: Date?
    @Binding var attendance: [Date: Bool]
    var showFullMonth: Bool
    private let calendar = Calendar.current
    private var monthDays: [Date] {
        let start = calendar.date(from: calendar.dateComponents([.year, .month], from: Date()))!
        let range = calendar.range(of: .day, in: .month, for: start)!
        return range.compactMap { calendar.date(byAdding: .day, value: $0 - 1, to: start) }
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
                    Spacer(minLength: 16)
                    if calendar.component(.weekday, from: date) == 3 {
                        Text("정기 훈련")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                    if let result = attendance[calendar.startOfDay(for: date)] {
                        if result {
                            Circle().fill(Color.green).frame(width: 8, height: 8)
                        } else {
                            Text("X").font(.caption2).foregroundColor(.red)
                        }
                    }
                }
                .frame(minHeight: 60)
                .onTapGesture { selectedDate = date }
            }
        }
    }
}
