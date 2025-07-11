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
    @State private var selectedDate: String? = nil
    private var todayString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy M월 d일 EEEE"
        return formatter.string(from: Date())
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: Layout.spacing) {
                
                // 상단 바
                HStack {
                    Text("볼터치")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.leading)

                    Spacer()

                    Button(action: {}) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 32, height: 32)
                            .padding(.trailing)
                    }
                }
                .padding(.vertical, 8)

                // 상단 메시지
                VStack(spacing: 6) {
                    Text("LET’S GO D-40")
                        .font(.title)
                        .bold()
                    Text("하나가 되어 정상을 향해가는 순간\n힘들어도 극복하면서 자신있게!! 나아가자!!")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal)

                    HStack(spacing: 16) {
                        ForEach(["월", "화", "수", "목", "금"], id: \.self) { day in
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                                .frame(width: 50, height: 50)
                                .overlay(Text(day).font(.subheadline))
                        }
                    }
                    .padding(.vertical, 12)
                }
                .padding(.horizontal)

                // 일지 리스트
                let diaryDay = DiaryDay(
                    date: "06 (화)",
                    entries: [
                        DiaryEntry(color: .green, time: "12:00 - 12:12", title: "Temp – Adventure racing", place: "Aardla, Tartu, Eesti"),
                        DiaryEntry(color: .green, time: "14:00 - 15:00", title: "777 – Adaptive rowing", place: ""),
                        DiaryEntry(color: .blue, time: "13:00 - 15:00", title: "U19 – Football (soccer)", place: "Annelinna Kunstmuruväljak")
                    ]
                )

                DiaryDayView(day: diaryDay)
                    .padding(.horizontal)

                // 픽셀 트리 뷰
                PixelTreeView(model: progressModel)
                    .padding(Layout.padding)

                Spacer()
            }
            .padding(Layout.padding)
            .background(Color.pageBackground)
            .ignoresSafeArea()
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
        .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))
    }
}

#Preview {
    MainHomeView()
}

