//
//  SkillProgressModel.swift
//  Ballog
//
//  Created by OpenAI on 7/9/25.
//

import SwiftUI

final class SkillProgressModel: ObservableObject {
    enum Skill: String, CaseIterable, Identifiable {
        case pass
        case marseilleTurn
        case twoOnePass
        case shooting
        case defense

        var id: String { rawValue }
    }

    struct SkillInfo {
        let color: Color
        let positions: [(Int, Int)]
    }

    private let gridSize = 10

    @Published var pixelGrid: [[Color]]
    private var completedSkills: Set<Skill> = []

    let skillInfos: [Skill: SkillInfo] = [
        .pass: SkillInfo(color: .green, positions: [(2,4), (2,5), (1,4), (1,5)]),
        .marseilleTurn: SkillInfo(color: .black, positions: [(4,4), (5,4), (6,4), (4,5), (5,5), (6,5)]),
        .twoOnePass: SkillInfo(color: .brown, positions: [(7,3), (7,4), (7,5)]),
        .shooting: SkillInfo(color: .red, positions: [(3,4), (3,5)]),
        .defense: SkillInfo(color: .blue, positions: [(0,4), (0,5)])
    ]

    init() {
        pixelGrid = Array(repeating: Array(repeating: Color.clear, count: gridSize), count: gridSize)
    }

    func complete(skill: Skill) {
        guard !completedSkills.contains(skill), let info = skillInfos[skill] else { return }
        completedSkills.insert(skill)
        for pos in info.positions {
            pixelGrid[pos.0][pos.1] = info.color
        }
    }
}
