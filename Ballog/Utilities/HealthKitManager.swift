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
        let query = HKSampleQuery(sampleType: workoutType, predicate: nil, limit: limit, sortDescriptors: [sortDescriptor]) { _, samples, _ in
            let workouts = (samples as? [HKWorkout])?.map { workout in
                WorkoutSession(
                    activityType: workout.workoutActivityType,
                    startDate: workout.startDate,
                    endDate: workout.endDate,
                    calories: workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0,
                    distance: workout.totalDistance?.doubleValue(for: .meter()) ?? 0
                )
            } ?? []
            completion(workouts)
        }
        healthStore.execute(query)
    }
} 