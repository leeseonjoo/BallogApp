import SwiftUI

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

// MARK: - ViewModel
class TeamCalendarViewModel: ObservableObject {
    @Published var myTeamAvailability: [Availability] = []
    @Published var opponentTeamAvailability: [Availability] = []
    @Published var commonAvailability: [Availability] = []
    
    @Published var courts: [FutsalCourt] = []
    @Published var confirmedMatch: MatchInfo?
    @Published var publicMatches: [MatchInfo] = []
    
    init() {
        loadDummyData()
        calculateCommonAvailability()
        loadCourts()
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
}

// MARK: - View
struct TeamCalendarView: View {
    @StateObject var viewModel = TeamCalendarViewModel()
    @State private var selectedAvailability: Availability?
    @State private var showCourtSheet = false
    @State private var showPublicMatchList = false
    @EnvironmentObject private var eventStore: TeamEventStore
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("우리 팀 가용 시간")) {
                    ForEach(viewModel.myTeamAvailability) { availability in
                        Text("\(availability.day) \(availability.timeRange) (\(availability.myTeamCount)명)")
                    }
                }
                
                Section(header: Text("상대 팀 가용 시간")) {
                    ForEach(viewModel.opponentTeamAvailability) { availability in
                        Text("\(availability.day) \(availability.timeRange) (\(availability.opponentTeamCount)명)")
                    }
                }
                
                Section(header: Text("공통 가용 시간")) {
                    ForEach(viewModel.commonAvailability) { availability in
                        Button(action: {
                            selectedAvailability = availability
                            showCourtSheet = true
                        }) {
                            Text("\(availability.day) \(availability.timeRange) (합계 \(availability.totalCount)명)")
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            .navigationTitle("팀 캘린더 매칭")
            .sheet(isPresented: $showCourtSheet) {
                if let availability = selectedAvailability {
                    CourtSelectionView(viewModel: viewModel, availability: availability, dismissTrigger: { showCourtSheet = false })
                }
            }
            .sheet(isPresented: $showPublicMatchList) {
                PublicMatchListView(viewModel: viewModel)
            }
            .toolbar {
                Button("공개 매치 리스트") {
                    showPublicMatchList = true
                }
            }
            .alert(item: $viewModel.confirmedMatch) { match in
                Alert(title: Text("매치 확정!"), message: Text("날짜: \(match.date)\n시간: \(match.timeRange)\n구장: \(match.court.name)\n팀: \(match.teamA) vs \(match.teamB ?? "?")"), dismissButton: .default(Text("확인")))
            }
            .onChange(of: viewModel.confirmedMatch) { match in
                if let match = match,
                   let date = Self.date(from: match.date, timeRange: match.timeRange) {
                    let title = "매치 \(match.teamA) vs \(match.teamB ?? "?")"
                    let event = TeamEvent(date: date, title: title, place: match.court.name, type: .match)
                    eventStore.add(event)
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

struct CourtSelectionView: View {
    @ObservedObject var viewModel: TeamCalendarViewModel
    let availability: Availability
    let dismissTrigger: () -> Void
    @State private var isPrivateMatch = false
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                Toggle("비공개 초대 매치", isOn: $isPrivateMatch)
                    .padding()
                
                List {
                    ForEach(viewModel.courts.filter { $0.availableTimeRanges.contains(availability.timeRange) }) { court in
                        Button(action: {
                            viewModel.confirmMatch(selectedDay: availability.day, selectedTimeRange: availability.timeRange, selectedCourt: court, isPrivate: isPrivateMatch)
                            dismissTrigger()
                        }) {
                            Text("\(court.name) - \(court.location)")
                        }
                    }
                }
            }
            .navigationTitle("구장 선택")
        }
    }
}

struct PublicMatchListView: View {
    @ObservedObject var viewModel: TeamCalendarViewModel
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.publicMatches) { match in
                    VStack(alignment: .leading) {
                        Text("날짜: \(match.date)")
                        Text("시간: \(match.timeRange)")
                        Text("구장: \(match.court.name)")
                        Text("팀: \(match.teamA) vs ?")
                    }
                }
            }
            .navigationTitle("공개 매치 리스트")
        }
    }
}

// MARK: - 프리뷰
struct TeamCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        TeamCalendarView()
    }
}
