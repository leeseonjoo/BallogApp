//
//  PixelTreeView.swift.swift
//  Ballog
//
//  Created by 이선주 on 7/9/25.
//
import SwiftUI

struct PixelTreeView: View {
    // 10x10 픽셀 좌표 격자: 각 위치에 해당하는 스킬 이름을 연결
    let pixelMap: [[String?]] = [
        [nil, nil, nil, "shoot", "shoot", "shoot", nil, nil, nil, nil],
        [nil, nil, "pass", "pass", "pass", "pass", "pass", nil, nil, nil],
        [nil, "pass", "pass", "pass", "pass", "pass", "pass", "pass", nil, nil],
        [nil, nil, nil, "turn", "turn", "turn", nil, nil, nil, nil],
        [nil, nil, nil, "turn", "turn", "turn", nil, nil, nil, nil],
        [nil, nil, nil, "turn", "turn", "turn", nil, nil, nil, nil],
        [nil, nil, nil, "defense", "defense", "defense", nil, nil, nil, nil],
        [nil, nil, nil, "defense", "defense", "defense", nil, nil, nil, nil],
        [nil, nil, nil, "pass21", "pass21", "pass21", nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
    ]
    
    // 완료된 스킬 목록
    var completedSkills: Set<String> = ["pass", "turn", "shoot"]

    // 색상 맵
    let skillColors: [String: Color] = [
        "pass": .green,
        "shoot": .red,
        "turn": .brown,
        "defense": .blue,
        "pass21": .orange
    ]

    var body: some View {
        VStack(spacing: 2) {
            ForEach(0..<pixelMap.count, id: \.self) { row in
                HStack(spacing: 2) {
                    ForEach(0..<pixelMap[row].count, id: \.self) { col in
                        let skill = pixelMap[row][col]
                        Rectangle()
                            .fill(colorFor(skill: skill))
                            .frame(width: 12, height: 12)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }

    // 픽셀 색 결정 함수
    func colorFor(skill: String?) -> Color {
        guard let skill = skill else { return .clear }
        return completedSkills.contains(skill) ? skillColors[skill] ?? .black : .gray.opacity(0.2)
    }
}
