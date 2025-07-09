//
//  PixelTreeView.swift
//  Ballog
//
//  Created by OpenAI on 7/9/25.
//

import SwiftUI

struct PixelTreeView: View {
    @ObservedObject var viewModel: PixelTreeViewModel

    var body: some View {
        VStack(spacing: 12) {
            PixelView(pixelColors: viewModel.pixelGrid)
            HStack {
                ForEach(Skill.allCases) { skill in
                    Button(action: { viewModel.complete(skill: skill) }) {
                        Text(label(for: skill))
                            .font(.caption)
                            .padding(6)
                            .background(RoundedRectangle(cornerRadius: 4).stroke())
                    }
                }
            }
        }
    }

    private func label(for skill: Skill) -> String {
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
    PixelTreeView(viewModel: PixelTreeViewModel())
}
