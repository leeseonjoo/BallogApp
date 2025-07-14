import SwiftUI

struct PersonalSectionView: View {
    @State private var selectedTab = 0
    var body: some View {
        let personalTrainingStore = PersonalTrainingStore()
        TabView(selection: $selectedTab) {
            MainHomeView()
                .environmentObject(personalTrainingStore)
                .tabItem { Label("홈", systemImage: "house") }
                .tag(0)
            PersonalTrainingView()
                .environmentObject(personalTrainingStore)
                .tabItem { Label("훈련", systemImage: "figure.walk") }
                .tag(1)
            PersonalGoalListView()
                .tabItem { Label("목표", systemImage: "target") }
                .tag(2)
            TrainingStatisticsView()
                .environmentObject(personalTrainingStore)
                .tabItem { Label("통계", systemImage: "chart.bar") }
                .tag(3)
            ProfileView()
                .tabItem { Label("내 정보", systemImage: "person") }
                .tag(4)
        }
    }
} 