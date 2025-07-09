//
//  PixelTreeViewModel.swift
//  Ballog
//
//  Created by OpenAI on 7/9/25.
//

import SwiftUI

final class PixelTreeViewModel: ObservableObject {
    @Published var pixelGrid: [[Color]]
    private var completedSkills: Set<Skill> = []

    init() {
        pixelGrid = Array(repeating: Array(repeating: Color.clear, count: PixelTreeModel.gridSize), count: PixelTreeModel.gridSize)
    }

    func complete(skill: Skill) {
        guard !completedSkills.contains(skill), let info = PixelTreeModel.skills[skill] else { return }
        completedSkills.insert(skill)
        for pos in info.positions {
            pixelGrid[pos.0][pos.1] = info.color
        }
    }
}
