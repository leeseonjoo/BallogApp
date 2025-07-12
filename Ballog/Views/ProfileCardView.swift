import SwiftUI

struct ProfileCardView: View {
    let card: ProfileCard
    var showIcon: Bool = true
    var showRecordButton: Bool = false

    var body: some View {
        VStack(spacing: 8) {
            HStack(alignment: .top) {
                if showIcon {
                    Image(card.iconName)
                        .resizable()
                        .frame(width: 80, height: 80)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(card.nickname)
                        .font(.title2.bold())
                    Text(card.birthdate, style: .date)
                    Text("소속팀: \(card.hasTeam ? "Y" : "N")")
                    Text("플랩 레벨: \(card.plapLevel)")
                    Text("선출 여부: \(card.athleteLevel)")
                }
                Spacer()
            }

            if showRecordButton {
                NavigationLink(destination: PersonalTrainingView()) {
                    Text("내훈련일지기록")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).stroke())
    }
}

#Preview {
    ProfileCardView(card: ProfileCard(iconName: "fan", nickname: "홍길동", birthdate: Date(), hasTeam: true, plapLevel: "비기너1", athleteLevel: "선출아님"))
}
