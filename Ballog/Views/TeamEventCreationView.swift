import SwiftUI

struct TeamEventCreationView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var eventStore: TeamEventStore
    
    @State private var title = ""
    @State private var selectedDate = Date()
    @State private var place = ""
    @State private var selectedEventType: TeamEvent.EventType = .training
    @State private var selectedTrainingType: TeamEvent.TrainingType = .technical
    @State private var isRecurring = false
    @State private var selectedWeekday = 2 // 월요일
    @State private var endDate = Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date()
    
    // 매치 관련
    @State private var opponent = ""
    @State private var matchType = ""
    
    // 대회 관련
    @State private var tournamentName = ""
    @State private var tournamentRound = ""
    
    // 기타
    @State private var notes = ""
    
    private let weekdays = [
        (1, "일요일"), (2, "월요일"), (3, "화요일"), (4, "수요일"),
        (5, "목요일"), (6, "금요일"), (7, "토요일")
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                // 기본 정보
                Section("기본 정보") {
                    TextField("일정 제목", text: $title)
                    
                    DatePicker("날짜", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                    
                    TextField("장소 (풋살장 이름)", text: $place)
                }
                
                // 일정 타입
                Section("일정 타입") {
                    Picker("타입", selection: $selectedEventType) {
                        ForEach(TeamEvent.EventType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // 훈련 타입 (훈련이나 정기훈련일 때만)
                if selectedEventType == .training || selectedEventType == .regularTraining {
                    Section("훈련 종류") {
                        Picker("훈련 종류", selection: $selectedTrainingType) {
                            ForEach(TeamEvent.TrainingType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                
                // 정기 훈련 설정
                if selectedEventType == .regularTraining {
                    Section("반복 설정") {
                        Toggle("매주 반복", isOn: $isRecurring)
                        
                        if isRecurring {
                            Picker("요일", selection: $selectedWeekday) {
                                ForEach(weekdays, id: \.0) { weekday in
                                    Text(weekday.1).tag(weekday.0)
                                }
                            }
                            .pickerStyle(.menu)
                            
                            DatePicker("종료일", selection: $endDate, displayedComponents: .date)
                        }
                    }
                }
                
                // 매치 정보
                if selectedEventType == .match {
                    Section("매치 정보") {
                        TextField("상대팀", text: $opponent)
                        TextField("경기 종류", text: $matchType)
                    }
                }
                
                // 대회 정보
                if selectedEventType == .tournament {
                    Section("대회 정보") {
                        TextField("대회명", text: $tournamentName)
                        TextField("라운드", text: $tournamentRound)
                    }
                }
                
                // 메모
                Section("메모") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("팀 일정 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장") {
                        saveEvent()
                    }
                    .disabled(title.isEmpty || place.isEmpty)
                }
            }
        }
    }
    
    private func saveEvent() {
        var event: TeamEvent
        
        switch selectedEventType {
        case .training:
            event = TeamEvent(
                title: title,
                date: selectedDate,
                place: place,
                type: .training,
                opponent: nil,
                matchType: nil
            )
            event.trainingType = selectedTrainingType
            event.notes = notes
            
        case .regularTraining:
            if isRecurring {
                event = TeamEvent(
                    title: title,
                    date: selectedDate,
                    place: place,
                    trainingType: selectedTrainingType,
                    recurringWeekday: selectedWeekday,
                    endDate: endDate
                )
                event.notes = notes
                eventStore.createRecurringEvents(event)
            } else {
                event = TeamEvent(
                    title: title,
                    date: selectedDate,
                    place: place,
                    type: .training,
                    opponent: nil,
                    matchType: nil
                )
                event.trainingType = selectedTrainingType
                event.notes = notes
            }
            
        case .match:
            event = TeamEvent(
                title: title,
                date: selectedDate,
                place: place,
                type: .match,
                opponent: opponent.isEmpty ? nil : opponent,
                matchType: matchType.isEmpty ? nil : matchType
            )
            event.notes = notes
            
        case .tournament:
            event = TeamEvent(
                title: title,
                date: selectedDate,
                place: place,
                tournamentName: tournamentName,
                tournamentRound: tournamentRound.isEmpty ? nil : tournamentRound
            )
            event.notes = notes
        }
        
        eventStore.addEvent(event)
        dismiss()
    }
}

#Preview {
    TeamEventCreationView()
        .environmentObject(TeamEventStore())
} 