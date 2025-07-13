import SwiftUI
import CoreData

private enum Layout {
    static let padding = DesignConstants.horizontalPadding
}

struct AdminView: View {
    @FetchRequest(entity: AccountEntity.entity(), sortDescriptors: [])
    private var accounts: FetchedResults<AccountEntity>
    @Environment(\.managedObjectContext) private var context

    var body: some View {
        NavigationStack {
            List {
                ForEach(accounts) { account in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(account.username)
                                .font(.headline)
                            Text(account.email)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Toggle("관리자", isOn: Binding(get: { account.isAdmin }, set: { newVal in
                            account.isAdmin = newVal
                            try? context.save()
                        }))
                        .labelsHidden()
                    }
                }
                .onDelete(perform: delete)
            }
            .listStyle(.insetGrouped)
            .padding(.horizontal, Layout.padding)
            .navigationTitle("사용자 관리")
            .toolbar { EditButton() }
            .scrollContentBackground(.hidden)
        }
        .background(Color.pageBackground)
        .ignoresSafeArea()
        .ballogTopBar()
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            context.delete(accounts[index])
        }
        try? context.save()
    }
}

#Preview {
    AdminView()
        .environment(\.managedObjectContext, CoreDataStack.shared.container.viewContext)
}
