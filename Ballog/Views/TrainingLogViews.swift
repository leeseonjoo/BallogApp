import SwiftUI

struct TrainingLogCardView: View {
    let day: Date
    let log: TeamTrainingLog
    private var formatter: DateFormatter {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "M월 d일"
        return f
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(formatter.string(from: day))
                .font(.headline)
            Text(log.summary)
                .font(.caption)
                .foregroundColor(.green)
        }
        .padding()
        .frame(width: 160, height: 100)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
        .shadow(radius: 2)
    }
}

struct TrainingLogDetailView: View {
    let day: Date
    let log: TeamTrainingLog
    private var formatter: DateFormatter {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yyyy년 M월 d일"
        return f
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(formatter.string(from: day))
                .font(.title3)
            Text("전술: \(log.tactic)")
            Text("기술: \(log.skill)")
            Text(log.notes)
                .padding(.top, 8)
            Spacer()
        }
        .padding()
    }
}

#Preview {
    TrainingLogCardView(day: Date(), log: TeamTrainingLog(date: Date(), tactic: "패스", skill: "슛", notes: "메모"))
}
