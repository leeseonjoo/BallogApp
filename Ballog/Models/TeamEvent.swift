import Foundation

struct TeamEvent: Identifiable, Codable {
    enum EventType: String, Codable { case match, training }
    let id = UUID()
    var date: Date
    var title: String
    var place: String
    var type: EventType
}

final class TeamEventStore: ObservableObject {
    @Published var events: [TeamEvent] = []

    func add(_ event: TeamEvent) {
        events.append(event)
    }
}
