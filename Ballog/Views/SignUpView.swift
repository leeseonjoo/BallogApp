import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var username = ""
    @State private var password = ""
    @State private var email = ""
    @AppStorage("accounts") private var storedAccountsData: Data = Data()


    private var accounts: [String: Account] {
        get {
            (try? JSONDecoder().decode([String: Account].self,
                                        from: storedAccountsData)) ?? [:]
        }
        nonmutating set {
            storedAccountsData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }

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

    private var accounts: [String: Account] {
        get {
            (try? JSONDecoder().decode([String: Account].self, from: storedAccountsData)) ?? [:]
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                storedAccountsData = encoded
            }
        }
    }

    private mutating func register() {
        guard !username.isEmpty, !password.isEmpty, !email.isEmpty else { return }
        var dict = accounts
        dict[username] = Account(username: username, password: password, email: email)
        // 구조체 내에서 accounts = dict 호출 시 self 변경이 막히는 문제를 해결하려면 아래처럼 DispatchQueue.main.async 사용
        DispatchQueue.main.async {
            self.accounts = dict
            dismiss()
        }
    }
}

struct Account: Codable, Hashable {
    var username: String
    var password: String
    var email: String
}

#Preview {
    SignUpView()
}
