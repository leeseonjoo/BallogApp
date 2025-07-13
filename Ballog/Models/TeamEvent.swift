import Foundation

struct TeamEvent: Identifiable, Codable {
    enum EventType: String, Codable, CaseIterable { 
        case match = "매치"
        case training = "훈련"
        case tournament = "대회"
        case regularTraining = "정기훈련"
    }
    
    enum MatchResult: String, Codable { case win = "승", loss = "패", draw = "무승부" }
    enum TrainingType: String, Codable, CaseIterable {
        case technical = "기술훈련"
        case tactical = "전술훈련"
        case physical = "체력훈련"
        case matchPractice = "경기연습"
        case other = "기타"
    }
    
    let id = UUID()
    var date: Date
    var title: String
    var place: String
    var type: EventType
    var trainingType: TrainingType?
    var isRecurring: Bool = false
    var recurringWeekday: Int? // 1=일요일, 2=월요일, ..., 7=토요일
    var endDate: Date? // 반복 종료일
    
    // Match specific properties
    var opponent: String?
    var matchType: String?
    var ourScore: Int?
    var opponentScore: Int?
    var result: MatchResult?
    var notes: String?
    
    // Tournament specific properties
    var tournamentName: String?
    var tournamentRound: String?
    
    init(title: String, date: Date, place: String, type: EventType, opponent: String? = nil, matchType: String? = nil) {
        self.title = title
        self.date = date
        self.place = place
        self.type = type
        self.opponent = opponent
        self.matchType = matchType
    }
    
    // 정기 훈련용 초기화
    init(title: String, date: Date, place: String, trainingType: TrainingType, recurringWeekday: Int, endDate: Date) {
        self.title = title
        self.date = date
        self.place = place
        self.type = .regularTraining
        self.trainingType = trainingType
        self.isRecurring = true
        self.recurringWeekday = recurringWeekday
        self.endDate = endDate
    }
    
    // 대회용 초기화
    init(title: String, date: Date, place: String, tournamentName: String, tournamentRound: String?) {
        self.title = title
        self.date = date
        self.place = place
        self.type = .tournament
        self.tournamentName = tournamentName
        self.tournamentRound = tournamentRound
    }
}
