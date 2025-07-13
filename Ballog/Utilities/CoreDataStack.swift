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

        let entity = NSEntityDescription()
        entity.name = "AccountEntity"
        entity.managedObjectClassName = String(describing: AccountEntity.self)

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

        entity.properties = [username, password, email, isAdmin]
        model.entities = [entity]

        return model
    }

    func save() {
        let context = container.viewContext
        if context.hasChanges {
            try? context.save()
        }
    }
}
