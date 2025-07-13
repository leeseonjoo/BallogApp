import SwiftUI
import CoreData

struct LoginView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @AppStorage("hasTeam") private var hasTeam: Bool = false
    @AppStorage("savedUsername") private var savedUsername: String = ""
    @AppStorage("savedPassword") private var savedPassword: String = ""
    @AppStorage("rememberID") private var rememberID: Bool = false
    @AppStorage("autoLogin") private var autoLogin: Bool = false
    @AppStorage("isAdminUser") private var isAdminUser: Bool = false
    @Environment(\.managedObjectContext) private var context

    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showSignup = false
    @State private var alertMessage = ""
    @State private var showAlert = false


    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("로그인")
                .font(.title2.bold())
            TextField("아이디", text: $username)
                .textFieldStyle(.roundedBorder)
            SecureField("비밀번호", text: $password)
                .textFieldStyle(.roundedBorder)
            Toggle("자동 로그인", isOn: $autoLogin)
            Toggle("아이디 저장", isOn: $rememberID)
            HStack {
                Button("로그인") { attemptLogin() }
                    .buttonStyle(.borderedProminent)
                Button("회원가입") { showSignup = true }
                    .buttonStyle(.bordered)
            }
            Spacer()
        }
        .padding()
        .onAppear { applySavedInfo() }
        .alert(alertMessage, isPresented: $showAlert) { Button("확인", role: .cancel) {} }
        .sheet(isPresented: $showSignup) { SignUpView() }
    }

    private func applySavedInfo() {
        if rememberID {
            username = savedUsername
        }
        if autoLogin {
            username = savedUsername
            password = savedPassword
            let req = AccountEntity.fetchRequest()
            req.predicate = NSPredicate(format: "username == %@", username)
            if let account = try? context.fetch(req).first, account.password == password {
                isAdminUser = account.isAdmin
                isLoggedIn = true
            }
        }
    }

    private func attemptLogin() {
        guard !username.isEmpty, !password.isEmpty else {
            alertMessage = "아이디와 비밀번호를 입력해주세요"
            showAlert = true
            return
        }

        let req = AccountEntity.fetchRequest()
        req.predicate = NSPredicate(format: "username == %@", username)
        guard let account = try? context.fetch(req).first else {
            alertMessage = "아이디가 존재하지 않습니다 회원가입 하시겠습니까?"
            showAlert = true
            showSignup = true
            return
        }

        guard account.password == password else {
            alertMessage = "비밀번호가 틀렸습니다"
            showAlert = true
            return
        }

        if rememberID { savedUsername = username } else { savedUsername = "" }
        if autoLogin { savedPassword = password } else { savedPassword = "" }
        isAdminUser = account.isAdmin
        isLoggedIn = true
    }
}

#Preview {
    LoginView()
        .environment(\.managedObjectContext, CoreDataStack.shared.container.viewContext)
}
