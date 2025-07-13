//
//  ContentView.swift
//  Ballog
//
//  Created by 이선주 on 7/8/25.
//
import SwiftUI

struct ContentView: View {
    @AppStorage("isAdminUser") private var isAdminUser: Bool = false

    var body: some View {
        TabView {
            MainHomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("홈")
                }

            PersonalTrainingView()
                .tabItem {
                    Image(systemName: "figure.walk")
                    Text("개인")
                }

            TeamPageView()
                .tabItem {
                    Image(systemName: "person.3.fill")
                    Text("팀")
                }

            FeedView()
                .tabItem {
                    Image(systemName: "square.stack")
                    Text("피드")
                }

            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("설정")
                }

            if isAdminUser {
                AdminView()
                    .tabItem {
                        Image(systemName: "lock.shield")
                        Text("관리자")
                    }
            }
        }
        .background(Color.pageBackground)
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
        .environmentObject(AttendanceStore())
        .environmentObject(TeamTrainingLogStore())
        .environmentObject(TeamTacticStore())
}
