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

            MainHomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("홈")
                }


        }
    }
}

#Preview {
    ContentView()
}
