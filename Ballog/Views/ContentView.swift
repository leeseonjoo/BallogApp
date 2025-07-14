//
//  ContentView.swift
//  Ballog
//
//  Created by 이선주 on 7/8/25.
//
import SwiftUI

struct ContentView: View {
    @StateObject private var teamStore = TeamStore() // 팀 목록 관리
    @State private var selectedTeam: Team? = nil

    var body: some View {
        TabView {
            // 개인 섹션
            NavigationStack {
                PersonalSectionView()
            }
            .tabItem {
                Image(systemName: "person.crop.circle")
                Text("풋살 기록장")
            }

            // 팀 섹션
            NavigationStack {
                TeamSectionView(selectedTeam: $selectedTeam)
            }
            .tabItem {
                Image(systemName: "person.3.fill")
                Text("우리 팀 매칭룸")
            }
        }
        .environmentObject(teamStore)
    }
}

#Preview {
    ContentView()
}
