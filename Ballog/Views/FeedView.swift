import SwiftUI

/// 피드 탭은 현재 준비 중이다.
struct FeedView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignConstants.sectionSpacing) {
                    // Coming Soon Section
                    comingSoonSection
                    
                    // Feature Preview Section
                    featurePreviewSection
                }
                .padding(DesignConstants.horizontalPadding)
            }
            .background(Color.pageBackground)
        }
        .ballogTopBar()
    }
    
    private var comingSoonSection: some View {
        VStack(spacing: DesignConstants.largeSpacing) {
            Image(systemName: "newspaper")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(Color.primaryBlue)
            
            VStack(spacing: DesignConstants.smallSpacing) {
                Text("피드 준비 중")
                    .font(.title.bold())
                    .foregroundColor(Color.primaryText)
                
                Text("곧 팀원들과 소통할 수 있는 피드가 준비됩니다")
                    .font(.subheadline)
                    .foregroundColor(Color.secondaryText)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(DesignConstants.largePadding)
        .background(
            RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                .fill(Color.cardBackground)
        )
    }
    
    private var featurePreviewSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            Text("예정된 기능")
                .font(.title2.bold())
                .foregroundColor(Color.primaryText)
            
            VStack(spacing: DesignConstants.smallSpacing) {
                FeaturePreviewItem(
                    icon: "message.circle",
                    title: "팀 소통",
                    description: "팀원들과 실시간으로 소통하세요"
                )
                
                FeaturePreviewItem(
                    icon: "photo",
                    title: "훈련 사진",
                    description: "훈련 모습을 공유하고 기록하세요"
                )
                
                FeaturePreviewItem(
                    icon: "chart.bar",
                    title: "성과 공유",
                    description: "개인과 팀의 성과를 공유하세요"
                )
            }
        }
    }
}

struct FeaturePreviewItem: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: DesignConstants.spacing) {
            Image(systemName: icon)
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(Color.primaryBlue)
                .padding(DesignConstants.smallPadding)
                .background(
                    Circle()
                        .fill(Color.primaryBlue.opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color.primaryText)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(Color.secondaryText)
            }
            
            Spacer()
        }
        .padding(DesignConstants.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                .fill(Color.cardBackground)
        )
    }
}

#Preview {
    FeedView()
}
