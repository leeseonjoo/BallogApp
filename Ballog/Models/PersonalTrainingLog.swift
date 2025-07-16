import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class FirestoreManager: ObservableObject {
    private let db = Firestore.firestore()
    @Published var logs: [PersonalTrainingLog] = []

    func fetchLogs() {
        db.collection("personalTrainingLogs").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else { return }
            self.logs = documents.compactMap { try? $0.data(as: PersonalTrainingLog.self) }
        }
    }

    func addLog(_ log: PersonalTrainingLog) {
        do {
            _ = try db.collection("personalTrainingLogs").addDocument(from: log)
        } catch {
            print("Error adding log: \(error)")
        }
    }

    func updateLog(_ log: PersonalTrainingLog) {
        guard let id = log.id else { return }
        do {
            try db.collection("personalTrainingLogs").document(id).setData(from: log)
        } catch {
            print("Error updating log: \(error)")
        }
    }

    func deleteLog(_ log: PersonalTrainingLog) {
        guard let id = log.id else { return }
        db.collection("personalTrainingLogs").document(id).delete()
    }
} 
