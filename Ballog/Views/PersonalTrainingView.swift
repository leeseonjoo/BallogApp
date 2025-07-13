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
            ScrollView {
                VStack(spacing: DesignConstants.sectionSpacing) {
                    // Calendar Section
                    calendarSection
                    
                    // Training Log Section
                    trainingLogSection
                    
                    // Statistics Section
                    statisticsSection
                }
                .padding(DesignConstants.horizontalPadding)
            }
            .background(Color.pageBackground)
        }
        .ballogTopBar()
    }
    
    private var calendarSection: some View {
        VStack(spacing: DesignConstants.sectionHeaderSpacing) {
            InteractiveCalendarView(selectedDate: $selectedDate, attendance: $attendance, title: "개인 캘린더")
                .padding(DesignConstants.cardPadding)
                .background(
                    RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                        .fill(Color.cardBackground)
                )
        }
    }
    
    private var trainingLogSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            HStack {
                Text("📝 훈련일지")
                    .font(.title2.bold())
                    .foregroundColor(Color.primaryText)
                Spacer()
            }
            
            VStack(spacing: DesignConstants.smallSpacing) {
                // Write Log Button
                Button(action: {
                    // 훈련일지 작성 페이지 이동
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Color.primaryBlue)
                        Text("훈련일지 작성하기")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(Color.primaryBlue)
                        Spacer()
                    }
                    .padding(DesignConstants.cardPadding)
                    .background(
                        RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                            .fill(Color.primaryBlue.opacity(0.1))
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                // Recent Logs
                VStack(alignment: .leading, spacing: DesignConstants.smallSpacing) {
                    Text("최근 훈련일지")
                        .font(.headline)
                        .foregroundColor(Color.primaryText)
                    
                    if logs.isEmpty {
                        VStack(spacing: DesignConstants.smallSpacing) {
                            Image(systemName: "doc.text")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(Color.secondaryText)
                            
                            Text("훈련일지를 기록하세요")
                                .font(.subheadline)
                                .foregroundColor(Color.secondaryText)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(DesignConstants.largePadding)
                        .background(
                            RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                                .fill(Color.cardBackground)
                        )
                    } else {
                        VStack(spacing: 0) {
                            ForEach(logs, id: \.self) { log in
                                VStack(alignment: .leading, spacing: DesignConstants.smallSpacing) {
                                    HStack {
                                        Text(log)
                                            .font(.subheadline)
                                            .foregroundColor(Color.primaryText)
                                        Spacer()
                                        HStack(spacing: 4) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(Color.successColor)
                                            Text("훈련완료")
                                                .font(.caption)
                                                .foregroundColor(Color.successColor)
                                        }
                                    }
                                    
                                    if log != logs.last {
                                        Divider()
                                            .padding(.vertical, DesignConstants.smallSpacing)
                                    }
                                }
                                .padding(DesignConstants.cardPadding)
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                                .fill(Color.cardBackground)
                        )
                        
                        Button("전체 보기 →") {
                            // 전체 훈련일지 리스트 페이지 이동
                        }
                        .font(.caption)
                        .foregroundColor(Color.primaryBlue)
                        .padding(.top, DesignConstants.smallSpacing)
                    }
                }
            }
        }
    }
    
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            HStack {
                Text("📊 훈련 통계")
                    .font(.title2.bold())
                    .foregroundColor(Color.primaryText)
                Spacer()
            }
            
            if logs.isEmpty {
                VStack(spacing: DesignConstants.smallSpacing) {
                    Image(systemName: "chart.bar")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(Color.secondaryText)
                    
                    Text("훈련을 시작하고 통계를 확인해보세요")
                        .font(.subheadline)
                        .foregroundColor(Color.secondaryText)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(DesignConstants.largePadding)
                .background(
                    RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                        .fill(Color.cardBackground)
                )
            } else {
                VStack(spacing: DesignConstants.smallSpacing) {
                    HStack {
                        VStack(alignment: .leading, spacing: DesignConstants.smallSpacing) {
                            Text("총 횟수: \(logs.count)회")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(Color.primaryText)
                            Text("총 시간: 10시간")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(Color.primaryText)
                        }
                        Spacer()
                        
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(Color.primaryBlue)
                    }
                    .padding(DesignConstants.cardPadding)
                    .background(
                        RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                            .fill(Color.cardBackground)
                    )
                    
                    NavigationLink(destination: TrainingStatisticsView()) {
                        HStack {
                            Text("상세 통계 보기")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(Color.primaryBlue)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(Color.primaryBlue)
                        }
                        .padding(DesignConstants.cardPadding)
                        .background(
                            RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                                .fill(Color.primaryBlue.opacity(0.1))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}

#Preview {
    PersonalTrainingView()
}

