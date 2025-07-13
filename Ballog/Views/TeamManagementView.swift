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
// ``TeamCharacter`` (defined in ``TeamCharacterBoardView``) is used throughout
// this view. The previous ``MyTeamMember`` wrapper caused type mismatches when
// interacting with ``TeamCharacterBoardView``. Members are now stored directly
// as ``TeamCharacter`` values.
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

struct SelectedTeamLog: Identifiable {
    let day: Date
    let log: TeamTrainingLog
    var id: TeamTrainingLog.ID { log.id }
}

// MARK: - 메인 팀 관리 뷰
struct TeamManagementView: View {
    let team: Team
    // 선택된 팀원 정보 (팝업용)
    @State private var selectedMember: TeamCharacter? = nil
    @State private var selectedDate: Date? = nil
    @State private var selectedLog: SelectedTeamLog? = nil
    @State private var showLog = false
    @State private var showOptions = false
    @State private var showAttendance = false
    @State private var showEventCreation = false
    @EnvironmentObject private var attendanceStore: AttendanceStore
    @EnvironmentObject private var logStore: TeamTrainingLogStore
    @EnvironmentObject private var eventStore: TeamEventStore
    @State private var trainingWeather: WeatherCondition = .clear
    
    private var teamMembers: [TeamCharacter] {
        team.members
    }
    
    private var sortedLogs: [(Date, TeamTrainingLog)] {
        logStore.logs.flatMap { day, logs in logs.map { (day, $0) } }
            .sorted { $0.0 > $1.0 }
    }

    private var backgroundImage: String? {
        let month = Calendar.current.component(.month, from: Date())
        var name: String? = (6...8).contains(month) ? "summer" : nil
        if let weatherName = trainingWeather.imageName {
            name = weatherName
        }
        return name
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Layout.spacing) {
                    TeamHeaderView(teamName: team.name, team: team)
                    TeamCharacterBoardView(members: teamMembers, backgroundImage: backgroundImage) { member in
                        selectedMember = member
                    }
                    Divider()
                    CalendarSection(selectedDate: $selectedDate,
                                    showLog: $showLog,
                                    showOptions: $showOptions,
                                    showAttendance: $showAttendance,
                                    showEventCreation: $showEventCreation)
                    NavigationLink("", isActive: $showLog) {
                        TeamTrainingLogView()
                            .environmentObject(logStore)
                    }
                    TrainingLogsSection(logs: sortedLogs) { day, log in
                        selectedLog = SelectedTeamLog(day: day, log: log)
                    }
                    WriteLogButton { showLog = true }
                    Spacer()
                }
            }
        }
        .sheet(item: $selectedLog) { data in
            TrainingLogDetailView(day: data.day, log: data.log)
        }
        .sheet(item: $selectedMember) { member in
            MyTeamMemberCardView(memberName: member.name)
        }
        .sheet(isPresented: $showEventCreation) {
            TeamEventCreationView()
                .environmentObject(eventStore)
        }
    }
    
    // MARK: - Subviews
    
    private struct TeamHeaderView: View {
        let teamName: String
        let team: Team
        @State private var showJoinRequestManagement = false
        
        var body: some View {
            HStack {
                if let logoData = team.logo, let uiImage = UIImage(data: logoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                } else {
                    Image("pitch")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
                
                NavigationLink(destination: TeamListView()) {
                    Text(teamName)
                        .font(.title)
                        .fontWeight(.bold)
                }
                .buttonStyle(.plain)
                Spacer()
                
                Button(action: { showJoinRequestManagement = true }) {
                    Image(systemName: "person.badge.plus")
                        .foregroundColor(Color.primaryBlue)
                }
            }
            .padding(.horizontal, Layout.padding)
            .sheet(isPresented: $showJoinRequestManagement) {
                TeamJoinRequestManagementView(team: team)
            }
        }
    }
    
    
    private struct CalendarSection: View {
        @Binding var selectedDate: Date?
        @Binding var showLog: Bool
        @Binding var showOptions: Bool
        @Binding var showAttendance: Bool
        @Binding var showEventCreation: Bool
        @EnvironmentObject private var attendanceStore: AttendanceStore
        @EnvironmentObject private var eventStore: TeamEventStore
        
        var body: some View {
            VStack(spacing: 8) {
                InteractiveCalendarView(selectedDate: $selectedDate, attendance: $attendanceStore.results)
                    .padding()
                    .onChange(of: selectedDate) { _ in showOptions = selectedDate != nil }
                    .confirmationDialog("선택", isPresented: $showOptions, titleVisibility: .visible) {
                        Button("일정 추가") { showEventCreation = true }
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
                
                // 일정 추가 버튼
                Button(action: { showEventCreation = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Color.primaryBlue)
                        Text("팀 일정 추가")
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                            .fill(Color.primaryBlue.opacity(0.1))
                    )
                }
            }
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
}
