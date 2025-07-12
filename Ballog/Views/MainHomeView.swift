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
    @State private var selectedDate: String?
    @AppStorage("profileMessage")
    private var profileMessage: String =
        "하나가 되어 정상을 향해가는 순간\n힘들어도 극복하면서 자신있게!! 나아가자!!"
    @AppStorage("profileCard") private var storedCard: String = ""

    private var card: ProfileCard? {
        guard let data = storedCard.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(ProfileCard.self, from: data)
    }

    private var todayString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy M월 d일 EEEE"
        return formatter.string(from: Date())
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: Layout.spacing) {
                Spacer(minLength: 60) // 위 여백

                topBar
                profileMessageSection
                scheduleSection
                thisWeekScheduleSection // 추가된 부분
                if let card = card {
                    ProfileCardView(card: card, showIcon: true, iconOnRight: true, showRecordButton: true)
                }

                Spacer()
            }
            .padding(Layout.padding)
            .background(Color.pageBackground)
            .ignoresSafeArea()
        }
    }

    private var topBar: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                Text("볼로그")
                    .font(.title2.bold())
                Text(todayString)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.leading)

            Spacer()

            NavigationLink(destination: ProfileView()) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 28, height: 28)
            }
            NavigationLink(destination: NotificationView()) {
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
        }
        .padding(.horizontal)
    }

    private var scheduleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("대회 일정")
                    .font(.title2.bold())
                Spacer()
                Button(action: {}) {
                    Image(systemName: "plus")
                }
            }
            .padding(.horizontal)

            VStack(alignment: .leading, spacing: 0) {
                ForEach(scheduleTexts.indices, id: \.self) { index in
                    Text(scheduleTexts[index])
                        .padding(.vertical, 12)
                        .padding(.horizontal)

                    if index != scheduleTexts.count - 1 {
                        Divider()
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private var scheduleTexts: [String] {
        [
            "- 제 2회 리드컵 풋살 대회 | D-day 40",
            "- 제 9회 펜타컵 풋살 대회 | D-day 35"        ]
    }

    private var thisWeekScheduleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("이번주 일정")
                    .font(.title2.bold())
                Spacer()
                Button(action: {}) {
                    Image(systemName: "plus")
                }
            }
            .padding(.horizontal)

            VStack(alignment: .leading, spacing: 0) {
                ForEach(sampleDiaryDay.entries.indices, id: \.self) { index in
                    let entry = sampleDiaryDay.entries[index]

                    VStack(alignment: .leading, spacing: 4) {
                        Text("- \(entry.title) | \(entry.time)")
                        Text("  장소: \(entry.place)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal)

                    if index != sampleDiaryDay.entries.count - 1 {
                        Divider()
                    }
                }
            }
            .padding(.horizontal)
        }
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
    }
}
