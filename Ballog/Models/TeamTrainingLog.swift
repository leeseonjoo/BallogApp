import Foundation

struct TeamTrainingLog: Identifiable, Codable {
    let id = UUID()
    let date: Date
    let tactic: String
    let skill: String
    let notes: String

    var summary: String { "\(tactic) / \(skill)" }
}
