import SwiftUI
import CoreData

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var username = ""
    @State private var password = ""
    @State private var email = ""
    @Environment(\.managedObjectContext) private var context

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

        let request = AccountEntity.fetchRequest()
        request.predicate = NSPredicate(format: "username == %@", username)

        let existing = (try? context.fetch(request)) ?? []
        guard existing.isEmpty else { return }

        let newAccount = AccountEntity(context: context)
        newAccount.username = username
        newAccount.password = password
        newAccount.email = email

        try? context.save()
        dismiss()
    }
}

#Preview {
    SignUpView()
        .environment(\.managedObjectContext, CoreDataStack.shared.container.viewContext)
}
