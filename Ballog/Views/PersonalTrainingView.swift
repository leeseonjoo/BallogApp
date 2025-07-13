//
//  PersonalTrainingView.swift
//  Ballog
//
//  Created by 이선주 on 7/9/25.
//

import SwiftUI

private enum Layout {
    static let spacing = DesignConstants.spacing
    static let padding = DesignConstants.horizontalPadding
}

struct PersonalTrainingView: View {
    @AppStorage("profileCard") private var storedCard: String = ""

    @State private var selectedDate: Date? = nil
    @State private var attendance: [Date: Bool] = [:]
    @State private var logs: [String] = []

    private var card: ProfileCard? {
        guard let data = storedCard.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(ProfileCard.self, from: data)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: Layout.spacing) {
                InteractiveCalendarView(selectedDate: $selectedDate, attendance: $attendance, title: "개인 캘린더")
                    .padding(.horizontal, Layout.padding)

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
                .padding(.horizontal, Layout.padding)

            // 최근 훈련일지 요약 리스트
                VStack(alignment: .leading, spacing: 8) {
                    Text("📋 최근 훈련 일지")
                        .font(.headline)
                    if logs.isEmpty {
                        Text("훈련일지를 기록하세요")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(logs, id: \.self) { log in
                            HStack {
                                Text(log)
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
                }
                .padding(.horizontal, Layout.padding)

            // 훈련 통계 요약
                VStack(alignment: .leading, spacing: 8) {
                    Text("📊 훈련 통계 요약")
                        .font(.headline)
                    if logs.isEmpty {
                        Text("훈련을 시작하고 통계를 확인해보세요")
                            .foregroundColor(.secondary)
                    } else {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("총 횟수: \(logs.count)회")
                                Text("총 시간: 10시간")
                            }
                            Spacer()
                        }
                        NavigationLink(destination: TrainingStatisticsView()) {
                            Text("상세 통계 보기 →")
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal, Layout.padding)

                Spacer()
            }
            .navigationTitle("")
        }
        .background(Color.pageBackground)
        .ignoresSafeArea()
    }
}

#Preview {
    PersonalTrainingView()
}
