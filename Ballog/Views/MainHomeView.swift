import SwiftUI

struct MainHomeView: View {
    @StateObject private var progressModel = SkillProgressModel()
    @State private var selectedDate: String? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {

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

                // 요일 패스 상태 박스
                HStack(spacing: 16) {
                    ForEach(["월", "화", "수", "목", "금"], id: \.self) { day in
                        VStack {
                            Text(day)
                                .font(.subheadline)
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                                .frame(width: 50, height: 50)
                                .overlay(Text("패스").font(.caption))
                        }
                    }
                }
                .padding(.horizontal)

                // 일지 리스트
                let days = ["월", "화", "수", "목"]
                VStack(alignment: .leading, spacing: 8) {
                    Text("일지 리스트")
                        .font(.headline)

                    ForEach(1..<5) { idx in
                        Button(action: {
                            selectedDate = "7월 8일"
                        }) {
                            HStack {
                                Text("\(idx) 8일 \(days[idx-1]) 맑음 서수원풋살장")
                                Spacer()
                                if idx == 1 {
                                    Text("click")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .padding(.horizontal)

                // 픽셀 트리 뷰
                PixelTreeView(model: progressModel)
                    .padding()

                Spacer()

                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
            }
        }

#Preview {
    MainHomeView()
}
