import Foundation
import HealthKit

struct HealthKitStatistics {
    let steps: Int
    let distance: Double // km
    let calories: Double // kcal
    let workouts: Int
}

struct WorkoutSession: Identifiable {
    let id = UUID()
    let activityType: HKWorkoutActivityType
    let startDate: Date
    let endDate: Date
    let calories: Double
    let distance: Double
}

struct WorkoutSummary {
    let totalCount: Int
    let totalDuration: TimeInterval // seconds
    let mostFrequentType: HKWorkoutActivityType?
}

struct WorkoutStats {
    let count: Int
    let totalDuration: TimeInterval
    let averageDuration: TimeInterval
    let totalCalories: Double
    let totalDistance: Double
}

final class HealthKitManager {
    static let shared = HealthKitManager()
    private let healthStore = HKHealthStore()
    
    private init() {}
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false)
            return
        }
        let readTypes: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.workoutType()
        ]
        healthStore.requestAuthorization(toShare: [], read: readTypes) { success, _ in
            completion(success)
        }
    }
    
    func fetchStatistics(completion: @escaping (HealthKitStatistics) -> Void) {
        let group = DispatchGroup()
        var steps = 0
        var distance = 0.0
        var calories = 0.0
        var workouts = 0
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        // Steps
        group.enter()
        fetchSumQuantity(type: .stepCount, start: startOfDay, end: now) { value in
            steps = Int(value)
            group.leave()
        }
        // Distance
        group.enter()
        fetchSumQuantity(type: .distanceWalkingRunning, start: startOfDay, end: now) { value in
            distance = value / 1000.0 // m to km
            group.leave()
        }
        // Calories
        group.enter()
        fetchSumQuantity(type: .activeEnergyBurned, start: startOfDay, end: now) { value in
            calories = value
            group.leave()
        }
        // Workouts
        group.enter()
        fetchWorkoutCount(start: startOfDay, end: now) { count in
            workouts = count
            group.leave()
        }
        group.notify(queue: .main) {
            completion(HealthKitStatistics(steps: steps, distance: distance, calories: calories, workouts: workouts))
        }
    }
    
    private func fetchSumQuantity(type identifier: HKQuantityTypeIdentifier, start: Date, end: Date, completion: @escaping (Double) -> Void) {
        guard let type = HKObjectType.quantityType(forIdentifier: identifier) else {
            completion(0)
            return
        }
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            var sum = 0.0
            if let quantity = result?.sumQuantity() {
                switch identifier {
                case .stepCount:
                    sum = quantity.doubleValue(for: .count())
                case .distanceWalkingRunning:
                    sum = quantity.doubleValue(for: .meter()) / 1000.0 // m → km
                case .activeEnergyBurned:
                    sum = quantity.doubleValue(for: .kilocalorie())
                default:
                    sum = 0.0
                }
            }
            completion(sum)
        }
        healthStore.execute(query)
    }
    
    private func fetchWorkoutCount(start: Date, end: Date, completion: @escaping (Int) -> Void) {
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        let query = HKSampleQuery(sampleType: .workoutType(), predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
            completion(samples?.count ?? 0)
        }
        healthStore.execute(query)
    }
}

