import Foundation

struct Account: Codable, Identifiable {
    var id: String { username }
    var username: String
    var password: String
    var email: String
    var isAdmin: Bool
}
