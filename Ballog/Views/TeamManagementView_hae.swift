//
//  TeamManagementView.swift
//  Ballog
//
//  Created by 이선주 on 7/9/25.
//

import SwiftUI
import UIKit

private enum Layout {
    static let spacing = DesignConstants.spacing
    static let padding = DesignConstants.horizontalPadding
}

// MARK: - TeamMember 모델 정의
struct MyTeamMember: Identifiable {
    var id = UUID()
    var name: String
}
// MARK: - 모델 구조 추가

struct TrainingLog: Identifiable {
    let id = UUID()
    let title: String
    let memo: String
    let duration: Int
}

struct TrainingLogWrapper: Identifiable {
    let id = UUID()
    let day: Date
    let log: TrainingLog
}

// MARK: - 메인 팀 관리 뷰
struct TeamManagementView_hae: View {
    // 선택된 팀원 정보 (팝업용)
    @State private var selectedMember: MyTeamMember? = nil
    @State private var selectedDate: Date? = nil
    @State private var selectedLog: (Date, TeamTrainingLog)? = nil
    @State private var showLog = false
    @State private var showOptions = false
    @State private var showAttendance = false
    @EnvironmentObject private var attendanceStore: AttendanceStore
    @EnvironmentObject private var logStore: TeamTrainingLogStore

    private var tuesdayDates: [Date] {
        let calendar = Calendar.current
        guard let first = calendar.nextDate(after: Date(), matching: DateComponents(weekday: 3), matchingPolicy: .nextTime) else { return [] }
        return (0..<4).compactMap { calendar.date(byAdding: .day, value: 7 * $0, to: first) }
    }

