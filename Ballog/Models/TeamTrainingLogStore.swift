import Foundation

final class TeamTrainingLogStore: ObservableObject {
    @Published private(set) var logs: [Date: [TeamTrainingLog]] = [:]
    private let calendar = Calendar.current

    func add(_ log: TeamTrainingLog) {
        let day = calendar.startOfDay(for: log.date)
        logs[day, default: []].append(log)
    }
}
