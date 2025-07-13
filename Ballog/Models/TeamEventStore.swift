import Foundation

final class TeamEventStore: ObservableObject {
    @Published var events: [TeamEvent] = []
    
    private let eventsKey = "TeamEvents"
    
    init() {
        loadEvents()
    }
    
    func addEvent(_ event: TeamEvent) {
        events.append(event)
        saveEvents()
    }
    
    func add(_ event: TeamEvent) {
        events.append(event)
        saveEvents()
    }
    
    func updateEvent(_ event: TeamEvent) {
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            events[index] = event
            saveEvents()
        }
    }
    
    func removeEvent(_ event: TeamEvent) {
        events.removeAll { $0.id == event.id }
        saveEvents()
    }
    
    private func saveEvents() {
        if let data = try? JSONEncoder().encode(events) {
            UserDefaults.standard.set(data, forKey: eventsKey)
        }
    }
    
    private func loadEvents() {
        if let data = UserDefaults.standard.data(forKey: eventsKey),
           let decodedEvents = try? JSONDecoder().decode([TeamEvent].self, from: data) {
            events = decodedEvents
        }
    }
} 