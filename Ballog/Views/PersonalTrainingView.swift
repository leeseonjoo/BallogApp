//
//  PersonalTrainingView.swift
//  Ballog
//
//  Created by 이선주 on 7/9/25.
//

import SwiftUI

struct PersonalTrainingView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // 상단 달력 헤더
                HStack {
                    Text("2025년 7월")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                    Button(action: {
                        // 달력 전체 페이지 이동
                    }) {
                        Text("달력 보기")
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)

            // 훈련일지 작성 버튼
                Button(action: {
                    // 훈련일지 작성 페이지 이동
                }) {
                    Text("📝 훈련일지 작성하기")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.yellow.opacity(0.2))
                        .cornerRadius(10)
                }
                .padding(.horizontal)

            // 최근 훈련일지 요약 리스트
                VStack(alignment: .leading, spacing: 8) {
                    Text("📋 최근 훈련 일지")
                        .font(.headline)
                    ForEach(0..<5) { index in
                        HStack {
                            Text("7월 \(20 - index)일 • 개인훈련")
                            Spacer()
                            Text("👍 훈련완료")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                        .padding(.vertical, 4)
                        Divider()
                    }
                    Button("전체 보기 →") {
                        // 전체 훈련일지 리스트 페이지 이동
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(.top, 4)
                }
                .padding(.horizontal)

            // 훈련 통계 요약
                VStack(alignment: .leading, spacing: 8) {
                    Text("📊 훈련 통계 요약")
                        .font(.headline)
                    HStack {
                        VStack(alignment: .leading) {
                            Text("총 횟수: 12회")
                            Text("총 시간: 10시간")
                        }
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("기술별: 삼자패스 2h")
                            Text("유형별: 개인 6 / 팀 4 / 경기 2")
                        }
                    }
                    Button("상세 통계 보기 →") {
                        // 통계 페이지 이동
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
                .padding(.horizontal)

                Spacer()
            }
            .navigationTitle("개인 훈련")
        }
        .background(Color.pageBackground)
        .ignoresSafeArea()
    }
}

#Preview {
    PersonalTrainingView()
}
