//
//  BallogApp.swift
//  Ballog
//
//  Created by 이선주 on 7/8/25.
//

import SwiftUI
import SwiftData
import CoreData

@main
struct BallogApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    @StateObject private var attendanceStore = AttendanceStore()
    @StateObject private var logStore = TeamTrainingLogStore()
    @StateObject private var teamStore = TeamStore()
    @StateObject private var eventStore = TeamEventStore()
    @AppStorage("profileCard") private var storedCard: String = ""
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @AppStorage("autoLogin") private var autoLogin: Bool = false
    @AppStorage("savedUsername") private var savedUsername: String = ""
    @AppStorage("savedPassword") private var savedPassword: String = ""
    @AppStorage("isAdminUser") private var isAdminUser: Bool = false
    @State private var showProfileCreator = false
    private let persistenceController = CoreDataStack.shared

    var body: some Scene {
        WindowGroup {
            Group {
                if isLoggedIn {
                    ContentView()
                        .environmentObject(attendanceStore)
                        .environmentObject(logStore)
                        .environmentObject(teamStore)
                        .environmentObject(eventStore)
                        .sheet(isPresented: $showProfileCreator) {
                            ProfileCardCreationView()
                        }
                        .onAppear { if storedCard.isEmpty { showProfileCreator = true } }
                        .onChange(of: storedCard) { newValue in
                            if newValue.isEmpty { showProfileCreator = true }
                        }
                        .onChange(of: isLoggedIn) { newValue in
                            if !newValue { showProfileCreator = false }
                        }
                } else {
                    LoginView()
                        .environmentObject(eventStore)
                }
            }
            .onAppear {
                if !isLoggedIn && autoLogin {
                    if savedUsername == AdminCredentials.username && savedPassword == AdminCredentials.password {
                        isAdminUser = true
                        isLoggedIn = true
                    } else {
                        let req = AccountEntity.fetchRequest()
                        req.predicate = NSPredicate(format: "username == %@", savedUsername)
                        if let account = try? persistenceController.container.viewContext.fetch(req).first,
                           account.password == savedPassword {
                            isAdminUser = account.isAdmin
                            isLoggedIn = true
                        }
                    }
                }
            }
        }
        .modelContainer(sharedModelContainer)
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
    }
}
