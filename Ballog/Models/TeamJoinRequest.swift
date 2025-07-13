import Foundation

struct TeamJoinRequest: Identifiable, Codable {
    let id = UUID()
    let teamId: UUID
    let applicantId: String
    let applicantName: String
    let applicantMessage: String
    let status: RequestStatus
    let createdAt: Date
    
    enum RequestStatus: String, Codable, CaseIterable {
        case pending = "대기중"
        case approved = "승인됨"
        case rejected = "거절됨"
        
        var color: String {
            switch self {
            case .pending: return "orange"
            case .approved: return "green"
            case .rejected: return "red"
            }
        }
    }
    
    init(teamId: UUID, applicantId: String, applicantName: String, applicantMessage: String, status: RequestStatus = .pending, createdAt: Date = Date()) {
        self.teamId = teamId
        self.applicantId = applicantId
        self.applicantName = applicantName
        self.applicantMessage = applicantMessage
        self.status = status
        self.createdAt = createdAt
    }
}

final class TeamJoinRequestStore: ObservableObject {
    @Published var requests: [TeamJoinRequest] = []
    
    func addRequest(_ request: TeamJoinRequest) {
        requests.append(request)
    }
    
    func updateRequest(_ request: TeamJoinRequest) {
        if let index = requests.firstIndex(where: { $0.id == request.id }) {
            requests[index] = request
        }
    }
    
    func removeRequest(_ request: TeamJoinRequest) {
        requests.removeAll { $0.id == request.id }
    }
    
    func getRequestsForTeam(_ teamId: UUID) -> [TeamJoinRequest] {
        return requests.filter { $0.teamId == teamId }
    }
    
    func getPendingRequestsForTeam(_ teamId: UUID) -> [TeamJoinRequest] {
        return requests.filter { $0.teamId == teamId && $0.status == .pending }
    }
} 