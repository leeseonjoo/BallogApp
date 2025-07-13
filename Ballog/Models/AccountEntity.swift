import Foundation
import CoreData

@objc(AccountEntity)
public class AccountEntity: NSManagedObject {
    @NSManaged public var username: String
    @NSManaged public var password: String
    @NSManaged public var email: String
    @NSManaged public var isAdmin: Bool
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<AccountEntity> {
        return NSFetchRequest<AccountEntity>(entityName: "AccountEntity")
    }
}

extension AccountEntity: Identifiable {}

@objc(TeamEntity)
public class TeamEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var sport: String
    @NSManaged public var gender: String
    @NSManaged public var type: String
    @NSManaged public var region: String
    @NSManaged public var code: String
    @NSManaged public var trainingTime: String
    @NSManaged public var creatorId: String
    @NSManaged public var creatorName: String
    @NSManaged public var createdAt: Date
    @NSManaged public var membersData: Data
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TeamEntity> {
        return NSFetchRequest<TeamEntity>(entityName: "TeamEntity")
    }
}

@objc(TeamEventEntity)
public class TeamEventEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var title: String
    @NSManaged public var place: String
    @NSManaged public var type: String
    @NSManaged public var opponent: String?
    @NSManaged public var matchType: String?
    @NSManaged public var ourScore: Int32
    @NSManaged public var opponentScore: Int32
    @NSManaged public var result: String?
    @NSManaged public var notes: String?
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TeamEventEntity> {
        return NSFetchRequest<TeamEventEntity>(entityName: "TeamEventEntity")
    }
}

@objc(PersonalTrainingLogEntity)
public class PersonalTrainingLogEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var userId: String
    @NSManaged public var date: Date
    @NSManaged public var title: String
    @NSManaged public var content: String
    @NSManaged public var duration: Int32
    @NSManaged public var category: String
    @NSManaged public var mood: String
    @NSManaged public var goals: [String]
    @NSManaged public var achievements: [String]
    @NSManaged public var nextGoals: [String]
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PersonalTrainingLogEntity> {
        return NSFetchRequest<PersonalTrainingLogEntity>(entityName: "PersonalTrainingLogEntity")
    }
}

@objc(PersonalGoalEntity)
public class PersonalGoalEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var userId: String
    @NSManaged public var title: String
    @NSManaged public var goalDescription: String
    @NSManaged public var targetDate: Date
    @NSManaged public var category: String
    @NSManaged public var isCompleted: Bool
    @NSManaged public var progress: Int32
    @NSManaged public var createdAt: Date
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PersonalGoalEntity> {
        return NSFetchRequest<PersonalGoalEntity>(entityName: "PersonalGoalEntity")
    }
}

@objc(TeamGoalEntity)
public class TeamGoalEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var goalDescription: String
    @NSManaged public var targetDate: Date
    @NSManaged public var category: String
    @NSManaged public var isCompleted: Bool
    @NSManaged public var progress: Int32
    @NSManaged public var createdAt: Date
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TeamGoalEntity> {
        return NSFetchRequest<TeamGoalEntity>(entityName: "TeamGoalEntity")
    }
}

@objc(TeamTrainingLogEntity)
public class TeamTrainingLogEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var title: String
    @NSManaged public var content: String
    @NSManaged public var duration: Int32
    @NSManaged public var category: String
    @NSManaged public var mood: String
    @NSManaged public var goals: [String]
    @NSManaged public var achievements: [String]
    @NSManaged public var nextGoals: [String]
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TeamTrainingLogEntity> {
        return NSFetchRequest<TeamTrainingLogEntity>(entityName: "TeamTrainingLogEntity")
    }
}
