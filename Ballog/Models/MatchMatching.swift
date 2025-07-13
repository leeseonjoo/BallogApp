import Foundation
import SwiftUI

// 매치 요청 모델
struct MatchRequest: Identifiable, Codable {
    let id: UUID
    let teamId: String
    let teamName: String
    let teamLogo: Data?
    let title: String
    let description: String
    let preferredDate: Date
    let alternativeDates: [Date]
    let location: String
    let fieldFee: Int
    let teamLevel: TeamLevel
    let expectedPlayers: Int
    let maxPlayers: Int
    let contactInfo: String
    let createdAt: Date
    var status: MatchRequestStatus
    var applicants: [MatchApplication]
    
    init(teamId: String, teamName: String, teamLogo: Data? = nil, title: String, description: String, preferredDate: Date, alternativeDates: [Date], location: String, fieldFee: Int, teamLevel: TeamLevel, expectedPlayers: Int, maxPlayers: Int, contactInfo: String) {
        self.id = UUID()
        self.teamId = teamId
        self.teamName = teamName
        self.teamLogo = teamLogo
        self.title = title
        self.description = description
        self.preferredDate = preferredDate
        self.alternativeDates = alternativeDates
        self.location = location
        self.fieldFee = fieldFee
        self.teamLevel = teamLevel
        self.expectedPlayers = expectedPlayers
        self.maxPlayers = maxPlayers
        self.contactInfo = contactInfo
        self.createdAt = Date()
        self.status = .open
        self.applicants = []
    }
}

// 매치 신청 모델
struct MatchApplication: Identifiable, Codable {
    let id: UUID
    let teamId: String
    let teamName: String
    let teamLogo: Data?
    let teamLevel: TeamLevel
    let expectedPlayers: Int
    let contactInfo: String
    let message: String
    let appliedAt: Date
    var status: ApplicationStatus
    
    init(teamId: String, teamName: String, teamLogo: Data? = nil, teamLevel: TeamLevel, expectedPlayers: Int, contactInfo: String, message: String) {
        self.id = UUID()
        self.teamId = teamId
        self.teamName = teamName
        self.teamLogo = teamLogo
        self.teamLevel = teamLevel
        self.expectedPlayers = expectedPlayers
        self.contactInfo = contactInfo
        self.message = message
        self.appliedAt = Date()
        self.status = .pending
    }
}

// 팀 실력 레벨
enum TeamLevel: String, CaseIterable, Codable {
    case beginner = "초급"
    case intermediate = "중급"
    case advanced = "고급"
    case professional = "전문"
    
    var description: String {
        switch self {
        case .beginner:
            return "축구를 처음 시작하는 팀"
        case .intermediate:
            return "기본기를 갖춘 팀"
        case .advanced:
            return "경험이 풍부한 팀"
        case .professional:
            return "전문적인 수준의 팀"
        }
    }
    
    var color: Color {
        switch self {
        case .beginner:
            return .green
        case .intermediate:
            return .blue
        case .advanced:
            return .orange
        case .professional:
            return .red
        }
    }
}

// 매치 요청 상태
enum MatchRequestStatus: String, CaseIterable, Codable {
    case open = "모집중"
    case matched = "매칭완료"
    case cancelled = "취소됨"
    case completed = "완료"
}

// 신청 상태
enum ApplicationStatus: String, CaseIterable, Codable {
    case pending = "대기중"
    case accepted = "수락됨"
    case rejected = "거절됨"
    case cancelled = "취소됨"
}

// 팀 가용성 모델
struct TeamAvailability: Identifiable, Codable {
    let id: UUID
    let teamId: String
    let month: Int // 1-12
    let year: Int
    let availableDates: [Int] // 1-31
    let preferredTimes: [String] // "오전", "오후", "저녁"
    let notes: String?
    
    init(teamId: String, month: Int, year: Int, availableDates: [Int], preferredTimes: [String], notes: String? = nil) {
        self.id = UUID()
        self.teamId = teamId
        self.month = month
        self.year = year
        self.availableDates = availableDates
        self.preferredTimes = preferredTimes
        self.notes = notes
    }
}

// 매치 매칭 스토어
class MatchMatchingStore: ObservableObject {
    @Published var matchRequests: [MatchRequest] = []
    @Published var teamAvailabilities: [TeamAvailability] = []
    
    private let userDefaults = UserDefaults.standard
    private let matchRequestsKey = "MatchRequests"
    private let teamAvailabilitiesKey = "TeamAvailabilities"
    
    init() {
        loadData()
    }
    
    // 매치 요청 추가
    func addMatchRequest(_ request: MatchRequest) {
        matchRequests.insert(request, at: 0)
        saveData()
    }
    
    // 매치 요청 업데이트
    func updateMatchRequest(_ request: MatchRequest) {
        if let index = matchRequests.firstIndex(where: { $0.id == request.id }) {
            matchRequests[index] = request
            saveData()
        }
    }
    
    // 매치 신청 추가
    func applyToMatch(requestId: UUID, application: MatchApplication) {
        if let index = matchRequests.firstIndex(where: { $0.id == requestId }) {
            matchRequests[index].applicants.append(application)
            saveData()
        }
    }
    
    // 팀 가용성 추가/업데이트
    func updateTeamAvailability(_ availability: TeamAvailability) {
        if let index = teamAvailabilities.firstIndex(where: { $0.id == availability.id }) {
            teamAvailabilities[index] = availability
        } else {
            teamAvailabilities.append(availability)
        }
        saveData()
    }
    
    // 특정 월의 팀 가용성 조회
    func getTeamAvailability(teamId: String, month: Int, year: Int) -> TeamAvailability? {
        return teamAvailabilities.first { 
            $0.teamId == teamId && $0.month == month && $0.year == year 
        }
    }
    
    // 실력 차이 계산
    func calculateLevelDifference(level1: TeamLevel, level2: TeamLevel) -> Int {
        let levels = TeamLevel.allCases
        let index1 = levels.firstIndex(of: level1) ?? 0
        let index2 = levels.firstIndex(of: level2) ?? 0
        return abs(index1 - index2)
    }
    
    // 실력 차이가 큰지 확인
    func isSignificantLevelDifference(level1: TeamLevel, level2: TeamLevel) -> Bool {
        return calculateLevelDifference(level1: level1, level2: level2) >= 2
    }
    
    private func saveData() {
        if let encoded = try? JSONEncoder().encode(matchRequests) {
            userDefaults.set(encoded, forKey: matchRequestsKey)
        }
        if let encoded = try? JSONEncoder().encode(teamAvailabilities) {
            userDefaults.set(encoded, forKey: teamAvailabilitiesKey)
        }
    }
    
    private func loadData() {
        if let data = userDefaults.data(forKey: matchRequestsKey),
           let decoded = try? JSONDecoder().decode([MatchRequest].self, from: data) {
            matchRequests = decoded
        }
        if let data = userDefaults.data(forKey: teamAvailabilitiesKey),
           let decoded = try? JSONDecoder().decode([TeamAvailability].self, from: data) {
            teamAvailabilities = decoded
        }
    }
} 