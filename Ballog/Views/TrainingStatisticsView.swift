import SwiftUI
import HealthKit

struct TrainingStatisticsView: View {
    @State private var sessions: [WorkoutSession] = []
    @State private var isLoading = false
    @State private var showHealthKitAlert = false
    @State private var healthKitAuthorized = false
    @State private var summary: WorkoutSummary? = nil
    @State private var soccerStats: WorkoutStats? = nil
    @State private var isLoadingSoccerStats = false
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    @State private var prevMonthStats: WorkoutStats? = nil
    @State private var showMoreSessions = false

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // 실외 축구 월별 통계 요약 (UI 개선)
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "soccerball")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundColor(.primaryBlue)
                    Text("실외 축구 \(selectedYear)년 \(selectedMonth)월 통계 요약")
                        .font(.title2.bold())
                    Spacer()
                    Picker("연도", selection: $selectedYear) {
                        ForEach((2020...Calendar.current.component(.year, from: Date())), id: \.self) { y in
                            Text("\(y)년").tag(y)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    Picker("월", selection: $selectedMonth) {
                        ForEach(1...12, id: \.self) { m in
                            Text("\(m)월").tag(m)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                .padding(.bottom, 4)
                .onChange(of: selectedYear) { _ in
                    fetchSoccerStats()
                    fetchPrevMonthStats()
                }
                .onChange(of: selectedMonth) { _ in
                    fetchSoccerStats()
                    fetchPrevMonthStats()
                }
                if isLoadingSoccerStats {
                    ProgressView()
                } else if let stats = soccerStats {
                    SoccerStatsCard(stats: stats)
                } else {
                    Text("해당 월에 실외 축구 세션이 없습니다.")
                        .foregroundColor(.secondary)
                }
                // 전월 대비 안내 메시지
                if let stats = soccerStats, let prev = prevMonthStats {
                    let diff = (stats.totalDuration - prev.totalDuration) / 3600.0
                    if diff < 0 {
                        Text("전월 대비 \(String(format: "%.1f", -diff))시간 부족합니다.")
                            .font(.subheadline)
                            .foregroundColor(.red)
                            .padding(.top, 4)
                    }
                }
            }
            // 세션 요약 통계
            if let summary = summary {
                WorkoutSummaryView(summary: summary)
            } else {
                ProgressView("운동 요약 불러오는 중...")
            }
            Text("최근 운동 세션")
                .font(.title2.bold())
                .padding(.top, 8)
            if isLoading {
                ProgressView()
            } else if sessions.isEmpty {
                Text("운동 세션 기록이 없습니다.")
                    .foregroundColor(.secondary)
            } else {
                SessionCard(session: sessions[0])
                if sessions.count > 1 {
                    Button("더보기") { showMoreSessions = true }
                        .font(.subheadline)
                        .padding(.top, 4)
                }
            }
            Button(healthKitAuthorized ? "다시 동기화" : "피트니스 연동하기") {
                requestHealthKitAccess(force: true)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 8)
        }
        .onAppear {
            requestHealthKitAccess(force: false)
            fetchSummary()
            fetchSoccerStats()
            fetchPrevMonthStats()
        }
        .alert("HealthKit 권한이 필요합니다.", isPresented: $showHealthKitAlert) {
            Button("확인", role: .cancel) {}
        }
        .sheet(isPresented: $showMoreSessions) {
            MoreSessionsSheet(sessions: Array(sessions.dropFirst()))
        }
    }
    
    private func requestHealthKitAccess(force: Bool) {
        isLoading = true
        HealthKitManager.shared.requestAuthorization { success in
            DispatchQueue.main.async {
                healthKitAuthorized = success
                fetchSessions()
                if !success {
                    showHealthKitAlert = true
                }
            }
        }
    }
    
    private func fetchSessions() {
        HealthKitManager.shared.fetchRecentWorkouts(limit: 10) { result in
            DispatchQueue.main.async {
                self.sessions = result
                self.isLoading = false
            }
        }
    }

    private func fetchSummary() {
        HealthKitManager.shared.fetchWorkoutSummary { result in
            self.summary = result
        }
    }

    private func fetchSoccerStats() {
        isLoadingSoccerStats = true
        HealthKitManager.shared.fetchWorkouts(forYear: selectedYear, month: selectedMonth, activityType: .soccer) { sessions in
            self.soccerStats = HealthKitManager.shared.calculateStats(for: sessions)
            self.isLoadingSoccerStats = false
        }
    }
    private func fetchPrevMonthStats() {
        let prevMonth = selectedMonth == 1 ? 12 : selectedMonth - 1
        let prevYear = selectedMonth == 1 ? selectedYear - 1 : selectedYear
        HealthKitManager.shared.fetchWorkouts(forYear: prevYear, month: prevMonth, activityType: .soccer) { sessions in
            self.prevMonthStats = HealthKitManager.shared.calculateStats(for: sessions)
        }
    }
}

