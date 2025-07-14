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

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // 실외 축구 월별 통계 요약
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("실외 축구 \(selectedYear)년 \(selectedMonth)월 통계 요약")
                        .font(.title3.bold())
                    Spacer()
                    Picker("월", selection: $selectedMonth) {
                        ForEach(1...12, id: \.self) { m in
                            Text("\(m)월").tag(m)
                        }
                    }
                    .frame(width: 80)
                    .onChange(of: selectedMonth) { _ in
                        fetchSoccerStats()
                    }
                }
                if isLoadingSoccerStats {
                    ProgressView()
                } else if let stats = soccerStats {
                    SoccerStatsView(stats: stats)
                } else {
                    Text("해당 월에 실외 축구 세션이 없습니다.")
                        .foregroundColor(.secondary)
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
                ForEach(sessions) { session in
                    SessionCard(session: session)
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
        }
        .alert("HealthKit 권한이 필요합니다.", isPresented: $showHealthKitAlert) {
            Button("확인", role: .cancel) {}
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

struct SoccerStatsView: View {
    let stats: WorkoutStats
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("총 세션: \(stats.count)회")
                Spacer()
                Text("평균 시간: \(formatTime(stats.averageDuration))")
            }
            HStack {
                Text("총 시간: \(formatTime(stats.totalDuration))")
                Spacer()
                Text("총 칼로리: \(Int(stats.totalCalories)) kcal")
            }
            HStack {
                Text("총 거리: \(String(format: "%.2f km", stats.totalDistance/1000))")
            }
        }
        .font(.subheadline)
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    private func formatTime(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        return "\(hours)시간 \(minutes)분"
    }
}

#Preview {
    TrainingStatisticsView()
}
