//
//  BallogApp.swift
//  Ballog
//
//  Created by 이선주 on 7/8/25.
//

import SwiftUI
import SwiftData

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
    @AppStorage("profileCard") private var storedCard: String = ""
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @State private var showProfileCreator = false

    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                ContentView()
                    .environmentObject(attendanceStore)
                    .environmentObject(logStore)
                    .environmentObject(teamStore)
                    .sheet(isPresented: $showProfileCreator) {
                        ProfileCardCreationView()
                    }
                    .onAppear { if storedCard.isEmpty { showProfileCreator = true } }
                    .onChange(of: storedCard) { newValue in
                        if newValue.isEmpty { showProfileCreator = true }
                    }
            } else {
                LoginView()
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