struct SessionCard: View {
    let session: WorkoutSession
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(activityTypeName(session.activityType))
                    .font(.headline)
                Spacer()
                Text(session.startDate, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            HStack(spacing: 16) {
                Label("\(Int(session.calories)) kcal", systemImage: "flame")
                Label(String(format: "%.2f km", session.distance/1000), systemImage: "figure.walk")
                Label(durationString(), systemImage: "clock")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    private func activityTypeName(_ type: HKWorkoutActivityType) -> String {
        switch type {
        case .running: return "러닝"
        case .walking: return "걷기"
        case .cycling: return "사이클링"
        case .soccer: return "축구"
        case .traditionalStrengthTraining: return "근력운동"
        case .functionalStrengthTraining: return "코어/서킷"
        case .yoga: return "요가"
        case .swimming: return "수영"
        case .other: return "기타"
        default: return String(describing: type)
        }
    }
    private func durationString() -> String {
        let interval = session.endDate.timeIntervalSince(session.startDate)
        let minutes = Int(interval/60)
        let seconds = Int(interval) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct WorkoutSummaryView: View {
    let summary: WorkoutSummary
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("총 운동 횟수: \(summary.totalCount)회")
                Spacer()
                Text("총 운동 시간: \(Int(summary.totalDuration/60))분")
            }
            if let type = summary.mostFrequentType {
                Text("가장 많이 한 운동: \(activityTypeName(type))")
            }
        }
        .font(.subheadline)
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    private func activityTypeName(_ type: HKWorkoutActivityType) -> String {
        switch type {
        case .running: return "러닝"
        case .walking: return "걷기"
        case .cycling: return "사이클링"
        case .soccer: return "축구"
        case .traditionalStrengthTraining: return "근력운동"
        case .functionalStrengthTraining: return "코어/서킷"
        case .yoga: return "요가"
        case .swimming: return "수영"
        case .other: return "기타"
        default: return String(describing: type)
        }
    }
}

struct SoccerStatsCard: View {
    let stats: WorkoutStats
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("총 세션", systemImage: "number.circle")
                Spacer()
                Text("\(stats.count)회")
            }
            HStack {
                Label("평균 시간", systemImage: "clock")
                Spacer()
                Text(formatTime(stats.averageDuration))
            }
            HStack {
                Label("총 시간", systemImage: "timer")
                Spacer()
                Text(formatTime(stats.totalDuration))
            }
            HStack {
                Label("총 칼로리", systemImage: "flame")
                Spacer()
                Text("\(Int(stats.totalCalories)) kcal")
            }
            HStack {
                Label("총 거리", systemImage: "figure.walk")
                Spacer()
                Text("\(String(format: "%.2f km", stats.totalDistance/1000))")
            }
        }
        .font(.subheadline)
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.primaryBlue.opacity(0.08)))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.primaryBlue, lineWidth: 1)
        )
        .shadow(color: Color.primaryBlue.opacity(0.08), radius: 4, x: 0, y: 2)
    }
    private func formatTime(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        return "\(hours)시간 \(minutes)분"
    }
}

struct MoreSessionsSheet: View {
    let sessions: [WorkoutSession]
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationView {
            List(sessions) { session in
                SessionCard(session: session)
            }
            .navigationTitle("운동 세션 전체보기")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("닫기") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    TrainingStatisticsView()
}
