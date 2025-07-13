import SwiftUI
import PhotosUI

// 팀 가용성 조사 뷰
struct TeamAvailabilitySurveyView: View {
    let team: Team
    @EnvironmentObject private var matchMatchingStore: MatchMatchingStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    @State private var availableDates: Set<Int> = []
    @State private var preferredTimes: Set<String> = []
    @State private var notes = ""
    
    private let months = Array(1...12)
    private let years = Array(2024...2025)
    private let timeSlots = ["오전", "오후", "저녁"]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignConstants.sectionSpacing) {
                    // Month/Year Selection
                    VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
                        Text("조사할 월 선택")
                            .font(.headline)
                            .foregroundColor(Color.primaryText)
                        
                        HStack {
                            Picker("월", selection: $selectedMonth) {
                                ForEach(months, id: \.self) { month in
                                    Text("\(month)월").tag(month)
                                }
                            }
                            .pickerStyle(.menu)
                            
                            Picker("년도", selection: $selectedYear) {
                                ForEach(years, id: \.self) { year in
                                    Text("\(year)년").tag(year)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                    }
                    
                    // Available Dates
                    VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
                        Text("가능한 날짜 선택")
                            .font(.headline)
                            .foregroundColor(Color.primaryText)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                            ForEach(1...31, id: \.self) { day in
                                Button(action: {
                                    if availableDates.contains(day) {
                                        availableDates.remove(day)
                                    } else {
                                        availableDates.insert(day)
                                    }
                                }) {
                                    Text("\(day)")
                                        .font(.caption)
                                        .frame(width: 30, height: 30)
                                        .background(
                                            Circle()
                                                .fill(availableDates.contains(day) ? Color.primaryBlue : Color.cardBackground)
                                        )
                                        .foregroundColor(availableDates.contains(day) ? .white : Color.primaryText)
                                }
                            }
                        }
                    }
                    
                    // Preferred Times
                    VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
                        Text("선호하는 시간대")
                            .font(.headline)
                            .foregroundColor(Color.primaryText)
                        
                        HStack(spacing: DesignConstants.smallSpacing) {
                            ForEach(timeSlots, id: \.self) { time in
                                Button(action: {
                                    if preferredTimes.contains(time) {
                                        preferredTimes.remove(time)
                                    } else {
                                        preferredTimes.insert(time)
                                    }
                                }) {
                                    Text(time)
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: DesignConstants.smallCornerRadius)
                                                .fill(preferredTimes.contains(time) ? Color.primaryBlue : Color.cardBackground)
                                        )
                                        .foregroundColor(preferredTimes.contains(time) ? .white : Color.primaryText)
                                }
                            }
                        }
                    }
                    
                    // Notes
                    VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
                        Text("추가 메모")
                            .font(.headline)
                            .foregroundColor(Color.primaryText)
                        
                        TextEditor(text: $notes)
                            .frame(height: 100)
                            .padding(DesignConstants.cardPadding)
                            .background(
                                RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                                    .fill(Color.cardBackground)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                                    .stroke(Color.borderColor, lineWidth: 1)
                            )
                    }
                }
                .padding(DesignConstants.horizontalPadding)
            }
            .navigationTitle("가용성 조사")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장") {
                        saveAvailability()
                    }
                    .disabled(availableDates.isEmpty)
                }
            }
        }
    }
    
    private func saveAvailability() {
        let availability = TeamAvailability(
            teamId: team.id.uuidString,
            month: selectedMonth,
            year: selectedYear,
            availableDates: Array(availableDates),
            preferredTimes: Array(preferredTimes),
            notes: notes.isEmpty ? nil : notes
        )
        matchMatchingStore.updateTeamAvailability(availability)
        dismiss()
    }
}