extension HealthKitManager {
    func fetchRecentWorkouts(limit: Int = 10, completion: @escaping ([WorkoutSession]) -> Void) {
        let workoutType = HKObjectType.workoutType()
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: workoutType, predicate: nil, limit: limit, sortDescriptors: [sortDescriptor]) { _, samples, error in
            if let error = error {
                print("[HealthKitManager] fetchRecentWorkouts error: \(error.localizedDescription)")
            }
            print("[HealthKitManager] fetchRecentWorkouts samples count: \(samples?.count ?? 0)")
            let workouts: [WorkoutSession] = (samples as? [HKWorkout])?.map { workout in
                print("[HealthKitManager] workout: activityType=\(workout.workoutActivityType.rawValue), start=\(workout.startDate), end=\(workout.endDate)")
                let calories: Double
                if #available(iOS 18.0, *) {
                    if let stat = workout.statistics(for: HKQuantityType(.activeEnergyBurned)),
                       let quantity = stat.sumQuantity() {
                        calories = quantity.doubleValue(for: .kilocalorie())
                    } else {
                        calories = 0
                    }
                } else {
                    calories = workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0
                }
                return WorkoutSession(
                    activityType: workout.workoutActivityType,
                    startDate: workout.startDate,
                    endDate: workout.endDate,
                    calories: calories,
                    distance: workout.totalDistance?.doubleValue(for: .meter()) ?? 0
                )
            } ?? []
            completion(workouts)
        }
        healthStore.execute(query)
    }

    func fetchWorkoutSummary(completion: @escaping (WorkoutSummary) -> Void) {
        let workoutType = HKObjectType.workoutType()
        let query = HKSampleQuery(sampleType: workoutType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
            var totalCount = 0
            var totalDuration: TimeInterval = 0
            var typeCount: [HKWorkoutActivityType: Int] = [:]
            if let workouts = samples as? [HKWorkout] {
                totalCount = workouts.count
                for workout in workouts {
                    let duration = workout.endDate.timeIntervalSince(workout.startDate)
                    totalDuration += duration
                    typeCount[workout.workoutActivityType, default: 0] += 1
                }
            }
            let mostFrequentType = typeCount.max(by: { $0.value < $1.value })?.key
            let summary = WorkoutSummary(totalCount: totalCount, totalDuration: totalDuration, mostFrequentType: mostFrequentType)
            DispatchQueue.main.async {
                completion(summary)
            }
        }
        healthStore.execute(query)
    }

    func fetchTodayWorkouts(completion: @escaping ([WorkoutSession]) -> Void) {
        let workoutType = HKObjectType.workoutType()
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: workoutType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { _, samples, error in
            let workouts: [WorkoutSession] = (samples as? [HKWorkout])?.map { workout in
                let calories: Double
                if #available(iOS 18.0, *) {
                    if let stat = workout.statistics(for: HKQuantityType(.activeEnergyBurned)),
                       let quantity = stat.sumQuantity() {
                        calories = quantity.doubleValue(for: .kilocalorie())
                    } else {
                        calories = 0
                    }
                } else {
                    calories = workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0
                }
                return WorkoutSession(
                    activityType: workout.workoutActivityType,
                    startDate: workout.startDate,
                    endDate: workout.endDate,
                    calories: calories,
                    distance: workout.totalDistance?.doubleValue(for: .meter()) ?? 0
                )
            } ?? []
            DispatchQueue.main.async {
                completion(workouts)
            }
        }
        healthStore.execute(query)
    }

    func fetchWorkouts(forYear year: Int, month: Int, completion: @escaping ([WorkoutSession]) -> Void) {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        guard let startOfMonth = calendar.date(from: components) else {
            completion([])
            return
        }
        var comps = DateComponents()
        comps.month = 1
        comps.day = -1
        guard let endOfMonth = calendar.date(byAdding: comps, to: startOfMonth) else {
            completion([])
            return
        }
        let workoutType = HKObjectType.workoutType()
        let predicate = HKQuery.predicateForSamples(withStart: startOfMonth, end: endOfMonth, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: workoutType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { _, samples, error in
            let workouts: [WorkoutSession] = (samples as? [HKWorkout])?.map { workout in
                let calories: Double
                if #available(iOS 18.0, *) {
                    if let stat = workout.statistics(for: HKQuantityType(.activeEnergyBurned)),
                       let quantity = stat.sumQuantity() {
                        calories = quantity.doubleValue(for: .kilocalorie())
                    } else {
                        calories = 0
                    }
                } else {
                    calories = workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0
                }
                return WorkoutSession(
                    activityType: workout.workoutActivityType,
                    startDate: workout.startDate,
                    endDate: workout.endDate,
                    calories: calories,
                    distance: workout.totalDistance?.doubleValue(for: .meter()) ?? 0
                )
            } ?? []
            DispatchQueue.main.async {
                completion(workouts)
            }
        }
        healthStore.execute(query)
    }

    func fetchWorkouts(forYear year: Int, month: Int, activityType: HKWorkoutActivityType, completion: @escaping ([WorkoutSession]) -> Void) {
        fetchWorkouts(forYear: year, month: month) { sessions in
            let filtered = sessions.filter { $0.activityType == activityType }
            completion(filtered)
        }
    }
    func calculateStats(for sessions: [WorkoutSession]) -> WorkoutStats {
        let count = sessions.count
        let totalDuration = sessions.reduce(0) { $0 + $1.endDate.timeIntervalSince($1.startDate) }
        let averageDuration = count > 0 ? totalDuration / Double(count) : 0
        let totalCalories = sessions.reduce(0) { $0 + $1.calories }
        let totalDistance = sessions.reduce(0) { $0 + $1.distance }
        return WorkoutStats(count: count, totalDuration: totalDuration, averageDuration: averageDuration, totalCalories: totalCalories, totalDistance: totalDistance)
    }
} 