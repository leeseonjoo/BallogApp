import SwiftUI
import HealthKit

struct PersonalPageView: View {
    @State private var showTrainingLogView = false
    @State private var todayWorkouts: [WorkoutSession] = []
    @State private var isLoadingTodayWorkouts = false
    @State private var showMonthSheet = false
    @State private var selectedMonth: (year: Int, month: Int)? = nil
    @State private var monthWorkouts: [WorkoutSession] = []
    @State private var isLoadingMonthWorkouts = false
    @State private var showStatistics = false
    @EnvironmentObject private var personalTrainingStore: PersonalTrainingStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // noteb 이미지
                    Image("noteb")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 160)
                    // 훈련일지 빠른 작성
                    TrainingLogQuickWriteCard()
                        .onTapGesture { showTrainingLogView = true }

                    // 훈련일지 진열 프레임 (책장 스타일)
                    TrainingLogShelfView(showStatistics: $showStatistics)
                        .padding(.top, 24)

                    // 오늘의 운동(피트니스 연동)
                    FitnessSummarySection(todayWorkouts: todayWorkouts, isLoading: isLoadingTodayWorkouts)

                    // 실외 축구 월별 통계 (기존 스타일)
                    MonthWorkoutSection(
                        title: selectedMonth != nil ? "\(selectedMonth!.month)월 실외 축구 세션 요약" : "이달의 실외 축구 세션 요약",
                        workouts: monthWorkouts,
                        isLoading: isLoadingMonthWorkouts,
                        showMore: { showMonthSheet = true },
                        showMoreText: "월 변경"
                    )
                }
                .padding(DesignConstants.horizontalPadding)
                .onAppear {
                    loadTodayWorkouts()
                    let now = Date()
                    let year = Calendar.current.component(.year, from: now)
                    let month = Calendar.current.component(.month, from: now)
                    loadMonthWorkouts(year: year, month: month)
                    selectedMonth = (year, month)
                }
                .sheet(isPresented: $showMonthSheet) {
                    MonthSelectorView(
                        onSelect: { year, month in
                            selectedMonth = (year, month)
                            loadMonthWorkouts(year: year, month: month)
                        },
                        monthWorkouts: monthWorkouts,
                        isLoading: isLoadingMonthWorkouts,
                        selectedMonth: selectedMonth
                    )
                }
                .sheet(isPresented: $showStatistics) {
                    TrainingStatisticsDetailView()
                        .environmentObject(personalTrainingStore)
                }
            }
            .background(Color.pageBackground)
        }
        .sheet(isPresented: $showTrainingLogView) {
            PersonalTrainingLogView()
                .environmentObject(personalTrainingStore)
        }
    }

    private func loadTodayWorkouts() {
        isLoadingTodayWorkouts = true
        HealthKitManager.shared.fetchTodayWorkouts { result in
            self.todayWorkouts = result
            self.isLoadingTodayWorkouts = false
        }
    }
    private func loadMonthWorkouts(year: Int, month: Int) {
        isLoadingMonthWorkouts = true
        HealthKitManager.shared.fetchWorkouts(forYear: year, month: month, activityType: .soccer) { sessions in
            self.monthWorkouts = sessions
            self.isLoadingMonthWorkouts = false
        }
    }
}

struct FitnessSummarySection: View {
    let todayWorkouts: [WorkoutSession]
    let isLoading: Bool
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("오늘의 운동")
                .font(.title3.bold())
            if isLoading {
                ProgressView()
            } else if todayWorkouts.isEmpty {
                Text("오늘 기록된 운동이 없습니다.")
                    .foregroundColor(.secondary)
            } else {
                ForEach(todayWorkouts) { session in
                    HStack {
                        Text(session.activityType.displayName)
                            .font(.headline)
                        Spacer()
                        Text(String(format: "%.2f km", session.distance/1000))
                            .foregroundColor(.primaryBlue)
                        Text("\(Int(session.calories)) kcal")
                            .foregroundColor(.orange)
                    }
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
        }
        .padding(.vertical, 12)
    }
}

extension HKWorkoutActivityType {
    var displayName: String {
        switch self {
        case .running: return "러닝"
        case .walking: return "걷기"
        case .cycling: return "사이클링"
        case .soccer: return "축구"
        case .traditionalStrengthTraining: return "근력운동"
        case .functionalStrengthTraining: return "코어/서킷"
        case .yoga: return "요가"
        case .swimming: return "수영"
        case .other: return "기타"
        default: return String(describing: self)
        }
    }
}

