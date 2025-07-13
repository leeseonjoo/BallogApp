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
            ScrollView {
                VStack(spacing: DesignConstants.sectionSpacing) {
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
            .onChange(of: viewModel.confirmedMatch?.id) { _ in
                if let match = viewModel.confirmedMatch,
                   let date = Self.date(from: match.date, timeRange: match.timeRange) {
                    let title = "매치 \(match.teamA) vs \(match.teamB ?? "?")"
                    let event = TeamEvent(title: title, date: date, place: match.court.name, type: .match)
                    eventStore.add(event)
                }
            }
        }
        .ballogTopBar()
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

// MARK: - 프리뷰
struct TeamCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        TeamCalendarView()
    }
}
