import SwiftUI

enum Skill: String, CaseIterable, Identifiable {
    case pass
    case marseilleTurn
    case twoOnePass
    case shooting
    case defense

    var id: String { rawValue }
}

struct SkillPixelInfo {
    let color: Color
    let positions: [(Int, Int)]
}

struct PixelTreeModel {
    static let gridSize = 10
    static let skills: [Skill: SkillPixelInfo] = [
        .pass: SkillPixelInfo(color: .green, positions: [(2,4), (2,5), (1,4), (1,5)]),
        .marseilleTurn: SkillPixelInfo(color: .black, positions: [(4,4), (5,4), (6,4), (4,5), (5,5), (6,5)]),
        .twoOnePass: SkillPixelInfo(color: .brown, positions: [(7,3), (7,4), (7,5)]),
        .shooting: SkillPixelInfo(color: .red, positions: [(3,4), (3,5)]),
        .defense: SkillPixelInfo(color: .blue, positions: [(0,4), (0,5)])
    ]
}
