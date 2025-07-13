import Foundation

struct TeamEvent: Identifiable, Codable {
    enum EventType: String, Codable { case match, training }
    enum MatchResult: String, Codable { case win = "승", loss = "패", draw = "무승부" }
    
    let id = UUID()
    var date: Date
    var title: String
    var place: String
    var type: EventType
    
    // Match specific properties
    var opponent: String?
    var matchType: String?
    var ourScore: Int?
    var opponentScore: Int?
    var result: MatchResult?
    var notes: String?
    
    init(title: String, date: Date, place: String, type: EventType, opponent: String? = nil, matchType: String? = nil) {
        self.title = title
        self.date = date
        self.place = place
        self.type = type
        self.opponent = opponent
        self.matchType = matchType
    }
}

final class TeamEventStore: ObservableObject {
    @Published var events: [TeamEvent] = []

    func addEvent(_ event: TeamEvent) {
        events.append(event)
    }
    
    func add(_ event: TeamEvent) {
        events.append(event)
    }
    
    func updateEvent(_ event: TeamEvent) {
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            events[index] = event
        }
    }
    
    func removeEvent(_ event: TeamEvent) {
        events.removeAll { $0.id == event.id }
    }
}
