import Foundation

final class TeamTrainingLogStore: ObservableObject {
    @Published private(set) var logs: [Date: [TeamTrainingLog]] = [:]
    private let calendar = Calendar.current
    private let logsKey = "TeamTrainingLogs"

    init() {
        loadLogs()
    }

    func add(_ log: TeamTrainingLog) {
        let day = calendar.startOfDay(for: log.date)
        logs[day, default: []].append(log)
        saveLogs()
    }

    /// Remove all stored logs. Useful when a new team is created and the
    /// previous team's logs should be cleared.
    func removeAll() {
        logs.removeAll()
        saveLogs()
    }
    
    private func saveLogs() {
        if let data = try? JSONEncoder().encode(logs) {
            UserDefaults.standard.set(data, forKey: logsKey)
        }
    }
    
    private func loadLogs() {
        if let data = UserDefaults.standard.data(forKey: logsKey),
           let decodedLogs = try? JSONDecoder().decode([Date: [TeamTrainingLog]].self, from: data) {
            logs = decodedLogs
        }
    }
}