// 매치 요청 생성 뷰
struct CreateMatchRequestView: View {
    let team: Team
    @EnvironmentObject private var matchMatchingStore: MatchMatchingStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var preferredDate = Date()
    @State private var alternativeDates: [Date] = []
    @State private var location = ""
    @State private var fieldFee = ""
    @State private var teamLevel: TeamLevel = .intermediate
    @State private var expectedPlayers = ""
    @State private var maxPlayers = ""
    @State private var contactInfo = ""
    @State private var showDatePicker = false
    @State private var selectedDateForAlternative = Date()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignConstants.sectionSpacing) {
                    // Basic Info
                    VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
                        Text("매치 정보")
                            .font(.headline)
                            .foregroundColor(Color.primaryText)
                        
                        VStack(spacing: DesignConstants.smallSpacing) {
                            TextField("매치 제목", text: $title)
                                .textFieldStyle(.roundedBorder)
                            
                            TextEditor(text: $description)
                                .frame(height: 100)
                                .padding(DesignConstants.cardPadding)
                                .background(
                                    RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                                        .fill(Color.cardBackground)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                                        .stroke(Color.borderColor, lineWidth: 1)
                                )
                        }
                    }
                    
                    // Date and Location
                    VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
                        Text("일정 및 장소")
                            .font(.headline)
                            .foregroundColor(Color.primaryText)
                        
                        VStack(spacing: DesignConstants.smallSpacing) {
                            DatePicker("희망 날짜", selection: $preferredDate, displayedComponents: [.date])
                            
                            TextField("장소", text: $location)
                                .textFieldStyle(.roundedBorder)
                            
                            TextField("구장비 (원)", text: $fieldFee)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.numberPad)
                        }
                    }
                    
                    // Team Info
                    VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
                        Text("팀 정보")
                            .font(.headline)
                            .foregroundColor(Color.primaryText)
                        
                        VStack(spacing: DesignConstants.smallSpacing) {
                            Picker("팀 실력", selection: $teamLevel) {
                                ForEach(TeamLevel.allCases, id: \.self) { level in
                                    Text(level.rawValue).tag(level)
                                }
                            }
                            .pickerStyle(.menu)
                            
                            TextField("예상 참석 인원", text: $expectedPlayers)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.numberPad)
                            
                            TextField("최대 인원", text: $maxPlayers)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.numberPad)
                            
                            TextField("연락처", text: $contactInfo)
                                .textFieldStyle(.roundedBorder)
                        }
                    }
                }
                .padding(DesignConstants.horizontalPadding)
            }
            .navigationTitle("매치 요청")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("게시") {
                        createMatchRequest()
                    }
                    .disabled(title.isEmpty || location.isEmpty || expectedPlayers.isEmpty)
                }
            }
        }
    }
    
    private func createMatchRequest() {
        let request = MatchRequest(
            teamId: team.id.uuidString,
            teamName: team.name,
            teamLogo: team.logo,
            title: title,
            description: description,
            preferredDate: preferredDate,
            alternativeDates: alternativeDates,
            location: location,
            fieldFee: Int(fieldFee) ?? 0,
            teamLevel: teamLevel,
            expectedPlayers: Int(expectedPlayers) ?? 0,
            maxPlayers: Int(maxPlayers) ?? 0,
            contactInfo: contactInfo
        )
        matchMatchingStore.addMatchRequest(request)
        dismiss()
    }
}

