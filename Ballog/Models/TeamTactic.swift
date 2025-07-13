import Foundation

struct TeamTactic: Identifiable, Codable {
    let id: UUID
    var name: String
    var formation: String
    var notes: String
    var imageData: Data?
    var createdAt: Date

    init(id: UUID = UUID(), name: String, formation: String, notes: String = "", imageData: Data? = nil, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.formation = formation
        self.notes = notes
        self.imageData = imageData
        self.createdAt = createdAt
    }
}
