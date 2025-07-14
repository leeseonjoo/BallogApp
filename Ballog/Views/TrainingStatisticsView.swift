import SwiftUI
import HealthKit

struct TrainingStatisticsView: View {
    @State private var sessions: [WorkoutSession] = []
    @State private var isLoading = false
    @State private var showHealthKitAlert = false
    @State private var healthKitAuthorized = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
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

#Preview {
    TrainingStatisticsView()
}
