import SwiftUI

struct LoginView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @AppStorage("hasTeam") private var hasTeam: Bool = true
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var teamOption: Bool = true

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("로그인")
                .font(.title2.bold())
            TextField("아이디", text: $username)
                .textFieldStyle(.roundedBorder)
            SecureField("비밀번호", text: $password)
                .textFieldStyle(.roundedBorder)
            Toggle("팀이 이미 있어요", isOn: $teamOption)
                .toggleStyle(.switch)
            Button("로그인") {
                isLoggedIn = true
                hasTeam = teamOption
            }
            .buttonStyle(.borderedProminent)
            Spacer()
        }
        .padding()
    }
}

#Preview {
    LoginView()
}
