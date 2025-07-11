import SwiftUI

private enum Layout {
    static let spacing = DesignConstants.spacing
    static let padding = DesignConstants.horizontalPadding
}

struct DiaryEntry: Identifiable {
    let id = UUID()
    let color: Color
    let time: String
    let title: String
    let place: String
}

struct DiaryDay {
    let date: String
    let entries: [DiaryEntry]
}

struct MainHomeView: View {
    @StateObject private var progressModel = SkillProgressModel()
    @State private var selectedDate: String?
    @AppStorage("profileMessage")
    private var profileMessage: String =
        "하나가 되어 정상을 향해가는 순간\n힘들어도 극복하면서 자신있게!! 나아가자!!"

    private var todayString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy M월 d일 EEEE"
        return formatter.string(from: Date())
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: Layout.spacing) {
                topBar
                profileMessageSection
                scheduleSection
                DiaryDayView(day: sampleDiaryDay)
                    .padding(.horizontal)
                PixelTreeView(model: progressModel)
                    .padding(Layout.padding)
                Spacer()
            }
            .padding(Layout.padding)
            .background(Color.pageBackground)
            .ignoresSafeArea()
        }
    }

    private var topBar: some View {
        HStack(spacing: 16) {
            Text("볼터치")
                .font(.title2.bold())
                .padding(.leading)

            Spacer()

            NavigationLink(destination: ProfileView()) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 28, height: 28)
            }
            Button(action: {}) {
                Image(systemName: "bell")
                    .resizable()
                    .frame(width: 24, height: 24)
            }
            NavigationLink(destination: SettingsView()) {
                Image(systemName: "gearshape")
                    .resizable()
                    .frame(width: 24, height: 24)
            }
        }
        .padding(.vertical, 8)
    }

    private var profileMessageSection: some View {
        VStack(spacing: 8) {
            Text(profileMessage)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue)
                }
            NavigationLink("수정") { ProfileView() }
                .font(.caption)
        }
        .padding(.horizontal)
    }

    private var scheduleSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("캘린더")
                    .font(.title2.bold())
                Spacer()
                Button(action: {}) {
                    Image(systemName: "plus")
                }
            }
            .padding(.vertical, 12)
            VStack(alignment: .leading, spacing: 4) {
                Text("- 제 2회 리드컵 풋살 대회 | D-day 40")
                Text("- 제 9회 펜타컵 풋살 대회 | D-day 35")
                Text("- [일정을 등록하세요]")
            }
            .font(.subheadline)
        }
        .padding(.horizontal)
    }

    private var sampleDiaryDay: DiaryDay {
        DiaryDay(
            date: "06 (화)",
            entries: [
                DiaryEntry(
                    color: .green,
                    time: "12:00 - 12:12",
                    title: "해그래 운동",
                    place: "서수원풋살장"
                )
            ]
        )
    }
}

struct DiaryDayView: View {
    let day: DiaryDay

    var body: some View {
        HStack(alignment: .top) {
            Text(day.date)
                .font(.headline)
                .frame(width: 60, alignment: .leading)

            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(day.entries.enumerated()), id: \.offset) { index, entry in
                    HStack(alignment: .top, spacing: 8) {
                        Rectangle()
                            .fill(entry.color)
                            .frame(width: 10, height: 10)
                            .cornerRadius(2)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("시간: \(entry.time)")
                            Text("제목: \(entry.title)")
                            if !entry.place.isEmpty {
                                Text("장소: \(entry.place)")
                            }
                        }
                        Spacer()
                    }
                    if index != day.entries.count - 1 {
                        Divider()
                    }
                }
            }
        }
        .padding(Layout.padding)
        .background {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray)
        }
    }
}
