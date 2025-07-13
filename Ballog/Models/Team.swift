import Foundation

struct Team: Identifiable, Codable {
    let id: UUID
    var name: String
    var sport: String
    var gender: String
    var type: String
    
    init(id: UUID = UUID(), name: String, sport: String = "풋살", gender: String = "혼성", type: String = "club") {
        self.id = id
        self.name = name
        self.sport = sport
        self.gender = gender
        self.type = type
    }
}
