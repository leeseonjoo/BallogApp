import SwiftUI

struct TeamTrainingLogView: View {
    @EnvironmentObject private var logStore: TeamTrainingLogStore
    @Environment(\.dismiss) private var dismiss
    @State private var date = Date()
    @State private var time = ""
    @State private var location = ""
    @State private var condition = 5
    @State private var invited = ""
    @State private var tactic = ""
    @State private var skill = "아이솔레이션"
    private let skills = ["아이솔레이션", "슛페이크 동작", "롤링드리블", "등딱턴"]
    @State private var notes = ""

    var body: some View {
        Form {
            DatePicker("날짜", selection: $date, displayedComponents: .date)
            TextField("시간", text: $time)
            TextField("장소", text: $location)
            Stepper(value: $condition, in: 1...10) {
                Text("컨디션: \(condition)")
            }
            TextField("같이 훈련한 팀원 초대", text: $invited)
            TextField("팀 전술 훈련내용", text: $tactic)
            Picker("기술 훈련", selection: $skill) {
                ForEach(skills, id: \.self) { Text($0) }
            }
            Section(header: Text("배운점/느낀점")) {
                TextEditor(text: $notes)
                    .frame(height: 100)
            }
        }
        .navigationTitle("팀 훈련일지")
        .toolbar {
            Button("저장") {
                let log = TeamTrainingLog(date: date, tactic: tactic, skill: skill, notes: notes)
                logStore.add(log)
                dismiss()
            }
        }
    }
}

#Preview {
    NavigationStack { TeamTrainingLogView() }
        .environmentObject(TeamTrainingLogStore())
}
