//
//  ContentView.swift
//  Ballog
//
//  Created by 이선주 on 7/8/25.
//
import SwiftUI

struct ContentView: View {
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

            TeamManagementView()
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
        }
        .background(Color.pageBackground)
    }
}

#Preview {
    ContentView()
}
