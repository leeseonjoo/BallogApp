import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class FirestoreAccountService {
    static let shared = FirestoreAccountService()
    private let db = Firestore.firestore()
    private init() {}

    func fetchAccount(username: String, completion: @escaping (Account?) -> Void) {
        db.collection("accounts").document(username).getDocument { snapshot, error in
            if let account = try? snapshot?.data(as: Account.self) {
                completion(account)
            } else {
                completion(nil)
            }
        }
    }

    func createAccount(_ account: Account, completion: ((Error?) -> Void)? = nil) {
        do {
            try db.collection("accounts").document(account.username).setData(from: account) { error in
                completion?(error)
            }
        } catch {
            completion?(error)
        }
    }
}
