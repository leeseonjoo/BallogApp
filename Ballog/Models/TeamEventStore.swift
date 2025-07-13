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
    
    // 반복 일정 생성
    func createRecurringEvents(_ event: TeamEvent) {
        guard event.isRecurring, let weekday = event.recurringWeekday, let endDate = event.endDate else { return }
        
        let calendar = Calendar.current
        var currentDate = event.date
        
        while currentDate <= endDate {
            if calendar.component(.weekday, from: currentDate) == weekday {
                let recurringEvent = TeamEvent(
                    title: event.title,
                    date: currentDate,
                    place: event.place,
                    type: event.type,
                    opponent: event.opponent,
                    matchType: event.matchType
                )
                addEvent(recurringEvent)
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
    }
    
    // 특정 날짜의 이벤트들 가져오기
    func eventsForDate(_ date: Date) -> [TeamEvent] {
        let calendar = Calendar.current
        return events.filter { event in
            calendar.isDate(event.date, inSameDayAs: date)
        }
    }
    
    // 매치와 대회만 필터링
    func matchAndTournamentEvents() -> [TeamEvent] {
        return events.filter { $0.type == .match || $0.type == .tournament }
    }
    
    // 이번 주 이벤트들 가져오기
    func thisWeekEvents() -> [TeamEvent] {
        let calendar = Calendar.current
        let now = Date()
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        let weekEnd = calendar.dateInterval(of: .weekOfYear, for: now)?.end ?? now
        
        return events.filter { event in
            event.date >= weekStart && event.date < weekEnd
        }
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
        entity.trainingType = event.trainingType?.rawValue
        entity.isRecurring = event.isRecurring
        entity.recurringWeekday = Int32(event.recurringWeekday ?? 0)
        entity.endDate = event.endDate
        entity.opponent = event.opponent
        entity.matchType = event.matchType
        entity.ourScore = Int32(event.ourScore ?? 0)
        entity.opponentScore = Int32(event.opponentScore ?? 0)
        entity.result = event.result?.rawValue
        entity.notes = event.notes
        entity.tournamentName = event.tournamentName
        entity.tournamentRound = event.tournamentRound
        
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
            entity.trainingType = event.trainingType?.rawValue
            entity.isRecurring = event.isRecurring
            entity.recurringWeekday = Int32(event.recurringWeekday ?? 0)
            entity.endDate = event.endDate
            entity.opponent = event.opponent
            entity.matchType = event.matchType
            entity.ourScore = Int32(event.ourScore ?? 0)
            entity.opponentScore = Int32(event.opponentScore ?? 0)
            entity.result = event.result?.rawValue
            entity.notes = event.notes
            entity.tournamentName = event.tournamentName
            entity.tournamentRound = event.tournamentRound
            
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
                    // 기본 훈련 이벤트로 생성
                    var event = TeamEvent(
                        title: entity.title,
                        date: entity.date,
                        place: entity.place,
                        type: .training,
                        opponent: entity.opponent,
                        matchType: entity.matchType
                    )
                    event.notes = entity.notes
                    return event
                }
                
                var result: TeamEvent.MatchResult?
                if let resultString = entity.result {
                    result = TeamEvent.MatchResult(rawValue: resultString)
                }
                
                var trainingType: TeamEvent.TrainingType?
                if let trainingTypeString = entity.trainingType {
                    trainingType = TeamEvent.TrainingType(rawValue: trainingTypeString)
                }
                
                var event = TeamEvent(
                    title: entity.title,
                    date: entity.date,
                    place: entity.place,
                    type: type,
                    opponent: entity.opponent,
                    matchType: entity.matchType
                )
                
                // 추가 필드들 설정
                event.trainingType = trainingType
                event.isRecurring = entity.isRecurring
                event.recurringWeekday = Int(entity.recurringWeekday)
                event.endDate = entity.endDate
                event.ourScore = Int(entity.ourScore)
                event.opponentScore = Int(entity.opponentScore)
                event.result = result
                event.notes = entity.notes
                event.tournamentName = entity.tournamentName
                event.tournamentRound = entity.tournamentRound
                
                return event
            }
        }
    }
} 