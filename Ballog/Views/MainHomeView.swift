import SwiftUI

private enum Layout {
    static let spacing = DesignConstants.spacing
    static let padding = DesignConstants.horizontalPadding
}



struct MainHomeView: View {
    @EnvironmentObject private var eventStore: TeamEventStore
    private let calendar = Calendar.current
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
            ScrollView {
                VStack(spacing: DesignConstants.sectionSpacing) {
                    quoteSection
                    
                    // Character Card Section
                    if let card = card {
                        characterCardSection(card: card)
                    }
                    
                    scheduleSection
                    thisWeekScheduleSection
                }
                .padding(DesignConstants.horizontalPadding)
            }
            .background(Color.pageBackground)
            .onAppear { quote = quotes.randomElement() ?? "" }
        }
        .ballogTopBar()
    }

    private var quoteSection: some View {
        VStack(spacing: DesignConstants.smallSpacing) {
            Text(quote)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(Color.secondaryText)
                .padding(DesignConstants.cardPadding)
                .background(
                    RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                        .fill(Color.cardBackground)
                )
        }
    }
    
    private func characterCardSection(card: ProfileCard) -> some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            HStack {
                HStack(spacing: DesignConstants.smallSpacing) {
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(Color.primaryBlue)
                    Text("내 캐릭터")
                        .font(.title2.bold())
                        .foregroundColor(Color.primaryText)
                }
                Spacer()
            }
            
            ProfileCardView(card: card, showIcon: true, iconOnRight: true, showRecordButton: true)
        }
    }

    private var scheduleSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            HStack {
                Text("대회 일정")
                    .font(.title2.bold())
                    .foregroundColor(Color.primaryText)
                Spacer()
            }

            VStack(alignment: .leading, spacing: 0) {
                if competitionEvents.isEmpty {
                    Text("등록된 일정이 없습니다")
                        .foregroundColor(Color.secondaryText)
                        .padding(DesignConstants.cardPadding)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    ForEach(competitionEvents) { event in
                        VStack(alignment: .leading, spacing: DesignConstants.smallSpacing) {
                            HStack {
                                Text("\(dateFormatter.string(from: event.date)) \(event.title)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(Color.primaryText)
                                Spacer()
                                Text("D-day \(dDay(from: event.date))")
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: DesignConstants.smallCornerRadius)
                                            .fill(Color.primaryBlue.opacity(0.1))
                                    )
                                    .foregroundColor(Color.primaryBlue)
                            }
                        }
                        .padding(DesignConstants.cardPadding)
                        .background(
                            RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                                .fill(Color.cardBackground)
                        )
                        
                        if event.id != competitionEvents.last?.id {
                            Divider()
                                .padding(.vertical, DesignConstants.smallSpacing)
                        }
                    }
                }
            }
        }
    }

    private var thisWeekScheduleSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            HStack {
                Text("이번주 일정")
                    .font(.title2.bold())
                    .foregroundColor(Color.primaryText)
                Spacer()
            }

            VStack(alignment: .leading, spacing: 0) {
                if thisWeekEvents.isEmpty {
                    Text("등록된 일정이 없습니다")
                        .foregroundColor(Color.secondaryText)
                        .padding(DesignConstants.cardPadding)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    ForEach(thisWeekEvents) { event in
                        VStack(alignment: .leading, spacing: DesignConstants.smallSpacing) {
                            HStack {
                                Text("\(timeFormatter.string(from: event.date)) | \(event.title)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(Color.primaryText)
                                Spacer()
                            }
                            Text("장소: \(event.place)")
                                .font(.caption)
                                .foregroundColor(Color.secondaryText)
                        }
                        .padding(DesignConstants.cardPadding)
                        .background(
                            RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                                .fill(Color.cardBackground)
                        )
                        
                        if event.id != thisWeekEvents.last?.id {
                            Divider()
                                .padding(.vertical, DesignConstants.smallSpacing)
                        }
                    }
                }
            }
        }
    }
}


