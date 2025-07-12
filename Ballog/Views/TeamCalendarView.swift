import SwiftUI

// MARK: - 모델 구조
struct Availability: Identifiable, Hashable {
    let id = UUID()
    let day: String
    let timeRange: String
    let memberCount: Int
}

// MARK: - ViewModel
class TeamCalendarViewModel: ObservableObject {
    @Published var myTeamAvailability: [Availability] = []
    @Published var opponentTeamAvailability: [Availability] = []
    @Published var commonAvailability: [Availability] = []

    init() {
        loadDummyData()
        calculateCommonAvailability()
    }

    func loadDummyData() {
        myTeamAvailability = [
            Availability(day: "월요일", timeRange: "18:00~20:00", memberCount: 6),
            Availability(day: "수요일", timeRange: "19:00~21:00", memberCount: 8)
        ]
        opponentTeamAvailability = [
            Availability(day: "수요일", timeRange: "19:00~21:00", memberCount: 7),
            Availability(day: "금요일", timeRange: "20:00~22:00", memberCount: 6)
        ]
    }

    func calculateCommonAvailability() {
        let mySet = Set(myTeamAvailability.map { "\($0.day)|\($0.timeRange)" })
        let opponentSet = Set(opponentTeamAvailability.map { "\($0.day)|\($0.timeRange)" })
        let commonSet = mySet.intersection(opponentSet)

        commonAvailability = myTeamAvailability.filter { item in
            commonSet.contains("\(item.day)|\(item.timeRange)")
        }
        // 정렬: 인원수가 많은 순 > 요일순
        commonAvailability.sort {
            if $0.memberCount == $1.memberCount {
                return $0.day < $1.day
            }
            return $0.memberCount > $1.memberCount
        }
    }
}

// MARK: - View
struct TeamCalendarView: View {
    @StateObject var viewModel = TeamCalendarViewModel()

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("우리 팀 가용 시간")) {
                    ForEach(viewModel.myTeamAvailability, id: \.\.id) { availability in
                        Text("\(availability.day) \(availability.timeRange) (\(availability.memberCount)명)")
                    }
                }

                Section(header: Text("상대 팀 가용 시간")) {
                    ForEach(viewModel.opponentTeamAvailability, id: \.\.id) { availability in
                        Text("\(availability.day) \(availability.timeRange) (\(availability.memberCount)명)")
                    }
                }

                Section(header: Text("공통 가용 시간")) {
                    ForEach(viewModel.commonAvailability, id: \.\.id) { availability in
                        Text("\(availability.day) \(availability.timeRange) (\(availability.memberCount)명)")
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                }
            }
            .navigationTitle("팀 캘린더 매칭")
        }
    }
}

// MARK: - 프리뷰
#Preview {
    TeamCalendarView()
}
