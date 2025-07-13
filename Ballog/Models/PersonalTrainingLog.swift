import Foundation

struct PersonalTrainingLog: Identifiable, Codable {
    let id = UUID()
    let date: Date
    let title: String
    let content: String
    let duration: Int // 분 단위
    let category: TrainingCategory
    let mood: TrainingMood
    let goals: [String]
    let achievements: [String]
    let nextGoals: [String]
    
    enum TrainingCategory: String, Codable, CaseIterable {
        case dribbling = "드리블"
        case shooting = "슈팅"
        case passing = "패스"
        case defense = "수비"
        case fitness = "체력"
        case tactics = "전술"
        case match = "경기"
        case other = "기타"
        
        var icon: String {
            switch self {
            case .dribbling: return "figure.run"
            case .shooting: return "target"
            case .passing: return "arrow.left.and.right"
            case .defense: return "shield"
            case .fitness: return "heart.fill"
            case .tactics: return "brain.head.profile"
            case .match: return "sportscourt"
            case .other: return "ellipsis.circle"
            }
        }
    }
    
    enum TrainingMood: String, Codable, CaseIterable {
        case excellent = "매우 좋음"
        case good = "좋음"
        case normal = "보통"
        case bad = "나쁨"
        case terrible = "매우 나쁨"
        
        var emoji: String {
            switch self {
            case .excellent: return "😄"
            case .good: return "🙂"
            case .normal: return "😐"
            case .bad: return "😔"
            case .terrible: return "😢"
            }
        }
    }
    
    init(date: Date = Date(), title: String, content: String, duration: Int, category: TrainingCategory, mood: TrainingMood, goals: [String] = [], achievements: [String] = [], nextGoals: [String] = []) {
        self.date = date
        self.title = title
        self.content = content
        self.duration = duration
        self.category = category
        self.mood = mood
        self.goals = goals
        self.achievements = achievements
        self.nextGoals = nextGoals
    }
}

struct PersonalGoal: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String
    let targetDate: Date
    let category: PersonalTrainingLog.TrainingCategory
    let isCompleted: Bool
    let progress: Int // 0-100
    let createdAt: Date
    
    init(title: String, description: String, targetDate: Date, category: PersonalTrainingLog.TrainingCategory, isCompleted: Bool = false, progress: Int = 0) {
        self.title = title
        self.description = description
        self.targetDate = targetDate
        self.category = category
        self.isCompleted = isCompleted
        self.progress = progress
        self.createdAt = Date()
    }
}

final class PersonalTrainingStore: ObservableObject {
    @Published var logs: [PersonalTrainingLog] = []
    @Published var goals: [PersonalGoal] = []
    @Published var attendance: [Date: Bool] = [:]
    
    private let logsKey = "PersonalTrainingLogs"
    private let goalsKey = "PersonalGoals"
    private let attendanceKey = "PersonalAttendance"
    
    init() {
        loadData()
    }
    
    func addLog(_ log: PersonalTrainingLog) {
        logs.append(log)
        saveLogs()
    }
    
    func updateLog(_ log: PersonalTrainingLog) {
        if let index = logs.firstIndex(where: { $0.id == log.id }) {
            logs[index] = log
            saveLogs()
        }
    }
    
    func removeLog(_ log: PersonalTrainingLog) {
        logs.removeAll { $0.id == log.id }
        saveLogs()
    }
    
    func addGoal(_ goal: PersonalGoal) {
        goals.append(goal)
        saveGoals()
    }
    
    func updateGoal(_ goal: PersonalGoal) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index] = goal
            saveGoals()
        }
    }
    
    func removeGoal(_ goal: PersonalGoal) {
        goals.removeAll { $0.id == goal.id }
        saveGoals()
    }
    
    func setAttendance(_ value: Bool, for date: Date) {
        let day = Calendar.current.startOfDay(for: date)
        attendance[day] = value
        saveAttendance()
    }
    
    private func saveLogs() {
        if let data = try? JSONEncoder().encode(logs) {
            UserDefaults.standard.set(data, forKey: logsKey)
        }
    }
    
    private func saveGoals() {
        if let data = try? JSONEncoder().encode(goals) {
            UserDefaults.standard.set(data, forKey: goalsKey)
        }
    }
    
    private func saveAttendance() {
        if let data = try? JSONEncoder().encode(attendance) {
            UserDefaults.standard.set(data, forKey: attendanceKey)
        }
    }
    
    private func loadData() {
        // Load logs
        if let data = UserDefaults.standard.data(forKey: logsKey),
           let decodedLogs = try? JSONDecoder().decode([PersonalTrainingLog].self, from: data) {
            logs = decodedLogs
        }
        
        // Load goals
        if let data = UserDefaults.standard.data(forKey: goalsKey),
           let decodedGoals = try? JSONDecoder().decode([PersonalGoal].self, from: data) {
            goals = decodedGoals
        }
        
        // Load attendance
        if let data = UserDefaults.standard.data(forKey: attendanceKey),
           let decodedAttendance = try? JSONDecoder().decode([Date: Bool].self, from: data) {
            attendance = decodedAttendance
        }
    }
} 