//
//  PixelView.swift
//  Ballog
//
//  Created by OpenAI on 7/9/25.
//

import SwiftUI

struct PixelView: View {
    let pixelColors: [[Color]]
    
    var body: some View {
        VStack(spacing: 2) {
            ForEach(0..<pixelColors.count, id: \.self) { row in
                HStack(spacing: 2) {
                    ForEach(0..<pixelColors[row].count, id: \.self) { column in
                        Rectangle()
                            .fill(pixelColors[row][column])
                            .frame(width: 16, height: 16)
                    }
                }
            }
        }
    }
}

#Preview {
    PixelView(pixelColors: Array(repeating: Array(repeating: Color.green, count: 8), count: 8))
}
