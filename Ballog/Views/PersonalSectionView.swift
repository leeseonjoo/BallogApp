import SwiftUI

struct PersonalSectionView: View {
    @State private var selectedTab = 0
    var body: some View {
        let personalTrainingStore = PersonalTrainingStore()
        Group {
            if selectedTab == 0 {
                MainHomeView(selectedTab: $selectedTab)
                    .environmentObject(personalTrainingStore)
            } else if selectedTab == 1 {
                FeedView()
            } else if selectedTab == 2 {
                PersonalGoalListView()
            } // 필요시 추가 탭
        }
    }
} 