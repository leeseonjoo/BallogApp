import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("profileMessage") private var profileMessage: String = "하나가 되어 정상을 향해가는 순간\n힘들어도 극복하면서 자신있게!! 나아가자!!"

    var body: some View {
        Form {
            Section(header: Text("응원 문구")) {
                TextEditor(text: $profileMessage)
                    .frame(height: 120)
            }
            Button("완료") { dismiss() }
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .navigationTitle("프로필 수정")
    }
}

#Preview {
    NavigationStack { ProfileView() }
}
