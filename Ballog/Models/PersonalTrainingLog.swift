import Foundation
import CoreData

struct PersonalTrainingLog: Identifiable, Codable {
    enum EventType: String, Codable { case match, training }
    enum MatchResult: String, Codable { case win = "승", loss = "패", draw = "무승부" }
    
    let id: UUID
    var date: Date
    var title: String
    var coachingNotes: String // "훈련 중 코칭 받은 내용"
    var duration: Int // 분 단위
    var categories: [TrainingCategory] // 멀티 선택
    var condition: TrainingCondition // 5단계 이모지
    var achievements: [String] // 오늘 훈련 중 잘한 것들
    var shortcomings: [String] // 부족한 것들
    var nextGoals: [String] // 다음 훈련 목표
    var isTeam: Bool // 팀/개인 구분

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
    
    enum TrainingCondition: String, Codable, CaseIterable {
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
    
    init(id: UUID = UUID(), date: Date = Date(), title: String, coachingNotes: String, duration: Int, categories: [TrainingCategory], condition: TrainingCondition, achievements: [String] = [], shortcomings: [String] = [], nextGoals: [String] = [], isTeam: Bool = false) {
        self.id = id
        self.date = date
        self.title = title
        self.coachingNotes = coachingNotes
        self.duration = duration
        self.categories = categories
        self.condition = condition
        self.achievements = achievements
        self.shortcomings = shortcomings
        self.nextGoals = nextGoals
        self.isTeam = isTeam
    }
}

struct PersonalGoal: Identifiable, Codable, Equatable {
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
    
    private let coreDataStack = CoreDataStack.shared
    private var currentUserId: String = ""
    
    init() {
        loadData()
    }
    
    func setCurrentUser(_ userId: String) {
        currentUserId = userId
        loadData()
    }
    
    func addLog(_ log: PersonalTrainingLog) {
        logs.append(log)
        saveLogToCoreData(log)
    }
    
    func updateLog(_ log: PersonalTrainingLog) {
        if let index = logs.firstIndex(where: { $0.id == log.id }) {
            logs[index] = log
            updateLogInCoreData(log)
        }
    }
    
    func removeLog(_ log: PersonalTrainingLog) {
        logs.removeAll { $0.id == log.id }
        deleteLogFromCoreData(log)
    }
    
    func addGoal(_ goal: PersonalGoal) {
        goals.append(goal)
        saveGoalToCoreData(goal)
    }
    
