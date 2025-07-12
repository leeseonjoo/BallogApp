import SwiftUI

/// 피드 탭에서 팀 캘린더 매칭 기능을 보여준다.
struct FeedView: View {
    @EnvironmentObject private var attendanceStore: AttendanceStore

    var body: some View {
        VStack {
            TeamCalendarView()
            if !attendanceStore.results.isEmpty {
                List(attendanceStore.results.sorted(by: { $0.key < $1.key }), id: \\.key) { date, result in
                    Text(date, style: .date) + Text(result ? " 참석" : " 불참")
                }
            }
        }
    }
}

#Preview {
    FeedView()
}
