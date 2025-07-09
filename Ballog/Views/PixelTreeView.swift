//
//  PixelTreeView.swift
//  Ballog
//
//  Created by OpenAI on 7/9/25.
//

import SwiftUI

struct PixelTreeView: View {
    @ObservedObject var model: SkillProgressModel

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            PixelView(pixelColors: model.pixelGrid)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(SkillProgressModel.Skill.allCases, id: \.self) { skill in
                    Button(action: { model.complete(skill: skill) }) {
                        Text(label(for: skill))
                            .font(.caption)
                            .padding(6)
                            .background(RoundedRectangle(cornerRadius: 4).stroke())
                    }
                }
            }
        }
    }

    private func label(for skill: SkillProgressModel.Skill) -> String {
        switch skill {
        case .pass: return "패스"
        case .marseilleTurn: return "마르세유턴"
        case .twoOnePass: return "2대1"
        case .shooting: return "슈팅"
        case .defense: return "수비"
        }
    }
}

#Preview {
    PixelTreeView(model: SkillProgressModel())
}
