import Foundation
import FirebaseFirestoreSwift

struct PersonalTrainingLog: Identifiable, Codable {
    @DocumentID var id: String?
    var date: Date = Date()
    var title: String
    var coachingNotes: String
    var duration: Int
    var categories: [TrainingCategory]
    var condition: TrainingCondition
    var achievements: [String]
    var shortcomings: [String]
    var nextGoals: [String]
    var isTeam: Bool

    enum TrainingCategory: String, Codable, CaseIterable {
        case dribbling = "드리블"
        case passing = "패스"
        case shooting = "슈팅"
        case defense = "수비"
        case fitness = "체력"
        case tactics = "전술"

        var icon: String {
            switch self {
            case .dribbling: return "figure.soccer"
            case .passing: return "arrowshape.turn.up.right"
            case .shooting: return "scope"
            case .defense: return "shield.fill"
            case .fitness: return "heart.fill"
            case .tactics: return "brain.head.profile"
            }
        }
    }

    enum TrainingCondition: String, Codable, CaseIterable {
        case good = "좋음"
        case normal = "보통"
        case bad = "나쁨"

        var emoji: String {
            switch self {
            case .good: return "🙂"
            case .normal: return "😐"
            case .bad: return "☹️"
            }
        }
    }

    init(date: Date = Date(), title: String, coachingNotes: String, duration: Int, categories: [TrainingCategory], condition: TrainingCondition, achievements: [String] = [], shortcomings: [String] = [], nextGoals: [String] = [], isTeam: Bool) {
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

final class PersonalTrainingStore: ObservableObject {
    @Published var logs: [PersonalTrainingLog] = []
    @Published var attendance: [Date: Bool] = [:]

    private let logsKey = "PersonalTrainingLogs"
    private let attendanceKey = "PersonalTrainingAttendance"

    init() {
        loadLogs()
        loadAttendance()
    }

    func addLog(_ log: PersonalTrainingLog) {
        logs.append(log)
        saveLogs()
    }

    func updateLog(_ log: PersonalTrainingLog) {
        if let id = log.id, let index = logs.firstIndex(where: { $0.id == id }) {
            logs[index] = log
        } else if let index = logs.firstIndex(where: { $0.id == nil && $0.date == log.date && $0.title == log.title }) {
            logs[index] = log
        }
        saveLogs()
    }

    func deleteLog(_ log: PersonalTrainingLog) {
        if let id = log.id {
            logs.removeAll { $0.id == id }
        }
        saveLogs()
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

    private func loadLogs() {
        if let data = UserDefaults.standard.data(forKey: logsKey),
           let decoded = try? JSONDecoder().decode([PersonalTrainingLog].self, from: data) {
            logs = decoded
        }
    }

    private func saveAttendance() {
        if let data = try? JSONEncoder().encode(attendance) {
            UserDefaults.standard.set(data, forKey: attendanceKey)
        }
    }

    private func loadAttendance() {
        if let data = UserDefaults.standard.data(forKey: attendanceKey),
           let decoded = try? JSONDecoder().decode([Date: Bool].self, from: data) {
            attendance = decoded
        }
    }
}
