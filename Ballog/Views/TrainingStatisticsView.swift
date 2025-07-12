import SwiftUI

struct TrainingStatisticsView: View {
    // "StatItem" is referenced by "StatChartSection" which is defined below
    // the enclosing view. The "private" access level restricts usage to this
    // type only, leading to a compilation error. Use "fileprivate" so that
    // the helper view in the same file can access it while keeping it internal
    // to this file.
    fileprivate struct StatItem: Identifiable {
        let id = UUID()
        let label: String
        let value: Double
    }

    private let totalCount = [StatItem(label: "2025", value: 20)]
    private let skills = [
        StatItem(label: "패스", value: 5),
        StatItem(label: "슛", value: 3),
        StatItem(label: "드리블", value: 4)
    ]
    private let totalTime = [StatItem(label: "시간", value: 15)]
    private let types = [
        StatItem(label: "개인", value: 6),
        StatItem(label: "팀", value: 4),
        StatItem(label: "경기", value: 2)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: DesignConstants.spacing) {
                StatChartSection(title: "총 횟수", data: totalCount)
                StatChartSection(title: "기술별", data: skills)
                StatChartSection(title: "총 시간", data: totalTime)
                StatChartSection(title: "유형별", data: types)
            }
            .padding()
        }
        .navigationTitle("훈련 통계")
    }
}

private struct StatChartSection: View {
    let title: String
    let data: [TrainingStatisticsView.StatItem]

    private var maxValue: Double { data.map { $0.value }.max() ?? 1 }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            ForEach(data) { item in
                HStack {
                    Text(item.label)
                        .frame(width: 60, alignment: .leading)
                    GeometryReader { geo in
                        Rectangle()
                            .fill(Color.blue)
                            .frame(width: geo.size.width * item.value / maxValue, height: 8)
                            .cornerRadius(4)
                    }
                }
                .frame(height: 16)
            }
        }
    }
}

#Preview {
    TrainingStatisticsView()
}
