import Foundation

final class TeamTacticStore: ObservableObject {
    @Published var tactics: [TeamTactic] = []

    func add(_ tactic: TeamTactic) { tactics.append(tactic) }
    func remove(at offsets: IndexSet) { tactics.remove(atOffsets: offsets) }
    func update(_ tactic: TeamTactic) {
        if let index = tactics.firstIndex(where: { $0.id == tactic.id }) {
            tactics[index] = tactic
        }
    }
}