    private var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "M월 d일 (E)"
        return f
    }

    @AppStorage("profileCard") private var storedCard: String = ""

    private var userName: String {
        guard let data = storedCard.data(using: .utf8),
              let card = try? JSONDecoder().decode(ProfileCard.self, from: data) else { return "사용자" }
        return card.nickname
    }

    private var teamMembers: [MyTeamMember] {
        [
            MyTeamMember(name: "혜진"),
            MyTeamMember(name: "규원"),
            MyTeamMember(name: "진주"),
            MyTeamMember(name: userName)
        ]
    }

    private var sortedLogs: [(Date, TeamTrainingLog)] {
        logStore.logs.flatMap { day, logs in logs.map { (day, $0) } }
            .sorted { $0.0 > $1.0 }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Layout.spacing) {
                    TeamHeaderView()
                    TeamQuoteView()
                    Divider()
                    CalendarSection(selectedDate: $selectedDate,
                                    showLog: $showLog,
                                    showOptions: $showOptions,
                                    showAttendance: $showAttendance)
                    NavigationLink("", isActive: $showLog) {
                        TeamTrainingLogView()
                            .environmentObject(logStore)
                    }
                    TrainingScheduleSection(dates: tuesdayDates, formatter: dateFormatter)
                    TrainingLogsSection(logs: sortedLogs) { day, log in
                        selectedLog = (day, log)
                    }
                    WriteLogButton { showLog = true }
                    TeamMembersSection(members: teamMembers) { member in
                        selectedMember = member
                    }
                    Spacer()
                }
            }
        }
        .sheet(item: $selectedLog) { data in
            TrainingLogDetailView(day: data.0, log: data.1)
        }
        .sheet(item: $selectedMember) { member in
            MyTeamMemberCardView(memberName: member.name)
        }
    }

    // MARK: - Subviews

    private struct TeamHeaderView: View {
        var body: some View {
            HStack {
                Image(systemName: "soccerball")
                    .resizable()
                    .frame(width: 30, height: 30)
                NavigationLink(destination: TeamListView()) {
                    Text("해그래 FS")
                        .font(.title)
                        .fontWeight(.bold)
                }
                .buttonStyle(.plain)
                Spacer()
            }
            .padding(.horizontal, Layout.padding)
        }
    }

    private struct TeamQuoteView: View {
        var body: some View {
            HStack {
                Image(systemName: "quote.bubble")
                    .foregroundColor(.gray)
                Text("“오늘도 파이팅!” - 잔디요정")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal, Layout.padding)
        }
    }

    private struct CalendarSection: View {
        @Binding var selectedDate: Date?
        @Binding var showLog: Bool
        @Binding var showOptions: Bool
        @Binding var showAttendance: Bool
        @EnvironmentObject private var attendanceStore: AttendanceStore

        var body: some View {
            InteractiveCalendarView(selectedDate: $selectedDate, attendance: $attendanceStore.results)
                .padding()
                .onChange(of: selectedDate) { _ in showOptions = selectedDate != nil }
                .confirmationDialog("선택", isPresented: $showOptions, titleVisibility: .visible) {
                    Button("매치 참석 가능 여부") { showAttendance = true }
                    Button("훈련일지 작성") { showLog = true }
                    Button("취소", role: .cancel) { selectedDate = nil }
                }
                .confirmationDialog("참석 여부", isPresented: $showAttendance, titleVisibility: .visible) {
                    Button("참석") {
                        if let date = selectedDate { attendanceStore.set(true, for: date) }
                        selectedDate = nil
                    }
                    Button("불참", role: .destructive) {
                        if let date = selectedDate { attendanceStore.set(false, for: date) }
                        selectedDate = nil
                    }
                    Button("취소", role: .cancel) { selectedDate = nil }
                }
        }
    }

    private struct TrainingScheduleSection: View {
        let dates: [Date]
        let formatter: DateFormatter

        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text("팀 정기 훈련 일정")
                    .font(.headline)
                ForEach(dates, id: \.self) { date in
                    HStack {
                        Text(formatter.string(from: date))
                        Spacer()
                        Text("누누 풋살장")
                        Spacer()
                        Button("✅ 참석") {}
                            .buttonStyle(.borderedProminent)
                    }
                }
            }
            .padding(.horizontal, Layout.padding)
        }
    }

    private struct TrainingLogsSection: View {
        let logs: [(Date, TeamTrainingLog)]
        var onSelect: (Date, TeamTrainingLog) -> Void

        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text("📋 최근 팀 훈련 일지")
                    .font(.headline)
                if logs.isEmpty {
                    Text("잊지 말고 훈련내용을 기억하세요")
                        .foregroundColor(.secondary)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(logs, id: \.1.id) { day, log in
                                TrainingLogCardView(day: day, log: log)
                                    .onTapGesture { onSelect(day, log) }
                            }
                        }
                        .padding(.horizontal, Layout.padding)
                    }
                }
            }
            .padding(.horizontal, Layout.padding)
        }
    }

    private struct WriteLogButton: View {
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                Text("✏️ 팀 훈련일지 작성")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.yellow.opacity(0.2))
                    .cornerRadius(10)
            }
            .padding(.horizontal, Layout.padding)
        }
    }

    private struct TeamMembersSection: View {
        let members: [MyTeamMember]
        var onSelect: (MyTeamMember) -> Void

        var body: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 24) {
                    ForEach(members) { member in
                        VStack {
                            Image(systemName: "person.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.blue)
                            Text(member.name)
                        }
                        .onTapGesture { onSelect(member) }
                    }
                }
                .padding(.horizontal, Layout.padding)
            }
        }
    }


// MARK: - 팝업: 팀원 캐릭터 카드
struct MyTeamMemberCardView: View {
    let memberName: String
    
    var body: some View {
        VStack(spacing: Layout.spacing) {
            Text("⚽️ \(memberName)의 캐릭터 카드")
                .font(.title2)
                .padding()
            Image(systemName: "person.crop.square")
                .resizable()
                .frame(width: 100, height: 100)
                .padding(.bottom, 8)
            Text("최근 훈련 4회 참석\n드리블 기술 향상 중")
                .multilineTextAlignment(.center)
                .padding()
        }
    }
}
