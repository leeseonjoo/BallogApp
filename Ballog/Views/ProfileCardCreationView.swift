import SwiftUI

struct ProfileCardCreationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var iconName: String = "fan"
    @State private var nickname: String = ""
    @State private var birthdate: Date = Date()
    @State private var hasTeam: Bool = false
    @State private var plapLevel: String = ProfileCard.levels.first ?? ""
    @State private var athleteLevel: String = ProfileCard.athleteLevels.first ?? ""
    @AppStorage("profileCard") private var storedCard: String = ""
    
    var onSave: ((String) -> Void)?

    private let icons = [
        "fan", "football-player-2", "football-player-3", "goalkeeper",
        "medal", "reading", "reading-2", "question", "soccer-player",
        "reading-4"
    ]

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(icons, id: \.self) { name in
                            Image(name)
                                .resizable()
                                .frame(width: 60, height: 60)
                                .padding(4)
                                .background(iconName == name ? Color.blue.opacity(0.3) : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .onTapGesture { iconName = name }
                        }
                    }
                }

                TextField("닉네임", text: $nickname)
                    .textFieldStyle(.roundedBorder)
                DatePicker("태어난 날짜", selection: $birthdate, displayedComponents: .date)
                Toggle("현재 소속팀이 있습니까?", isOn: $hasTeam)
                Picker("플랩 레벨", selection: $plapLevel) {
                    ForEach(ProfileCard.levels, id: \.self) { Text($0) }
                }
                Picker("선출 여부", selection: $athleteLevel) {
                    ForEach(ProfileCard.athleteLevels, id: \.self) { Text($0) }
                }

                Button("저장하기") { save() }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
            }
            .padding()
            .navigationTitle("프로필 카드 작성")
        }
    }

    private func save() {
        let card = ProfileCard(iconName: iconName, nickname: nickname, birthdate: birthdate, hasTeam: hasTeam, plapLevel: plapLevel, athleteLevel: athleteLevel)
        if let data = try? JSONEncoder().encode(card),
           let json = String(data: data, encoding: .utf8) {
            storedCard = json
            onSave?(json)
        }
        dismiss()
    }
}

#Preview {
    ProfileCardCreationView()
}
