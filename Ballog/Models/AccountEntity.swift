import Foundation
import CoreData

@objc(AccountEntity)
final class AccountEntity: NSManagedObject {
    @NSManaged var username: String
    @NSManaged var password: String
    @NSManaged var email: String
}

extension AccountEntity {
    @nonobjc class func fetchRequest() -> NSFetchRequest<AccountEntity> {
        NSFetchRequest<AccountEntity>(entityName: "AccountEntity")
    }
}
