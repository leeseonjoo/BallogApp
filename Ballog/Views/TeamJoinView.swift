import SwiftUI

struct TeamJoinView: View {
    @State private var code: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("팀 조인하기")
                .font(.title2.bold())
            TextField("팀 코드 입력", text: $code)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
            NavigationLink("조인") {
                TeamManagementView_hae()
            }
            .buttonStyle(.borderedProminent)
            Spacer()
        }
        .padding()
        .navigationTitle("팀 조인")
    }
}

#Preview {
    NavigationStack { TeamJoinView() }
}