// 매치 신청 뷰
struct MatchApplicationView: View {
    let matchRequest: MatchRequest
    let team: Team
    @EnvironmentObject private var matchMatchingStore: MatchMatchingStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var message = ""
    @State private var expectedPlayers = ""
    @State private var showLevelWarning = false
    @State private var levelDifference: Int = 0
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignConstants.sectionSpacing) {
                    // Match Info
                    VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
                        Text("매치 정보")
                            .font(.headline)
                            .foregroundColor(Color.primaryText)
                        
                        VStack(spacing: DesignConstants.smallSpacing) {
                            HStack {
                                if let logoData = matchRequest.teamLogo, let uiImage = UIImage(data: logoData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 40, height: 40)
                                        .clipShape(Circle())
                                } else {
                                    Image(systemName: "person.3.fill")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(Color.secondaryText)
                                }
                                
                                VStack(alignment: .leading) {
                                    Text(matchRequest.teamName)
                                        .font(.headline)
                                    Text(matchRequest.title)
                                        .font(.subheadline)
                                        .foregroundColor(Color.secondaryText)
                                }
                                
                                Spacer()
                            }
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("희망 날짜")
                                        .font(.caption)
                                        .foregroundColor(Color.secondaryText)
                                    Text(matchRequest.preferredDate, style: .date)
                                        .font(.subheadline)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing) {
                                    Text("장소")
                                        .font(.caption)
                                        .foregroundColor(Color.secondaryText)
                                    Text(matchRequest.location)
                                        .font(.subheadline)
                                }
                            }
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("구장비")
                                        .font(.caption)
                                        .foregroundColor(Color.secondaryText)
                                    Text("\(matchRequest.fieldFee)원")
                                        .font(.subheadline)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing) {
                                    Text("팀 실력")
                                        .font(.caption)
                                        .foregroundColor(Color.secondaryText)
                                    Text(matchRequest.teamLevel.rawValue)
                                        .font(.subheadline)
                                        .foregroundColor(matchRequest.teamLevel.color)
                                }
                            }
                        }
                        .padding(DesignConstants.cardPadding)
                        .background(
                            RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                                .fill(Color.cardBackground)
                        )
                    }
                    
                    // Application Form
                    VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
                        Text("신청 정보")
                            .font(.headline)
                            .foregroundColor(Color.primaryText)
                        
                        VStack(spacing: DesignConstants.smallSpacing) {
                            TextField("예상 참석 인원", text: $expectedPlayers)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.numberPad)
                            
                            TextEditor(text: $message)
                                .frame(height: 100)
                                .padding(DesignConstants.cardPadding)
                                .background(
                                    RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                                        .fill(Color.cardBackground)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                                        .stroke(Color.borderColor, lineWidth: 1)
                                )
                        }
                    }
                    
                    // Level Warning
                    if showLevelWarning {
                        VStack(alignment: .leading, spacing: DesignConstants.smallSpacing) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(Color.primaryOrange)
                                Text("실력 차이 주의")
                                    .font(.headline)
                                    .foregroundColor(Color.primaryOrange)
                            }
                            
                            Text("두 팀의 실력 차이가 \(levelDifference)단계입니다. 매치를 진행하시겠습니까?")
                                .font(.subheadline)
                                .foregroundColor(Color.secondaryText)
                        }
                        .padding(DesignConstants.cardPadding)
                        .background(
                            RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                                .fill(Color.primaryOrange.opacity(0.1))
                        )
                    }
                }
                .padding(DesignConstants.horizontalPadding)
            }
            .navigationTitle("매치 신청")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("신청") {
                        applyToMatch()
                    }
                    .disabled(expectedPlayers.isEmpty)
                }
            }
            .onAppear {
                checkLevelDifference()
            }
        }
    }
    
    private func checkLevelDifference() {
        levelDifference = matchMatchingStore.calculateLevelDifference(
            level1: matchRequest.teamLevel,
            level2: .intermediate // Assuming current team level
        )
        showLevelWarning = matchMatchingStore.isSignificantLevelDifference(
            level1: matchRequest.teamLevel,
            level2: .intermediate
        )
    }
    
    private func applyToMatch() {
        let application = MatchApplication(
            teamId: team.id.uuidString,
            teamName: team.name,
            teamLogo: team.logo,
            teamLevel: .intermediate, // Assuming current team level
            expectedPlayers: Int(expectedPlayers) ?? 0,
            contactInfo: "연락처 정보",
            message: message
        )
        matchMatchingStore.applyToMatch(requestId: matchRequest.id, application: application)
        dismiss()
    }
}

#Preview {
    CreateMatchRequestView(team: Team(name: "테스트 팀"))
        .environmentObject(MatchMatchingStore())
} 