    func updateGoal(_ goal: PersonalGoal) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index] = goal
            updateGoalInCoreData(goal)
        }
    }
    
    func removeGoal(_ goal: PersonalGoal) {
        goals.removeAll { $0.id == goal.id }
        deleteGoalFromCoreData(goal)
    }
    
    func setAttendance(_ value: Bool, for date: Date) {
        let day = Calendar.current.startOfDay(for: date)
        attendance[day] = value
        saveAttendance()
    }
    
    // MARK: - Core Data Methods
    
    private func saveLogToCoreData(_ log: PersonalTrainingLog) {
        let context = coreDataStack.container.viewContext
        let entity = PersonalTrainingLogEntity(context: context)
        
        entity.id = log.id
        entity.userId = currentUserId
        entity.date = log.date
        entity.title = log.title
        entity.coachingNotes = log.coachingNotes
        entity.duration = Int32(log.duration)
        entity.categories = log.categories.map { $0.rawValue } as NSArray
        entity.condition = log.condition.rawValue
        entity.achievements = log.achievements as NSArray
        entity.shortcomings = log.shortcomings as NSArray
        entity.nextGoals = log.nextGoals as NSArray
        entity.isTeam = log.isTeam
        
        coreDataStack.save()
    }
    
    private func updateLogInCoreData(_ log: PersonalTrainingLog) {
        let context = coreDataStack.container.viewContext
        let request: NSFetchRequest<PersonalTrainingLogEntity> = PersonalTrainingLogEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@ AND userId == %@", log.id as CVarArg, currentUserId)
        
        if let entity = try? context.fetch(request).first {
            entity.date = log.date
            entity.title = log.title
            entity.coachingNotes = log.coachingNotes
            entity.duration = Int32(log.duration)
            entity.categories = log.categories.map { $0.rawValue } as NSArray
            entity.condition = log.condition.rawValue
            entity.achievements = log.achievements as NSArray
            entity.shortcomings = log.shortcomings as NSArray
            entity.nextGoals = log.nextGoals as NSArray
            entity.isTeam = log.isTeam
            
            coreDataStack.save()
        }
    }
    
    private func deleteLogFromCoreData(_ log: PersonalTrainingLog) {
        let context = coreDataStack.container.viewContext
        let request: NSFetchRequest<PersonalTrainingLogEntity> = PersonalTrainingLogEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@ AND userId == %@", log.id as CVarArg, currentUserId)
        
        if let entity = try? context.fetch(request).first {
            context.delete(entity)
            coreDataStack.save()
        }
    }
    
    private func saveGoalToCoreData(_ goal: PersonalGoal) {
        let context = coreDataStack.container.viewContext
        let entity = PersonalGoalEntity(context: context)
        
        entity.id = goal.id
        entity.userId = currentUserId
        entity.title = goal.title
        entity.goalDescription = goal.description
        entity.targetDate = goal.targetDate
        entity.category = goal.category.rawValue
        entity.isCompleted = goal.isCompleted
        entity.progress = Int32(goal.progress)
        entity.createdAt = goal.createdAt
        
        coreDataStack.save()
    }
    
    private func updateGoalInCoreData(_ goal: PersonalGoal) {
        let context = coreDataStack.container.viewContext
        let request: NSFetchRequest<PersonalGoalEntity> = PersonalGoalEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@ AND userId == %@", goal.id as CVarArg, currentUserId)
        
        if let entity = try? context.fetch(request).first {
            entity.title = goal.title
            entity.goalDescription = goal.description
            entity.targetDate = goal.targetDate
            entity.category = goal.category.rawValue
            entity.isCompleted = goal.isCompleted
            entity.progress = Int32(goal.progress)
            
            coreDataStack.save()
        }
    }
    
    private func deleteGoalFromCoreData(_ goal: PersonalGoal) {
        let context = coreDataStack.container.viewContext
        let request: NSFetchRequest<PersonalGoalEntity> = PersonalGoalEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@ AND userId == %@", goal.id as CVarArg, currentUserId)
        
        if let entity = try? context.fetch(request).first {
            context.delete(entity)
            coreDataStack.save()
        }
    }
    
    private func loadData() {
        loadLogsFromCoreData()
        loadGoalsFromCoreData()
        loadAttendance()
    }
    
    private func loadLogsFromCoreData() {
        let context = coreDataStack.container.viewContext
        let request: NSFetchRequest<PersonalTrainingLogEntity> = PersonalTrainingLogEntity.fetchRequest()
        request.predicate = NSPredicate(format: "userId == %@", currentUserId)
        
        if let entities = try? context.fetch(request) {
            logs = entities.compactMap { entity -> PersonalTrainingLog? in
                let categories = (entity.categories as? [String])?.compactMap { PersonalTrainingLog.TrainingCategory(rawValue: $0) } ?? []
                guard let conditionRaw = entity.condition,
                      let condition = PersonalTrainingLog.TrainingCondition(rawValue: conditionRaw) else { return nil }
                return PersonalTrainingLog(
                    id: entity.id ?? UUID(),
                    date: entity.date ?? Date(),
                    title: entity.title ?? "",
                    coachingNotes: entity.coachingNotes ?? "",
                    duration: Int(entity.duration),
                    categories: categories,
                    condition: condition,
                    achievements: entity.achievements as? [String] ?? [],
                    shortcomings: entity.shortcomings as? [String] ?? [],
                    nextGoals: entity.nextGoals as? [String] ?? [],
                    isTeam: entity.isTeam
                )
            }
        }
    }
    
    private func loadGoalsFromCoreData() {
        let context = coreDataStack.container.viewContext
        let request: NSFetchRequest<PersonalGoalEntity> = PersonalGoalEntity.fetchRequest()
        request.predicate = NSPredicate(format: "userId == %@", currentUserId)
        
        if let entities = try? context.fetch(request) {
            goals = entities.compactMap { entity in
                guard let category = PersonalTrainingLog.TrainingCategory(rawValue: entity.category) else {
                    return nil
                }
                
                return PersonalGoal(
                    title: entity.title,
                    description: entity.goalDescription,
                    targetDate: entity.targetDate,
                    category: category,
                    isCompleted: entity.isCompleted,
                    progress: Int(entity.progress)
                )
            }
        }
    }
    
    private func saveAttendance() {
        if let data = try? JSONEncoder().encode(attendance) {
            UserDefaults.standard.set(data, forKey: "PersonalAttendance_\(currentUserId)")
        }
    }
    
    private func loadAttendance() {
        if let data = UserDefaults.standard.data(forKey: "PersonalAttendance_\(currentUserId)"),
           let decodedAttendance = try? JSONDecoder().decode([Date: Bool].self, from: data) {
            attendance = decodedAttendance
        }
    }
} 