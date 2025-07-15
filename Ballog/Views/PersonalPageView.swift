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
    @EnvironmentObject private var personalTrainingStore: PersonalTrainingStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignConstants.sectionSpacing) {
                    // noteb 이미지
                    Image("noteb")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 160)
                        .padding(.top, 8)
                    // 훈련일지 빠른 작성
                    TrainingLogQuickWriteCard()
                        .onTapGesture { showTrainingLogView = true }

                    // 피트니스 앱 연동 운동/통계
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