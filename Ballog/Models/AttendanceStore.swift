import Foundation
import SwiftUI

final class AttendanceStore: ObservableObject {
    @Published var results: [Date: Bool] = [:]

    func set(_ value: Bool, for date: Date) {
        let day = Calendar.current.startOfDay(for: date)
        results[day] = value
    }
}
