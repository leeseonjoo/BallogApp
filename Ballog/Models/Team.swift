import Foundation

struct Team: Identifiable, Codable {
    let id: UUID
    var name: String
    var sport: String
    var gender: String
    var type: String
    var region: String
    let code: String
    var trainingTime: String
    var members: [TeamCharacter]
    var creatorId: String
    var creatorName: String
    var createdAt: Date
    var logo: Data?

    init(
        id: UUID = UUID(),
        name: String,
        sport: String = "풋살",
        gender: String = "혼성",
        type: String = "club",
        region: String = "",
        code: String = String(UUID().uuidString.prefix(8)),
        trainingTime: String = "매주 화요일 19:00",
        members: [TeamCharacter] = [],
        creatorId: String = "",
        creatorName: String = "",
        createdAt: Date = Date(),
        logo: Data? = nil
    ) {
        self.id = id
        self.name = name
        self.sport = sport
        self.gender = gender
        self.type = type
        self.region = region
        self.code = code
        self.trainingTime = trainingTime
        self.members = members
        self.creatorId = creatorId
        self.creatorName = creatorName
        self.createdAt = createdAt
        self.logo = logo
    }
}
