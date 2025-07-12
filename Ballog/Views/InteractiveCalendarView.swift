import SwiftUI

struct InteractiveCalendarView: View {
    @Binding var selectedDate: Date?
    @Binding var attendance: [Date: Bool]
    var body: some View {
        VStack(alignment: .leading) {
            Text("팀 캘린더")
                .font(.headline)
            DaysOfWeekHeader()
            CalendarGrid(selectedDate: $selectedDate, attendance: $attendance)
        }
    }
}

private struct DaysOfWeekHeader: View {
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

private struct CalendarGrid: View {
    @Binding var selectedDate: Date?
    @Binding var attendance: [Date: Bool]
    private let calendar = Calendar.current
    private var monthDays: [Date] {
        let start = calendar.date(from: calendar.dateComponents([.year, .month], from: Date()))!
        let range = calendar.range(of: .day, in: .month, for: start)!
        return range.compactMap { calendar.date(byAdding: .day, value: $0 - 1, to: start) }
    }

    var body: some View {
        let columns = Array(repeating: GridItem(.flexible()), count: 7)
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(monthDays, id: \.self) { date in
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
