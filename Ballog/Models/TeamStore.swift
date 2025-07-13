import Foundation
import CoreData

final class TeamStore: ObservableObject {
    @Published var teams: [Team] = []
    
    private let coreDataStack = CoreDataStack.shared
    
    init() {
        loadTeams()
    }
    
    func addTeam(_ team: Team) {
        teams.append(team)
        saveTeamToCoreData(team)
    }
    
    func updateTeam(_ team: Team) {
        if let index = teams.firstIndex(where: { $0.id == team.id }) {
            teams[index] = team
            updateTeamInCoreData(team)
        }
    }
    
    func removeTeam(_ team: Team) {
        teams.removeAll { $0.id == team.id }
        deleteTeamFromCoreData(team)
    }
    
    func addMember(_ member: TeamCharacter, to teamId: UUID) {
        if let index = teams.firstIndex(where: { $0.id == teamId }) {
            teams[index].members.append(member)
            updateTeamInCoreData(teams[index])
        }
    }
    
    func removeMember(_ member: TeamCharacter, from teamId: UUID) {
        if let index = teams.firstIndex(where: { $0.id == teamId }) {
            teams[index].members.removeAll { $0.id == member.id }
            updateTeamInCoreData(teams[index])
        }
    }
    
    func updateMember(_ member: TeamCharacter, in teamId: UUID) {
        if let teamIndex = teams.firstIndex(where: { $0.id == teamId }),
           let memberIndex = teams[teamIndex].members.firstIndex(where: { $0.id == member.id }) {
            teams[teamIndex].members[memberIndex] = member
            updateTeamInCoreData(teams[teamIndex])
        }
    }
    
    // MARK: - Core Data Methods
    
    private func saveTeamToCoreData(_ team: Team) {
        let context = coreDataStack.container.viewContext
        let entity = TeamEntity(context: context)
        
        entity.id = team.id
        entity.name = team.name
        entity.sport = team.sport
        entity.gender = team.gender
        entity.type = team.type
        entity.region = team.region
        entity.code = team.code
        entity.trainingTime = team.trainingTime
        entity.creatorId = team.creatorId
        entity.creatorName = team.creatorName
        entity.createdAt = team.createdAt
        entity.membersData = try! JSONEncoder().encode(team.members)
        
        coreDataStack.save()
    }
    
    private func updateTeamInCoreData(_ team: Team) {
        let context = coreDataStack.container.viewContext
        let request: NSFetchRequest<TeamEntity> = TeamEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", team.id as CVarArg)
        
        if let entity = try? context.fetch(request).first {
            entity.name = team.name
            entity.sport = team.sport
            entity.gender = team.gender
            entity.type = team.type
            entity.region = team.region
            entity.code = team.code
            entity.trainingTime = team.trainingTime
            entity.creatorId = team.creatorId
            entity.creatorName = team.creatorName
            entity.createdAt = team.createdAt
            entity.membersData = try! JSONEncoder().encode(team.members)
            
            coreDataStack.save()
        }
    }
    
    private func deleteTeamFromCoreData(_ team: Team) {
        let context = coreDataStack.container.viewContext
        let request: NSFetchRequest<TeamEntity> = TeamEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", team.id as CVarArg)
        
        if let entity = try? context.fetch(request).first {
            context.delete(entity)
            coreDataStack.save()
        }
    }
    
    private func loadTeams() {
        let context = coreDataStack.container.viewContext
        let request: NSFetchRequest<TeamEntity> = TeamEntity.fetchRequest()
        
        if let entities = try? context.fetch(request) {
            teams = entities.map { entity in
                Team(
                    id: entity.id,
                    name: entity.name,
                    sport: entity.sport,
                    gender: entity.gender,
                    type: entity.type,
                    region: entity.region,
                    code: entity.code,
                    trainingTime: entity.trainingTime,
                    members: (try? JSONDecoder().decode([TeamCharacter].self, from: entity.membersData)) ?? [],
                    creatorId: entity.creatorId,
                    creatorName: entity.creatorName,
                    createdAt: entity.createdAt
                )
            }
        }
    }
}
