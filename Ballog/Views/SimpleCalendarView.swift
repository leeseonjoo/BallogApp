import SwiftUI

struct SimpleCalendarView: View {
    @Binding var selectedDate: Date?
    var loggedDates: [Date]
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
                Text("\(day)")
                    .frame(maxWidth: .infinity, minHeight: 24)
                    .background(
                        Circle()
                            .stroke(Color.red, lineWidth: 2)
                            .opacity(loggedDates.contains { calendar.isDate($0, inSameDayAs: date) } ? 1 : 0)
                    )
                    .onTapGesture { selectedDate = date }
            }
        }
    }
}


