import SwiftUI

/// 팀 탭에서 매치 관리 기능을 보여준다.
struct MatchManagementView: View {
    @EnvironmentObject private var attendanceStore: AttendanceStore

    var body: some View {
        VStack {
            TeamCalendarView()
            if !attendanceStore.results.isEmpty {
                List(attendanceStore.results.sorted(by: { $0.key < $1.key }), id: \.key) { date, result in
                    Text(date, style: .date) + Text(result ? " 참석" : " 불참")
                }
            }
        }
        .navigationTitle("매치 관리")
    }
}

#Preview {
    MatchManagementView().environmentObject(AttendanceStore())
}
