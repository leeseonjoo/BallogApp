//
//  BallogApp.swift
//  Ballog
//
//  Created by 이선주 on 7/8/25.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import SwiftData

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
      }
    }

@main
struct BallogApp: App {
    // Firebase 초기화
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        FirebaseApp.configure()
    }

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
    @StateObject private var tacticStore = TeamTacticStore()
    @StateObject private var requestStore = TeamJoinRequestStore()
    @StateObject private var personalTrainingStore = PersonalTrainingStore()
    @StateObject private var teamGoalStore = TeamGoalStore()
    @StateObject private var matchMatchingStore = MatchMatchingStore()
    @AppStorage("profileCard") private var storedCard: String = ""
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @AppStorage("autoLogin") private var autoLogin: Bool = false
    @AppStorage("savedUsername") private var savedUsername: String = ""
    @AppStorage("savedPassword") private var savedPassword: String = ""
    @AppStorage("isAdminUser") private var isAdminUser: Bool = false
    @State private var showProfileCreator = false
    
    // 유저별 프로필카드 키 생성
    private func profileCardKey(for username: String) -> String {
        "profileCard_\(username)"
    }
    
    private func loadProfileCard(for username: String) {
        let key = profileCardKey(for: username)
        if let card = UserDefaults.standard.string(forKey: key) {
            storedCard = card
        } else {
            storedCard = ""
        }
    }
    
    private func saveProfileCard(for username: String, card: String) {
        let key = profileCardKey(for: username)
        UserDefaults.standard.set(card, forKey: key)
    }
    
    private func clearProfileCard() {
        storedCard = ""
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if isLoggedIn {
                    ContentView()
                        .environmentObject(attendanceStore)
                        .environmentObject(logStore)
                        .environmentObject(teamStore)
                        .environmentObject(eventStore)
                        .environmentObject(tacticStore)
                        .environmentObject(requestStore)
                        .environmentObject(personalTrainingStore)
                        .environmentObject(teamGoalStore)
                        .environmentObject(matchMatchingStore)
                        .sheet(isPresented: $showProfileCreator) {
                            ProfileCardCreationView(onSave: { cardString in
                                saveProfileCard(for: savedUsername, card: cardString)
                                storedCard = cardString
                            })
                        }
                        .onAppear {
                            loadProfileCard(for: savedUsername)
                            if storedCard.isEmpty { showProfileCreator = true }
                        }
                        .onChange(of: storedCard) { newValue in
                            if newValue.isEmpty { showProfileCreator = true }
                        }
                        .onChange(of: isLoggedIn) { newValue in
                            if !newValue {
                                clearProfileCard()
                                showProfileCreator = false
                                personalTrainingStore.setCurrentUser("")
                            } else {
                                loadProfileCard(for: savedUsername)
                                personalTrainingStore.setCurrentUser(savedUsername)
                            }
                        }
                } else {
                    LoginView()
                        .environmentObject(eventStore)
                        .environmentObject(requestStore)
                }
            }
            .onAppear {
                handleAutoLogin()
                HealthKitManager.shared.requestAuthorization { _ in }
            }
        }
        .modelContainer(sharedModelContainer)
    }

    private func handleAutoLogin() {
        if !isLoggedIn && autoLogin {
            if savedUsername == AdminCredentials.username && savedPassword == AdminCredentials.password {
                isAdminUser = true
                isLoggedIn = true
            } else {
                FirestoreAccountService.shared.fetchAccount(username: savedUsername) { account in
                    if let account, account.password == savedPassword {
                        isAdminUser = account.isAdmin
                        isLoggedIn = true
                    }
                }
            }
        }
    }
}
