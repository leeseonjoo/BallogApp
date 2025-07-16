import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var username = ""
    @State private var password = ""
    @State private var email = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("아이디", text: $username)
                SecureField("비밀번호", text: $password)
                TextField("이메일", text: $email)
            }
            .navigationTitle("회원가입")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("완료") { register() }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
            }
        }
    }

    private func register() {
        guard !username.isEmpty, !password.isEmpty, !email.isEmpty else { return }

        let account = Account(username: username,
                              password: password,
                              email: email,
                              isAdmin: false)

        FirestoreAccountService.shared.createAccount(account) { error in
            if error == nil { dismiss() }
        }
    }
}

#Preview {
    SignUpView()
}
