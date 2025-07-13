import Foundation

struct TeamGoal: Identifiable, Codable {
    let id = UUID()
    let teamId: UUID
    let title: String
    let description: String
    let targetDate: Date
    let category: GoalCategory
    let isCompleted: Bool
    let progress: Int // 0-100
    let createdAt: Date
    let createdBy: String // 생성자 ID
    
    enum GoalCategory: String, Codable, CaseIterable {
        case teamBuilding = "팀워크"
        case skillImprovement = "기술 향상"
        case matchPerformance = "경기 성과"
        case fitness = "체력 관리"
        case tactics = "전술 발전"
        case other = "기타"
        
        var icon: String {
            switch self {
            case .teamBuilding: return "person.3.fill"
            case .skillImprovement: return "arrow.up.circle"
            case .matchPerformance: return "sportscourt"
            case .fitness: return "heart.fill"
            case .tactics: return "brain.head.profile"
            case .other: return "ellipsis.circle"
            }
        }
        
        var color: String {
            switch self {
            case .teamBuilding: return "blue"
            case .skillImprovement: return "green"
            case .matchPerformance: return "orange"
            case .fitness: return "red"
            case .tactics: return "purple"
            case .other: return "gray"
            }
        }
    }
    
    init(teamId: UUID, title: String, description: String, targetDate: Date, category: GoalCategory, isCompleted: Bool = false, progress: Int = 0, createdBy: String) {
        self.teamId = teamId
        self.title = title
        self.description = description
        self.targetDate = targetDate
        self.category = category
        self.isCompleted = isCompleted
        self.progress = progress
        self.createdBy = createdBy
        self.createdAt = Date()
    }
}

struct TeamMotivation: Identifiable, Codable {
    let id = UUID()
    let teamId: UUID
    let title: String
    let content: String
    let type: MotivationType
    let createdAt: Date
    let createdBy: String
    
    enum MotivationType: String, Codable, CaseIterable {
        case quote = "명언"
        case story = "스토리"
        case tip = "팁"
        case achievement = "성과"
        case encouragement = "격려"
        
        var icon: String {
            switch self {
            case .quote: return "quote.bubble"
            case .story: return "book"
            case .tip: return "lightbulb"
            case .achievement: return "trophy"
            case .encouragement: return "heart"
            }
        }
    }
    
    init(teamId: UUID, title: String, content: String, type: MotivationType, createdBy: String) {
        self.teamId = teamId
        self.title = title
        self.content = content
        self.type = type
        self.createdBy = createdBy
        self.createdAt = Date()
    }
}

final class TeamGoalStore: ObservableObject {
    @Published var goals: [TeamGoal] = []
    @Published var motivations: [TeamMotivation] = []
    
    private let goalsKey = "TeamGoals"
    private let motivationsKey = "TeamMotivations"
    
    init() {
        loadData()
    }
    
    func addGoal(_ goal: TeamGoal) {
        goals.append(goal)
        saveGoals()
    }
    
    func updateGoal(_ goal: TeamGoal) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index] = goal
            saveGoals()
        }
    }
    
    func removeGoal(_ goal: TeamGoal) {
        goals.removeAll { $0.id == goal.id }
        saveGoals()
    }
    
    func addMotivation(_ motivation: TeamMotivation) {
        motivations.append(motivation)
        saveMotivations()
    }
    
    func updateMotivation(_ motivation: TeamMotivation) {
        if let index = motivations.firstIndex(where: { $0.id == motivation.id }) {
            motivations[index] = motivation
            saveMotivations()
        }
    }
    
    func removeMotivation(_ motivation: TeamMotivation) {
        motivations.removeAll { $0.id == motivation.id }
        saveMotivations()
    }
    
    func getGoalsForTeam(_ teamId: UUID) -> [TeamGoal] {
        return goals.filter { $0.teamId == teamId }
    }
    
    func getMotivationsForTeam(_ teamId: UUID) -> [TeamMotivation] {
        return motivations.filter { $0.teamId == teamId }
    }
    
    private func saveGoals() {
        if let data = try? JSONEncoder().encode(goals) {
            UserDefaults.standard.set(data, forKey: goalsKey)
        }
    }
    
    private func saveMotivations() {
        if let data = try? JSONEncoder().encode(motivations) {
            UserDefaults.standard.set(data, forKey: motivationsKey)
        }
    }
    
    private func loadData() {
        // Load goals
        if let data = UserDefaults.standard.data(forKey: goalsKey),
           let decodedGoals = try? JSONDecoder().decode([TeamGoal].self, from: data) {
            goals = decodedGoals
        }
        
        // Load motivations
        if let data = UserDefaults.standard.data(forKey: motivationsKey),
           let decodedMotivations = try? JSONDecoder().decode([TeamMotivation].self, from: data) {
            motivations = decodedMotivations
        }
    }
} 