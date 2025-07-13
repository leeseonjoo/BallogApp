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
    private let quotes = [
        "노력은 배신하지 않는다. – 일본 야구선수 이치로",
        "오늘 걷지 않으면 내일은 뛰어야 한다. – 독일 속담",
        "성공은 우연이 아니다. 그것은 노력, 끈기, 배움, 희생, 그리고 무엇보다 자신이 하는 일에 대한 사랑이다. – 펠레",
        "남과 비교하지 말고 어제의 나와 비교하라.",
        "변화는 불편함에서 시작된다.",
        "포기하지 않는 한 실패는 없다. – 토마스 에디슨",
        "지금 하는 작은 선택들이 미래의 나를 만든다.",
        "행동 없는 비전은 환상일 뿐이다. – 토니 로빈스",
        "매일 1%씩 나아가라. 1년이면 37배 성장한다. – 제임스 클리어 《Atomic Habits》",
        "당신이 통제할 수 있는 유일한 것은 오늘의 행동이다.",
        "습관이 운명을 만든다.",
        "실패란 더 현명해지기 위한 데이터다.",
        "원하는 결과를 얻으려면, 그에 맞는 사람이 되어야 한다.",
        "아무도 보는 사람이 없을 때의 노력이 진짜 실력을 만든다.",
        "당신이 꿈꾸는 삶을 살고 싶다면, 지금 그 삶에 걸맞은 행동을 하라.",
        "하루하루를 마지막 날처럼 살아라. – 스티브 잡스",
        "준비하는 자에게 기회는 반드시 온다.",
        "나를 힘들게 하는 것이 나를 성장시킨다.",
        "변명보다 행동이 더 많아야 한다.",
        "시작이 반이다. 하지만 끝까지 가야 진짜다."
    ]
    @State private var quote: String = ""
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

    private var competitionEvents: [TeamEvent] {
        eventStore.events.filter { $0.type == .match }.sorted { $0.date < $1.date }
    }

    private var thisWeekEvents: [TeamEvent] {
        eventStore.events.filter {
            calendar.isDate($0.date, equalTo: Date(), toGranularity: .weekOfYear)
        }.sorted { $0.date < $1.date }
    }

    private var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "M월 d일"
        return f
    }

    private var timeFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }

    private func dDay(from date: Date) -> Int {
        let diff = calendar.dateComponents([.day], from: calendar.startOfDay(for: Date()), to: calendar.startOfDay(for: date))
        return diff.day ?? 0
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: Layout.spacing) {
                Spacer(minLength: 60) // 위 여백

                topBar
                quoteSection
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
            .onAppear { quote = quotes.randomElement() ?? "" }
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

    private var quoteSection: some View {
        VStack(spacing: 8) {
            Text(quote)
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
            }
            .padding(.horizontal)

            VStack(alignment: .leading, spacing: 0) {
                if competitionEvents.isEmpty {
                    Text("등록된 일정이 없습니다")
                        .padding(.vertical, 12)
                        .padding(.horizontal)
                } else {
                    ForEach(competitionEvents) { event in
                        Text("- \(dateFormatter.string(from: event.date)) \(event.title) | D-day \(dDay(from: event.date))")
                            .padding(.vertical, 12)
                            .padding(.horizontal)
                        if event.id != competitionEvents.last?.id {
                            Divider()
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private var thisWeekScheduleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("이번주 일정")
                    .font(.title2.bold())
                Spacer()
            }
            .padding(.horizontal)

            VStack(alignment: .leading, spacing: 0) {
                if thisWeekEvents.isEmpty {
                    Text("등록된 일정이 없습니다")
                        .padding(.vertical, 12)
                        .padding(.horizontal)
                } else {
                    ForEach(thisWeekEvents) { event in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("- \(timeFormatter.string(from: event.date)) | \(event.title)")
                            Text("  장소: \(event.place)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal)
                        if event.id != thisWeekEvents.last?.id {
                            Divider()
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
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
