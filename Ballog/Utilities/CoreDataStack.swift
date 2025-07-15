import Foundation
import CoreData

final class CoreDataStack {
    static let shared = CoreDataStack()

    let container: NSPersistentContainer

    private init(inMemory: Bool = false) {
        let model = Self.makeModel()
        container = NSPersistentContainer(name: "BallogModel", managedObjectModel: model)

        if inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
        }

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        }
    }

    static func makeModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        // Account Entity
        let accountEntity = NSEntityDescription()
        accountEntity.name = "AccountEntity"
        accountEntity.managedObjectClassName = String(describing: AccountEntity.self)

        let username = NSAttributeDescription()
        username.name = "username"
        username.attributeType = .stringAttributeType
        username.isOptional = false

        let password = NSAttributeDescription()
        password.name = "password"
        password.attributeType = .stringAttributeType
        password.isOptional = false

        let email = NSAttributeDescription()
        email.name = "email"
        email.attributeType = .stringAttributeType
        email.isOptional = false

        let isAdmin = NSAttributeDescription()
        isAdmin.name = "isAdmin"
        isAdmin.attributeType = .booleanAttributeType
        isAdmin.isOptional = false
        isAdmin.defaultValue = false

        accountEntity.properties = [username, password, email, isAdmin]

        // Team Entity
        let teamEntity = NSEntityDescription()
        teamEntity.name = "TeamEntity"
        teamEntity.managedObjectClassName = String(describing: TeamEntity.self)

        let teamId = NSAttributeDescription()
        teamId.name = "id"
        teamId.attributeType = .UUIDAttributeType
        teamId.isOptional = false

        let teamName = NSAttributeDescription()
        teamName.name = "name"
        teamName.attributeType = .stringAttributeType
        teamName.isOptional = false

        let teamSport = NSAttributeDescription()
        teamSport.name = "sport"
        teamSport.attributeType = .stringAttributeType
        teamSport.isOptional = false

        let teamGender = NSAttributeDescription()
        teamGender.name = "gender"
        teamGender.attributeType = .stringAttributeType
        teamGender.isOptional = false

        let teamType = NSAttributeDescription()
        teamType.name = "type"
        teamType.attributeType = .stringAttributeType
        teamType.isOptional = false

        let teamRegion = NSAttributeDescription()
        teamRegion.name = "region"
        teamRegion.attributeType = .stringAttributeType
        teamRegion.isOptional = false

        let teamCode = NSAttributeDescription()
        teamCode.name = "code"
        teamCode.attributeType = .stringAttributeType
        teamCode.isOptional = false

        let teamTrainingTime = NSAttributeDescription()
        teamTrainingTime.name = "trainingTime"
        teamTrainingTime.attributeType = .stringAttributeType
        teamTrainingTime.isOptional = false

        let teamCreatorId = NSAttributeDescription()
        teamCreatorId.name = "creatorId"
        teamCreatorId.attributeType = .stringAttributeType
        teamCreatorId.isOptional = false

        let teamCreatorName = NSAttributeDescription()
        teamCreatorName.name = "creatorName"
        teamCreatorName.attributeType = .stringAttributeType
        teamCreatorName.isOptional = false

        let teamCreatedAt = NSAttributeDescription()
        teamCreatedAt.name = "createdAt"
        teamCreatedAt.attributeType = .dateAttributeType
        teamCreatedAt.isOptional = false

        let teamMembers = NSAttributeDescription()
        teamMembers.name = "membersData"
        teamMembers.attributeType = .binaryDataAttributeType
        teamMembers.isOptional = false

        teamEntity.properties = [teamId, teamName, teamSport, teamGender, teamType, teamRegion, teamCode, teamTrainingTime, teamCreatorId, teamCreatorName, teamCreatedAt, teamMembers]

        // TeamEvent Entity
        let teamEventEntity = NSEntityDescription()
        teamEventEntity.name = "TeamEventEntity"
        teamEventEntity.managedObjectClassName = String(describing: TeamEventEntity.self)

        let eventId = NSAttributeDescription()
        eventId.name = "id"
        eventId.attributeType = .UUIDAttributeType
        eventId.isOptional = false

        let eventDate = NSAttributeDescription()
        eventDate.name = "date"
        eventDate.attributeType = .dateAttributeType
        eventDate.isOptional = false

        let eventTitle = NSAttributeDescription()
        eventTitle.name = "title"
        eventTitle.attributeType = .stringAttributeType
        eventTitle.isOptional = false

        let eventPlace = NSAttributeDescription()
        eventPlace.name = "place"
        eventPlace.attributeType = .stringAttributeType
        eventPlace.isOptional = false

        let eventType = NSAttributeDescription()
        eventType.name = "type"
        eventType.attributeType = .stringAttributeType
        eventType.isOptional = false

        let eventOpponent = NSAttributeDescription()
        eventOpponent.name = "opponent"
        eventOpponent.attributeType = .stringAttributeType
        eventOpponent.isOptional = true

        let eventMatchType = NSAttributeDescription()
        eventMatchType.name = "matchType"
        eventMatchType.attributeType = .stringAttributeType
        eventMatchType.isOptional = true

        let eventOurScore = NSAttributeDescription()
        eventOurScore.name = "ourScore"
        eventOurScore.attributeType = .integer32AttributeType
        eventOurScore.isOptional = false

        let eventOpponentScore = NSAttributeDescription()
        eventOpponentScore.name = "opponentScore"
        eventOpponentScore.attributeType = .integer32AttributeType
        eventOpponentScore.isOptional = false

        let eventResult = NSAttributeDescription()
        eventResult.name = "result"
        eventResult.attributeType = .stringAttributeType
        eventResult.isOptional = true

        let eventNotes = NSAttributeDescription()
        eventNotes.name = "notes"
        eventNotes.attributeType = .stringAttributeType
        eventNotes.isOptional = true

        // 새로운 필드들 추가
        let eventTrainingType = NSAttributeDescription()
        eventTrainingType.name = "trainingType"
        eventTrainingType.attributeType = .stringAttributeType
        eventTrainingType.isOptional = true

        let eventIsRecurring = NSAttributeDescription()
        eventIsRecurring.name = "isRecurring"
        eventIsRecurring.attributeType = .booleanAttributeType
        eventIsRecurring.isOptional = false
        eventIsRecurring.defaultValue = false

        let eventRecurringWeekday = NSAttributeDescription()
        eventRecurringWeekday.name = "recurringWeekday"
        eventRecurringWeekday.attributeType = .integer32AttributeType
        eventRecurringWeekday.isOptional = true

        let eventEndDate = NSAttributeDescription()
        eventEndDate.name = "endDate"
        eventEndDate.attributeType = .dateAttributeType
        eventEndDate.isOptional = true

        let eventTournamentName = NSAttributeDescription()
        eventTournamentName.name = "tournamentName"
        eventTournamentName.attributeType = .stringAttributeType
        eventTournamentName.isOptional = true

        let eventTournamentRound = NSAttributeDescription()
        eventTournamentRound.name = "tournamentRound"
        eventTournamentRound.attributeType = .stringAttributeType
        eventTournamentRound.isOptional = true

        teamEventEntity.properties = [eventId, eventDate, eventTitle, eventPlace, eventType, eventTrainingType, eventIsRecurring, eventRecurringWeekday, eventEndDate, eventOpponent, eventMatchType, eventOurScore, eventOpponentScore, eventResult, eventNotes, eventTournamentName, eventTournamentRound]

        // PersonalTrainingLog Entity
        let personalTrainingLogEntity = NSEntityDescription()
        personalTrainingLogEntity.name = "PersonalTrainingLogEntity"
        personalTrainingLogEntity.managedObjectClassName = String(describing: PersonalTrainingLogEntity.self)

        let logId = NSAttributeDescription()
        logId.name = "id"
        logId.attributeType = .UUIDAttributeType
        logId.isOptional = false

        let logUserId = NSAttributeDescription()
        logUserId.name = "userId"
        logUserId.attributeType = .stringAttributeType
        logUserId.isOptional = false

        let logDate = NSAttributeDescription()
        logDate.name = "date"
        logDate.attributeType = .dateAttributeType
        logDate.isOptional = false

        let logTitle = NSAttributeDescription()
        logTitle.name = "title"
        logTitle.attributeType = .stringAttributeType
        logTitle.isOptional = false

        let logCoachingNotes = NSAttributeDescription()
        logCoachingNotes.name = "coachingNotes"
        logCoachingNotes.attributeType = .stringAttributeType
        logCoachingNotes.isOptional = false

        let logDuration = NSAttributeDescription()
        logDuration.name = "duration"
        logDuration.attributeType = .integer32AttributeType
        logDuration.isOptional = false

        let logCategories = NSAttributeDescription()
        logCategories.name = "categories"
        logCategories.attributeType = .transformableAttributeType
        logCategories.valueTransformerName = "NSSecureUnarchiveFromData"
        logCategories.isOptional = false

        let logCondition = NSAttributeDescription()
        logCondition.name = "condition"
        logCondition.attributeType = .stringAttributeType
        logCondition.isOptional = false

        let logAchievements = NSAttributeDescription()
        logAchievements.name = "achievements"
        logAchievements.attributeType = .transformableAttributeType
        logAchievements.valueTransformerName = "NSSecureUnarchiveFromData"
        logAchievements.isOptional = false

        let logShortcomings = NSAttributeDescription()
        logShortcomings.name = "shortcomings"
        logShortcomings.attributeType = .transformableAttributeType
        logShortcomings.valueTransformerName = "NSSecureUnarchiveFromData"
        logShortcomings.isOptional = false

        let logNextGoals = NSAttributeDescription()
        logNextGoals.name = "nextGoals"
        logNextGoals.attributeType = .transformableAttributeType
        logNextGoals.valueTransformerName = "NSSecureUnarchiveFromData"
        logNextGoals.isOptional = false

        let logIsTeam = NSAttributeDescription()
        logIsTeam.name = "isTeam"
        logIsTeam.attributeType = .booleanAttributeType
        logIsTeam.isOptional = false
        logIsTeam.defaultValue = false

        personalTrainingLogEntity.properties = [
            logId, logUserId, logDate, logTitle,
            logCoachingNotes, logDuration, logCategories,
            logCondition, logAchievements, logShortcomings,
            logNextGoals, logIsTeam
        ]

        // PersonalGoal Entity
        let personalGoalEntity = NSEntityDescription()
        personalGoalEntity.name = "PersonalGoalEntity"
        personalGoalEntity.managedObjectClassName = String(describing: PersonalGoalEntity.self)

        let goalId = NSAttributeDescription()
        goalId.name = "id"
        goalId.attributeType = .UUIDAttributeType
        goalId.isOptional = false

        let goalUserId = NSAttributeDescription()
        goalUserId.name = "userId"
        goalUserId.attributeType = .stringAttributeType
        goalUserId.isOptional = false

        let goalTitle = NSAttributeDescription()
        goalTitle.name = "title"
        goalTitle.attributeType = .stringAttributeType
        goalTitle.isOptional = false

        let goalDescription = NSAttributeDescription()
        goalDescription.name = "goalDescription"
        goalDescription.attributeType = .stringAttributeType
        goalDescription.isOptional = false

        let goalTargetDate = NSAttributeDescription()
        goalTargetDate.name = "targetDate"
        goalTargetDate.attributeType = .dateAttributeType
        goalTargetDate.isOptional = false

        let goalCategory = NSAttributeDescription()
        goalCategory.name = "category"
        goalCategory.attributeType = .stringAttributeType
        goalCategory.isOptional = false

        let goalIsCompleted = NSAttributeDescription()
        goalIsCompleted.name = "isCompleted"
        goalIsCompleted.attributeType = .booleanAttributeType
        goalIsCompleted.isOptional = false

        let goalProgress = NSAttributeDescription()
        goalProgress.name = "progress"
        goalProgress.attributeType = .integer32AttributeType
        goalProgress.isOptional = false

        let goalCreatedAt = NSAttributeDescription()
        goalCreatedAt.name = "createdAt"
        goalCreatedAt.attributeType = .dateAttributeType
        goalCreatedAt.isOptional = false

        personalGoalEntity.properties = [goalId, goalUserId, goalTitle, goalDescription, goalTargetDate, goalCategory, goalIsCompleted, goalProgress, goalCreatedAt]

        // TeamGoal Entity
        let teamGoalEntity = NSEntityDescription()
        teamGoalEntity.name = "TeamGoalEntity"
        teamGoalEntity.managedObjectClassName = String(describing: TeamGoalEntity.self)

        let teamGoalId = NSAttributeDescription()
        teamGoalId.name = "id"
        teamGoalId.attributeType = .UUIDAttributeType
        teamGoalId.isOptional = false

        let teamGoalTitle = NSAttributeDescription()
        teamGoalTitle.name = "title"
        teamGoalTitle.attributeType = .stringAttributeType
        teamGoalTitle.isOptional = false

        let teamGoalDescription = NSAttributeDescription()
        teamGoalDescription.name = "goalDescription"
        teamGoalDescription.attributeType = .stringAttributeType
        teamGoalDescription.isOptional = false

        let teamGoalTargetDate = NSAttributeDescription()
        teamGoalTargetDate.name = "targetDate"
        teamGoalTargetDate.attributeType = .dateAttributeType
        teamGoalTargetDate.isOptional = false

        let teamGoalCategory = NSAttributeDescription()
        teamGoalCategory.name = "category"
        teamGoalCategory.attributeType = .stringAttributeType
        teamGoalCategory.isOptional = false

        let teamGoalIsCompleted = NSAttributeDescription()
        teamGoalIsCompleted.name = "isCompleted"
        teamGoalIsCompleted.attributeType = .booleanAttributeType
        teamGoalIsCompleted.isOptional = false

        let teamGoalProgress = NSAttributeDescription()
        teamGoalProgress.name = "progress"
        teamGoalProgress.attributeType = .integer32AttributeType
        teamGoalProgress.isOptional = false

        let teamGoalCreatedAt = NSAttributeDescription()
        teamGoalCreatedAt.name = "createdAt"
        teamGoalCreatedAt.attributeType = .dateAttributeType
        teamGoalCreatedAt.isOptional = false

        teamGoalEntity.properties = [teamGoalId, teamGoalTitle, teamGoalDescription, teamGoalTargetDate, teamGoalCategory, teamGoalIsCompleted, teamGoalProgress, teamGoalCreatedAt]

        // TeamTrainingLog Entity
        let teamTrainingLogEntity = NSEntityDescription()
        teamTrainingLogEntity.name = "TeamTrainingLogEntity"
        teamTrainingLogEntity.managedObjectClassName = String(describing: TeamTrainingLogEntity.self)

        let teamLogId = NSAttributeDescription()
        teamLogId.name = "id"
        teamLogId.attributeType = .UUIDAttributeType
        teamLogId.isOptional = false

        let teamLogDate = NSAttributeDescription()
        teamLogDate.name = "date"
        teamLogDate.attributeType = .dateAttributeType
        teamLogDate.isOptional = false

        let teamLogTitle = NSAttributeDescription()
        teamLogTitle.name = "title"
        teamLogTitle.attributeType = .stringAttributeType
        teamLogTitle.isOptional = false

        let teamLogContent = NSAttributeDescription()
        teamLogContent.name = "content"
        teamLogContent.attributeType = .stringAttributeType
        teamLogContent.isOptional = false

        let teamLogDuration = NSAttributeDescription()
        teamLogDuration.name = "duration"
        teamLogDuration.attributeType = .integer32AttributeType
        teamLogDuration.isOptional = false

        let teamLogCategory = NSAttributeDescription()
        teamLogCategory.name = "category"
        teamLogCategory.attributeType = .stringAttributeType
        teamLogCategory.isOptional = false

        let teamLogMood = NSAttributeDescription()
        teamLogMood.name = "mood"
        teamLogMood.attributeType = .stringAttributeType
        teamLogMood.isOptional = false

        let teamLogGoals = NSAttributeDescription()
        teamLogGoals.name = "goals"
        teamLogGoals.attributeType = .transformableAttributeType
        teamLogGoals.valueTransformerName = "NSSecureUnarchiveFromData"
        teamLogGoals.isOptional = false

        let teamLogAchievements = NSAttributeDescription()
        teamLogAchievements.name = "achievements"
        teamLogAchievements.attributeType = .transformableAttributeType
        teamLogAchievements.valueTransformerName = "NSSecureUnarchiveFromData"
        teamLogAchievements.isOptional = false

        let teamLogNextGoals = NSAttributeDescription()
        teamLogNextGoals.name = "nextGoals"
        teamLogNextGoals.attributeType = .transformableAttributeType
        teamLogNextGoals.valueTransformerName = "NSSecureUnarchiveFromData"
        teamLogNextGoals.isOptional = false

        teamTrainingLogEntity.properties = [teamLogId, teamLogDate, teamLogTitle, teamLogContent, teamLogDuration, teamLogCategory, teamLogMood, teamLogGoals, teamLogAchievements, teamLogNextGoals]

        model.entities = [accountEntity, teamEntity, teamEventEntity, personalTrainingLogEntity, personalGoalEntity, teamGoalEntity, teamTrainingLogEntity]

        return model
    }

    func save() {
        let context = container.viewContext
        if context.hasChanges {
            try? context.save()
        }
    }
}
