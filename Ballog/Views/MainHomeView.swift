//
//  MainHomeView.swift
//  Ballog
//
//  Created by 이선주 on 7/9/25.
//

import SwiftUI

struct MainHomeView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
            // 상단 바
            HStack {
                Text("볼터치")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.leading)
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .padding(.trailing)
                }
            }
            .padding(.vertical, 8)

            // 훈련 요약 박스
            HStack {
                VStack(alignment: .leading) {
                    Text("이번주 훈련 요약")
                        .font(.headline)
                    Text("시간: 2시간 | 거리: 4.2km")
                        .font(.subheadline)
                    Text("기술: 삼자패스, 수비전환")
                        .font(.subheadline)
                }
                Spacer()
            }
            .padding()
            .background(Color.yellow.opacity(0.2))
            .cornerRadius(12)
            .padding(.horizontal)

            // 캐릭터 + 공풀장
            ZStack {
                Color.blue.opacity(0.1)
                    .frame(height: 300)

                VStack {
                    Image(systemName: "teddybear.fill") // 곰돌이 아이콘 대체용
                        .resizable()
                        .frame(width: 120, height: 120)

                    Text("내 캐릭터")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(.top, 16)

                Spacer()
            }
            .navigationTitle("홈")
        }
    }
}

#Preview {
    MainHomeView()
}
