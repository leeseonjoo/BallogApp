import Foundation
import SwiftUI

final class AttendanceStore: ObservableObject {
    @Published var results: [Date: Bool] = [:]
    
    private let attendanceKey = "AttendanceResults"
    
    init() {
        loadAttendance()
    }

    func set(_ value: Bool, for date: Date) {
        let day = Calendar.current.startOfDay(for: date)
        results[day] = value
        saveAttendance()
    }
    
    private func saveAttendance() {
        if let data = try? JSONEncoder().encode(results) {
            UserDefaults.standard.set(data, forKey: attendanceKey)
        }
    }
    
    private func loadAttendance() {
        if let data = UserDefaults.standard.data(forKey: attendanceKey),
           let decodedResults = try? JSONDecoder().decode([Date: Bool].self, from: data) {
            results = decodedResults
        }
    }
}
