//
//  ContentView.swift
//  Ballog
//
//  Created by 이선주 on 7/8/25.
//
import SwiftUI

struct ContentView: View {
    @AppStorage("isAdminUser") private var isAdminUser: Bool = false
    @State private var selectedTab: Int = 0
    @EnvironmentObject private var eventStore: TeamEventStore

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                MainHomeView()
                    .tag(0)
                
                PersonalTrainingView()
                    .tag(1)
                
                TeamPageView()
                    .tag(2)
                
                FeedView()
                    .tag(3)
                
                SettingsView()
                    .tag(4)
                
                if isAdminUser {
                    AdminView()
                        .tag(5)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            TabBarView(selectedTab: $selectedTab)
        }
        .background(Color.pageBackground)
        .ignoresSafeArea(.all, edges: .bottom)
    }
}

#Preview {
    ContentView()
        .environmentObject(AttendanceStore())
        .environmentObject(TeamTrainingLogStore())
        .environmentObject(TeamTacticStore())
}
