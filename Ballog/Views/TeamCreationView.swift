import SwiftUI
import UIKit

struct TeamCreationView: View {
    private enum Step: Int { case name, sport, gender, type, source, done }
    @State private var step: Step = .name

    @EnvironmentObject private var teamStore: TeamStore
    @EnvironmentObject private var eventStore: TeamEventStore
    @EnvironmentObject private var logStore: TeamTrainingLogStore
    @AppStorage("currentTeamID") private var currentTeamID: String = ""
    @AppStorage("hasTeam") private var hasTeam: Bool = true

    @State private var teamName = ""
    @State private var sport = "풋살"
    @State private var gender = "남자"
    @State private var teamType = "club"
    @State private var source = "인스타"

    private let sports = ["풋살", "축구"]
    private let genders = ["남자", "여자", "혼성"]
    private let types = ["club", "회사 동호회", "Group of friends", "Recreational team", "School / University"]
    private let sources = ["인스타", "지인 소개", "블로그", "인터넷 검색"]

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            switch step {
            case .name:
                Text("팀 이름 작성해주세요")
                TextField("팀 이름", text: $teamName)
                    .textFieldStyle(.roundedBorder)
            case .sport:
                Text("어떤 스포츠 인가요?")
                Picker("스포츠", selection: $sport) {
                    ForEach(sports, id: \..self) { Text($0) }
                }
                .pickerStyle(.segmented)
            case .gender:
                Text("팀의 성별이 어떻게 되나요?")
                Picker("성별", selection: $gender) {
                    ForEach(genders, id: \..self) { Text($0) }
                }
                .pickerStyle(.segmented)
            case .type:
                Text("어떤 타입의 팀인가요?")
                Picker("타입", selection: $teamType) {
                    ForEach(types, id: \..self) { Text($0) }
                }
            case .source:
                Text("볼로그는 어떻게 알게 되었나요?")
                Picker("경로", selection: $source) {
                    ForEach(sources, id: \..self) { Text($0) }
                }
            case .done:
                Text("축하합니다 팀 생성이 완료 되었어요!")
                    .font(.headline)
                Text("환영합니다 \(teamName) 팀!")
                NavigationLink("멤버 추가하기") {
                    TeamLinkShareView(teamName: teamName)
                }
                .buttonStyle(.borderedProminent)
            }
            Spacer()
            if step != .done {
                Button("다음") { nextStep() }
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .navigationTitle("팀 만들기")
    }

    private func nextStep() {
        if let next = Step(rawValue: step.rawValue + 1) {
            step = next
            if step == .done {
                let team = Team(name: teamName, sport: sport, gender: gender, type: teamType)
                teamStore.add(team)
                currentTeamID = team.id.uuidString
                hasTeam = true
                eventStore.events.removeAll()
                logStore.logs.removeAll()
            }
        }
    }
}

#Preview {
    NavigationStack { TeamCreationView() }
}
