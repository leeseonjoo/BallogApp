import Foundation

final class TeamTrainingLogStore: ObservableObject {
    @Published private(set) var logs: [Date: [TeamTrainingLog]] = [:]
    private let calendar = Calendar.current

    func add(_ log: TeamTrainingLog) {
        let day = calendar.startOfDay(for: log.date)
        logs[day, default: []].append(log)
    }

    /// Remove all stored logs. Useful when a new team is created and the
    /// previous team's logs should be cleared.
    func removeAll() {
        logs.removeAll()
    }
}
