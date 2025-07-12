import Foundation

struct ProfileCard: Codable {
    var iconName: String
    var nickname: String
    var birthdate: Date
    var hasTeam: Bool
    var plapLevel: String
    var athleteLevel: String
}

extension ProfileCard {
    static let levels: [String] = [
        "플랩 레벨없음", "비기너1", "비기너2", "비기너3", "비기너4", "비기너5",
        "아마추어1", "아마추어2", "아마추어3", "아마추어4", "아마추어5",
        "세미프로1", "세미프로2", "세미프로3", "세미프로4", "세미프로5",
        "프로1", "프로2", "프로3", "프로4", "프로5"
    ]

    static let athleteLevels: [String] = [
        "선출아님", "초등학교 선출", "중학교 선출", "고등학교 선출", "대학교 선출"
    ]
}