struct TrainingLogShelfView: View {
    @EnvironmentObject private var personalTrainingStore: PersonalTrainingStore
    @Binding var showStatistics: Bool
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 5)
    private let maxCount = 25
    var body: some View {
        let logs = Array(personalTrainingStore.logs.prefix(maxCount))
        let emptyCount = maxCount - logs.count
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("나의 훈련일지 진열장")
                    .font(.title3.bold())
                Spacer()
                Button(action: { showStatistics = true }) {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.title3)
                        .foregroundColor(.primaryBlue)
                        .padding(.trailing, 2)
                }
            }
            .padding(.bottom, 8)
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(0..<maxCount, id: \ .self) { idx in
                    if idx < logs.count {
                        TrainingLogBookCell(log: logs[idx])
                    } else {
                        EmptyBookCell()
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemGray6))
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
        }
        .padding(.horizontal, 4)
    }
}

struct TrainingLogBookCell: View {
    let log: PersonalTrainingLog
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: "book.fill")
                .resizable()
                .scaledToFit()
                .frame(height: 28)
                .foregroundColor(.primaryBlue)
            Text(log.title)
                .font(.caption2)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(width: 48, height: 48)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color.white))
        .shadow(radius: 1, y: 1)
    }
}

struct EmptyBookCell: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
            .foregroundColor(.secondary)
            .frame(width: 48, height: 48)
    }
}

struct TrainingStatisticsDetailView: View {
    @EnvironmentObject private var personalTrainingStore: PersonalTrainingStore
    @State private var manualDistance: String = ""
    @State private var manualCalories: String = ""
    @State private var manualTime: String = ""
    @State private var healthKitAvailable = false
    @State private var syncedDistance: Double? = nil
    @State private var syncedCalories: Double? = nil
    @State private var syncedTime: Double? = nil
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("훈련 상세 통계")
                .font(.title2.bold())
                .padding(.top, 8)
            Divider()
            // 훈련일지 기반 통계
            TrainingLogStatsView(logs: personalTrainingStore.logs)
            Divider()
            // 피트니스 연동 통계 or 수동 입력
            if healthKitAvailable {
                VStack(alignment: .leading, spacing: 8) {
                    Text("피트니스 연동 통계")
                        .font(.headline)
                    HStack {
                        Label("거리", systemImage: "figure.walk")
                        Spacer()
                        Text(syncedDistance != nil ? String(format: "%.2f km", syncedDistance!/1000) : "-")
                    }
                    HStack {
                        Label("칼로리", systemImage: "flame")
                        Spacer()
                        Text(syncedCalories != nil ? "\(Int(syncedCalories!)) kcal" : "-")
                    }
                    HStack {
                        Label("운동 시간", systemImage: "clock")
                        Spacer()
                        Text(syncedTime != nil ? "\(Int(syncedTime!/60))분" : "-")
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("피트니스 미연동 시 수동 입력")
                        .font(.headline)
                    HStack {
                        Label("거리", systemImage: "figure.walk")
                        Spacer()
                        TextField("km", text: $manualDistance)
                            .keyboardType(.decimalPad)
                            .frame(width: 80)
                            .textFieldStyle(.roundedBorder)
                    }
                    HStack {
                        Label("칼로리", systemImage: "flame")
                        Spacer()
                        TextField("kcal", text: $manualCalories)
                            .keyboardType(.numberPad)
                            .frame(width: 80)
                            .textFieldStyle(.roundedBorder)
                    }
                    HStack {
                        Label("운동 시간", systemImage: "clock")
                        Spacer()
                        TextField("분", text: $manualTime)
                            .keyboardType(.numberPad)
                            .frame(width: 80)
                            .textFieldStyle(.roundedBorder)
                    }
                }
            }
            Spacer()
        }
        .padding()
        .onAppear {
            // HealthKit 연동 여부 및 데이터 fetch
            HealthKitManager.shared.requestAuthorization { success in
                healthKitAvailable = success
                if success {
                    HealthKitManager.shared.fetchStatistics { stats in
                        syncedDistance = stats.distance * 1000 // km to m
                        syncedCalories = stats.calories
                        syncedTime = Double(stats.steps) // 예시: steps를 시간으로 변환 필요시 수정
                    }
                }
            }
        }
    }
}

struct TrainingLogStatsView: View {
    let logs: [PersonalTrainingLog]
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("내 훈련일지 기반 통계")
                .font(.headline)
            let totalCount = logs.count
            let totalDuration = logs.reduce(0) { $0 + $1.duration }
            let averageDuration = totalCount > 0 ? totalDuration / totalCount : 0
            Text("총 횟수: \(totalCount)회")
            Text("총 시간: \(totalDuration/60)시간 \(totalDuration%60)분")
            Text("평균 시간: \(averageDuration/60)분")
        }
        .padding(.bottom, 8)
    }
} 