import SwiftUI
import UIKit
import PhotosUI

struct TeamCreationView: View {
    private enum Step: Int { case name, sport, gender, type, source, region, done }
    @State private var step: Step = .name
    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject private var teamStore: TeamStore
    @EnvironmentObject private var eventStore: TeamEventStore
    @EnvironmentObject private var logStore: TeamTrainingLogStore
    @AppStorage("currentTeamID") private var currentTeamID: String = ""
    @AppStorage("hasTeam") private var hasTeam: Bool = true
    @AppStorage("profileCard") private var storedCard: String = ""

    @State private var teamName = ""
    @State private var sport = "풋살"
    @State private var gender = "남자"
    @State private var teamType = "club"
    @State private var source = "인스타"
    @State private var region = ""
    @State private var teamLogo: Data?
    @State private var selectedLogoItem: PhotosPickerItem?

    private var userCard: ProfileCard? {
        guard let data = storedCard.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(ProfileCard.self, from: data)
    }

    private let sports = ["풋살", "축구"]
    private let genders = ["남자", "여자", "혼성"]
    private let types = ["club", "회사 동호회", "Group of friends", "Recreational team", "School / University"]
    private let sources = ["인스타", "지인 소개", "블로그", "인터넷 검색"]

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            switch step {
            case .name:
                VStack(spacing: DesignConstants.largeSpacing) {
                    Text("팀 이름 작성해주세요")
                        .font(.title2.bold())
                        .foregroundColor(Color.primaryText)
                    
                    TextField("팀 이름", text: $teamName)
                        .textFieldStyle(.roundedBorder)
                    
                    VStack(spacing: DesignConstants.smallSpacing) {
                        Text("팀 로고 (선택사항)")
                            .font(.headline)
                            .foregroundColor(Color.primaryText)
                        
                        if let teamLogo = teamLogo, let uiImage = UIImage(data: teamLogo) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "camera.circle")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .foregroundColor(Color.secondaryText)
                        }
                        
                        PhotosPicker(selection: $selectedLogoItem, matching: .images) {
                            Text("로고 선택")
                                .foregroundColor(Color.primaryBlue)
                        }
                    }
                }
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
            case .region:
                Text("주요활동지역이 어디인가요?")
                TextField("지역", text: $region)
                    .textFieldStyle(.roundedBorder)
            case .done:
                VStack(spacing: DesignConstants.largeSpacing) {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(Color.successColor)
                    
                    VStack(spacing: DesignConstants.smallSpacing) {
                        Text("축하합니다 팀 생성이 완료되었어요!")
                            .font(.title2.bold())
                            .foregroundColor(Color.primaryText)
                        
                        Text("환영합니다 \(teamName) 팀!")
                            .font(.headline)
                            .foregroundColor(Color.secondaryText)
                    }
                    
                    VStack(spacing: DesignConstants.spacing) {
                        Button(action: { dismiss() }) {
                            HStack {
                                Image(systemName: "person.3.fill")
                                Text("팀 화면으로 가기")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.primaryBlue)
                            .foregroundColor(.white)
                            .cornerRadius(DesignConstants.cornerRadius)
                        }
                        
                        NavigationLink(destination: TeamLinkShareView(teamName: teamName)) {
                            HStack {
                                Image(systemName: "person.badge.plus")
                                Text("멤버 추가하기")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.primaryGreen)
                            .foregroundColor(.white)
                            .cornerRadius(DesignConstants.cornerRadius)
                        }
                    }
                }
            }
            Spacer()
            if step != .done {
                Button("다음") { nextStep() }
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .navigationTitle("팀 만들기")
        .onChange(of: selectedLogoItem) { newItem in
            if let newItem {
                Task {
                    teamLogo = try? await newItem.loadTransferable(type: Data.self)
                }
            }
        }
    }

    private func nextStep() {
        if let next = Step(rawValue: step.rawValue + 1) {
            step = next
            if step == .done {
                let member = TeamCharacter(
                    name: userCard?.nickname ?? "나",
                    imageName: userCard?.iconName ?? "soccer-player",
                    isOnline: false
                )
                let team = Team(
                    name: teamName,
                    sport: sport,
                    gender: gender,
                    type: teamType,
                    region: region,
                    members: [member],
                    creatorId: userCard?.nickname ?? "나",
                    creatorName: userCard?.nickname ?? "나",
                    logo: teamLogo
                )
                teamStore.addTeam(team)
                currentTeamID = team.id.uuidString
                hasTeam = true
                eventStore.events.removeAll()
                logStore.removeAll()
            }
        }
    }
}

#Preview {
    NavigationStack { TeamCreationView() }
}
