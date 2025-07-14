import SwiftUI
import HealthKit

struct TrainingStatisticsView: View {
    @State private var totalSteps: Int = 0
    @State private var totalDistance: Double = 0.0
    @State private var totalCalories: Double = 0.0
    @State private var totalWorkouts: Int = 0
    @State private var showHealthKitAlert = false
    @State private var healthKitAuthorized = false
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Activity Rings (Steps, Distance, Calories)
            HStack(spacing: 24) {
                ActivityRingView(value: totalSteps, goal: 10000, label: "걸음수", color: .blue, unit: "걸음")
                ActivityRingView(value: Int(totalDistance), goal: 8, label: "거리", color: .green, unit: "km")
                ActivityRingView(value: Int(totalCalories), goal: 500, label: "칼로리", color: .red, unit: "kcal")
            }
            .frame(height: 120)
            // Summary Cards
            HStack(spacing: 16) {
                StatSummaryCard(title: "총 운동 세션", value: "\(totalWorkouts)", icon: "figure.walk")
                StatSummaryCard(title: "총 거리", value: String(format: "%.2f km", totalDistance), icon: "map")
            }
            // HealthKit 연동 버튼
            Button(action: {
                requestHealthKitAccess(force: true)
            }) {
                Text(healthKitAuthorized ? "HealthKit 동기화됨 (다시 동기화)" : "HealthKit 연동하기")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(healthKitAuthorized ? Color.green : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.top, 8)
            .alert("HealthKit 접근 권한이 필요합니다.", isPresented: $showHealthKitAlert) {
                Button("확인", role: .cancel) {}
            }
            // Loading indicator
            if isLoading {
                ProgressView("데이터 불러오는 중...")
                    .padding()
            }
        }
        .padding(.vertical, 8)
        .onAppear {
            requestHealthKitAccess(force: false)
        }
    }
    
    private func requestHealthKitAccess(force: Bool) {
        HealthKitManager.shared.requestAuthorization { success in
            DispatchQueue.main.async {
                healthKitAuthorized = success
                if success || force { fetchHealthKitData() }
                else { showHealthKitAlert = true }
            }
        }
    }
    
    private func fetchHealthKitData() {
        isLoading = true
        HealthKitManager.shared.fetchStatistics { stats in
            DispatchQueue.main.async {
                self.totalSteps = stats.steps
                self.totalDistance = stats.distance
                self.totalCalories = stats.calories
                self.totalWorkouts = stats.workouts
                self.isLoading = false
            }
        }
    }
}

// Activity Ring View
struct ActivityRingView: View {
    let value: Int
    let goal: Int
    let label: String
    let color: Color
    let unit: String
    
    var progress: Double { min(Double(value) / Double(goal), 1.0) }
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(color, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut, value: progress)
                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .bold()
            }
            .frame(width: 70, height: 70)
            Text(label)
                .font(.subheadline)
            Text("\(value) \(unit)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// Stat Summary Card
struct StatSummaryCard: View {
    let title: String
    let value: String
    let icon: String
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 32, height: 32)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.headline)
            }
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    TrainingStatisticsView()
}
