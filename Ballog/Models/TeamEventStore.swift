import Foundation
import CoreData

final class TeamEventStore: ObservableObject {
    @Published var events: [TeamEvent] = []
    
    private let coreDataStack = CoreDataStack.shared
    
    init() {
        loadEvents()
    }
    
    func addEvent(_ event: TeamEvent) {
        events.append(event)
        saveEventToCoreData(event)
    }
    
    func add(_ event: TeamEvent) {
        events.append(event)
        saveEventToCoreData(event)
    }
    
    func updateEvent(_ event: TeamEvent) {
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            events[index] = event
            updateEventInCoreData(event)
        }
    }
    
    func removeEvent(_ event: TeamEvent) {
        events.removeAll { $0.id == event.id }
        deleteEventFromCoreData(event)
    }
    
    // MARK: - Core Data Methods
    
    private func saveEventToCoreData(_ event: TeamEvent) {
        let context = coreDataStack.container.viewContext
        let entity = TeamEventEntity(context: context)
        
        entity.id = event.id
        entity.date = event.date
        entity.title = event.title
        entity.place = event.place
        entity.type = event.type.rawValue
        entity.opponent = event.opponent
        entity.matchType = event.matchType
        entity.ourScore = Int32(event.ourScore ?? 0)
        entity.opponentScore = Int32(event.opponentScore ?? 0)
        entity.result = event.result?.rawValue
        entity.notes = event.notes
        
        coreDataStack.save()
    }
    
    private func updateEventInCoreData(_ event: TeamEvent) {
        let context = coreDataStack.container.viewContext
        let request: NSFetchRequest<TeamEventEntity> = TeamEventEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", event.id as CVarArg)
        
        if let entity = try? context.fetch(request).first {
            entity.date = event.date
            entity.title = event.title
            entity.place = event.place
            entity.type = event.type.rawValue
            entity.opponent = event.opponent
            entity.matchType = event.matchType
            entity.ourScore = Int32(event.ourScore ?? 0)
            entity.opponentScore = Int32(event.opponentScore ?? 0)
            entity.result = event.result?.rawValue
            entity.notes = event.notes
            
            coreDataStack.save()
        }
    }
    
    private func deleteEventFromCoreData(_ event: TeamEvent) {
        let context = coreDataStack.container.viewContext
        let request: NSFetchRequest<TeamEventEntity> = TeamEventEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", event.id as CVarArg)
        
        if let entity = try? context.fetch(request).first {
            context.delete(entity)
            coreDataStack.save()
        }
    }
    
    private func loadEvents() {
        let context = coreDataStack.container.viewContext
        let request: NSFetchRequest<TeamEventEntity> = TeamEventEntity.fetchRequest()
        
        if let entities = try? context.fetch(request) {
            events = entities.compactMap { entity in
                guard let type = TeamEvent.EventType(rawValue: entity.type) else {
                    return nil
                }
                
                var result: TeamEvent.MatchResult?
                if let resultString = entity.result {
                    result = TeamEvent.MatchResult(rawValue: resultString)
                }
                
                return TeamEvent(
                    title: entity.title,
                    date: entity.date,
                    place: entity.place,
                    type: type,
                    opponent: entity.opponent,
                    matchType: entity.matchType
                )
            }
        }
    }
} 