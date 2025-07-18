import SwiftUI

struct MatchManagementView: View {
    @EnvironmentObject private var attendanceStore: AttendanceStore
    @EnvironmentObject private var eventStore: TeamEventStore
    @State private var showCreateMatch = false
    @State private var showMatchDetail = false
    @State private var selectedMatch: TeamEvent?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignConstants.sectionSpacing) {
                    // Upcoming Matches Section
                    upcomingMatchesSection
                    
                    // Past Matches Section
                    pastMatchesSection
                    
                    // Statistics Section
                    matchStatisticsSection
                }
                .padding(DesignConstants.horizontalPadding)
            }
            .background(Color.pageBackground)
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showCreateMatch) {
                CreateMatchView { newMatch in
                    eventStore.addEvent(newMatch)
                }
            }
            .sheet(item: $selectedMatch) { matchEvent in
                MatchDetailView(matchEvent: matchEvent)
            }
        }
        .ballogTopBar(selectedTab: .constant(0))
    }
    

    
    private var upcomingMatchesSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            HStack {
                Text("예정된 매치")
                    .font(.title2.bold())
                    .foregroundColor(Color.primaryText)
                Spacer()
                HStack(spacing: 8) {
                    Text("\(upcomingMatches.count)개")
                        .font(.caption)
                        .foregroundColor(Color.secondaryText)
                    Button(action: { showCreateMatch = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Color.primaryBlue)
                            .font(.title2)
                    }
                }
            }
            
            if upcomingMatches.isEmpty {
                emptyMatchesView("예정된 매치가 없습니다", "새로운 매치를 등록해보세요")
            } else {
                VStack(spacing: DesignConstants.smallSpacing) {
                    ForEach(upcomingMatches) { matchEvent in
                        MatchCard(matchEvent: matchEvent) {
                            selectedMatch = matchEvent
                        }
                    }
                }
            }
        }
    }
    
    private var pastMatchesSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            HStack {
                Text("지난 매치")
                    .font(.title2.bold())
                    .foregroundColor(Color.primaryText)
                Spacer()
                HStack(spacing: 8) {
                    Text("\(pastMatches.count)개")
                        .font(.caption)
                        .foregroundColor(Color.secondaryText)
                    Button(action: { showCreateMatch = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Color.primaryBlue)
                            .font(.title2)
                    }
                }
            }
            
            if pastMatches.isEmpty {
                emptyMatchesView("지난 매치가 없습니다", "매치 기록을 확인해보세요")
            } else {
                VStack(spacing: DesignConstants.smallSpacing) {
                    ForEach(pastMatches) { matchEvent in
                        PastMatchCard(matchEvent: matchEvent) {
                            selectedMatch = matchEvent
                        }
                    }
                }
            }
        }
    }
    
    private var matchStatisticsSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            HStack {
                Text("매치 통계")
                    .font(.title2.bold())
                    .foregroundColor(Color.primaryText)
                Spacer()
                Button(action: { showCreateMatch = true }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(Color.primaryBlue)
                        .font(.title2)
                }
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: DesignConstants.spacing) {
                MatchStatCard(
                    title: "총 매치",
                    value: "\(allMatches.count)",
                    icon: "sportscourt",
                    color: Color.primaryBlue
                )
                
                MatchStatCard(
                    title: "승률",
                    value: "\(winRate)%",
                    icon: "trophy",
                    color: Color.primaryOrange
                )
                
                MatchStatCard(
                    title: "평균 득점",
                    value: "\(averageGoals)",
                    icon: "soccer.ball.inverse",
                    color: Color.primaryGreen
                )
                
                MatchStatCard(
                    title: "평균 실점",
                    value: "\(averageConceded)",
                    icon: "shield",
                    color: Color.primaryRed
                )
            }
            
            // Recent Performance Chart
            VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
                Text("최근 성과")
                    .font(.headline)
                    .foregroundColor(Color.primaryText)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DesignConstants.spacing) {
                        ForEach(recentMatches.prefix(5), id: \.id) { matchEvent in
                            PerformanceCard(matchEvent: matchEvent)
                        }
                    }
                    .padding(.horizontal, DesignConstants.horizontalPadding)
                }
            }
        }
    }
    
    private func emptyMatchesView(_ title: String, _ subtitle: String) -> some View {
        VStack(spacing: DesignConstants.largeSpacing) {
            Image(systemName: "sportscourt")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundColor(Color.secondaryText)
            
            VStack(spacing: DesignConstants.smallSpacing) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(Color.primaryText)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(Color.secondaryText)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(DesignConstants.largePadding)
        .background(
            RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                .fill(Color.cardBackground)
        )
    }
    
    // MARK: - Computed Properties
    
    private var allMatches: [TeamEvent] {
        eventStore.events.filter { $0.type == .match }
    }
    
    private var upcomingMatches: [TeamEvent] {
        allMatches.filter { $0.date > Date() }.sorted { $0.date < $1.date }
    }
    
    private var pastMatches: [TeamEvent] {
        allMatches.filter { $0.date <= Date() }.sorted { $0.date > $1.date }
    }
    
    private var recentMatches: [TeamEvent] {
        pastMatches.prefix(10).reversed()
    }
    
    private var winRate: Int {
        let wins = pastMatches.filter { $0.result == .win }.count
        return pastMatches.isEmpty ? 0 : Int((Double(wins) / Double(pastMatches.count)) * 100)
    }
    
    private var averageGoals: Double {
        let totalGoals = pastMatches.reduce(0) { $0 + ($1.ourScore ?? 0) }
        return pastMatches.isEmpty ? 0 : Double(totalGoals) / Double(pastMatches.count)
    }
    
    private var averageConceded: Double {
        let totalConceded = pastMatches.reduce(0) { $0 + ($1.opponentScore ?? 0) }
        return pastMatches.isEmpty ? 0 : Double(totalConceded) / Double(pastMatches.count)
    }
}



struct MatchCard: View {
    let matchEvent: TeamEvent
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
                onTap()
            }
        }) {
            VStack(alignment: .leading, spacing: DesignConstants.smallSpacing) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(matchEvent.title)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.primaryText)
                        
                        Text(matchEvent.place)
                            .font(.subheadline)
                            .foregroundColor(Color.secondaryText)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(matchEvent.date, style: .date)
                            .font(.caption)
                            .foregroundColor(Color.secondaryText)
                        
                        Text(matchEvent.date, style: .time)
                            .font(.caption)
                            .foregroundColor(Color.secondaryText)
                    }
                }
                
                HStack {
                    Label("D-day \(daysUntilMatch)", systemImage: "calendar")
                        .font(.caption)
                        .foregroundColor(daysUntilMatch <= 3 ? Color.primaryOrange : Color.secondaryText)
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Button("참석") {
                            // 참석 처리
                        }
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.successColor)
                        .foregroundColor(.white)
                        .cornerRadius(DesignConstants.smallCornerRadius)
                        
                        Button("불참") {
                            // 불참 처리
                        }
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.errorColor)
                        .foregroundColor(.white)
                        .cornerRadius(DesignConstants.smallCornerRadius)
                    }
                }
            }
            .padding(DesignConstants.cardPadding)
            .background(
                RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                    .fill(Color.cardBackground)
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.98 : 1.0)
    }
    
    private var daysUntilMatch: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: matchEvent.date)
        return components.day ?? 0
    }
}

struct PastMatchCard: View {
    let matchEvent: TeamEvent
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(matchEvent.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Color.primaryText)
                    
                    Text(matchEvent.date, style: .date)
                        .font(.caption)
                        .foregroundColor(Color.secondaryText)
                }
                
                Spacer()
                
                if let ourScore = matchEvent.ourScore, let opponentScore = matchEvent.opponentScore {
                    HStack(spacing: 4) {
                        Text("\(ourScore)")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(Color.primaryText)
                        
                        Text("-")
                            .font(.caption)
                            .foregroundColor(Color.secondaryText)
                        
                        Text("\(opponentScore)")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(Color.primaryText)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: DesignConstants.smallCornerRadius)
                            .fill(matchEvent.result == .win ? Color.successColor.opacity(0.1) : 
                                  matchEvent.result == .loss ? Color.errorColor.opacity(0.1) : Color.secondaryText.opacity(0.1))
                    )
                }
            }
            .padding(DesignConstants.cardPadding)
            .background(
                RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                    .fill(Color.cardBackground)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MatchStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: DesignConstants.smallSpacing) {
            Image(systemName: icon)
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(color)
            
            VStack(spacing: 2) {
                Text(value)
                    .font(.title2.bold())
                    .foregroundColor(Color.primaryText)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(Color.secondaryText)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(DesignConstants.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                .fill(Color.cardBackground)
        )
    }
}

struct PerformanceCard: View {
    let matchEvent: TeamEvent
    
    var body: some View {
        VStack(spacing: DesignConstants.smallSpacing) {
            Text(matchEvent.date, style: .date)
                .font(.caption)
                .foregroundColor(Color.secondaryText)
            
            if let ourScore = matchEvent.ourScore, let opponentScore = matchEvent.opponentScore {
                HStack(spacing: 4) {
                    Text("\(ourScore)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color.primaryText)
                    
                    Text("-")
                        .font(.caption)
                        .foregroundColor(Color.secondaryText)
                    
                    Text("\(opponentScore)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color.primaryText)
                }
            } else {
                Text("미정")
                    .font(.caption)
                    .foregroundColor(Color.secondaryText)
            }
            
            if let result = matchEvent.result {
                Text(result.rawValue)
                    .font(.caption)
                    .foregroundColor(result == .win ? Color.successColor : 
                                   result == .loss ? Color.errorColor : Color.secondaryText)
            }
        }
        .frame(width: 80)
        .padding(DesignConstants.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                .fill(Color.cardBackground)
        )
    }
}

struct CreateMatchView: View {
    let onCreate: (TeamEvent) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var date = Date()
    @State private var place = ""
    @State private var opponent = ""
    @State private var matchType: MatchType = .friendly
    
    enum MatchType: String, CaseIterable {
        case friendly = "친선경기"
        case league = "리그"
        case cup = "컵대회"
        case practice = "연습경기"
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignConstants.sectionSpacing) {
                    VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
                        Text("매치 정보")
                            .font(.title2.bold())
                            .foregroundColor(Color.primaryText)
                        
                        VStack(spacing: DesignConstants.smallSpacing) {
                            TextField("매치 제목", text: $title)
                                .textFieldStyle(.roundedBorder)
                            
                            DatePicker("날짜 및 시간", selection: $date)
                                .datePickerStyle(.compact)
                            
                            TextField("장소", text: $place)
                                .textFieldStyle(.roundedBorder)
                            
                            TextField("상대팀 (선택사항)", text: $opponent)
                                .textFieldStyle(.roundedBorder)
                            
                            Picker("경기 유형", selection: $matchType) {
                                ForEach(MatchType.allCases, id: \.self) { type in
                                    Text(type.rawValue).tag(type)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                    }
                }
                .padding(DesignConstants.horizontalPadding)
            }
            .background(Color.pageBackground)
            .navigationTitle("새 매치")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("생성") {
                        createMatch()
                    }
                    .disabled(title.isEmpty || place.isEmpty)
                }
            }
        }
    }
    
    private func createMatch() {
        let newMatch = TeamEvent(
            title: title,
            date: date,
            place: place,
            type: .match,
            opponent: opponent.isEmpty ? nil : opponent,
            matchType: matchType.rawValue
        )
        onCreate(newMatch)
        dismiss()
    }
}

struct MatchDetailView: View {
    let matchEvent: TeamEvent
    @Environment(\.dismiss) private var dismiss
    @State private var ourScore: Int = 0
    @State private var opponentScore: Int = 0
    @State private var showScoreInput = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignConstants.sectionSpacing) {
                    // Match Info
                    matchInfoSection
                    
                    // Score Section
                    scoreSection
                    
                    // Attendance Section
                    attendanceSection
                }
                .padding(DesignConstants.horizontalPadding)
            }
            .background(Color.pageBackground)
            .navigationTitle("매치 상세")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("완료") {
                        dismiss()
                    }
                }
            }
        }
        .ballogTopBar(selectedTab: .constant(0))
    }
    
    private var matchInfoSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            Text("매치 정보")
                .font(.title2.bold())
                .foregroundColor(Color.primaryText)
            
            VStack(spacing: DesignConstants.smallSpacing) {
                MatchInfoRow(title: "제목", value: matchEvent.title)
                MatchInfoRow(title: "장소", value: matchEvent.place)
                MatchInfoRow(title: "날짜", value: matchEvent.date, dateStyle: .date)
                MatchInfoRow(title: "시간", value: matchEvent.date, dateStyle: .time)
                if let opponent = matchEvent.opponent {
                    MatchInfoRow(title: "상대팀", value: opponent)
                }
            }
            .padding(DesignConstants.cardPadding)
            .background(
                RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                    .fill(Color.cardBackground)
            )
        }
    }
    
    private var scoreSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            HStack {
                Text("스코어")
                    .font(.title2.bold())
                    .foregroundColor(Color.primaryText)
                Spacer()
                Button("수정") {
                    showScoreInput = true
                }
                .foregroundColor(Color.primaryBlue)
            }
            
            HStack(spacing: DesignConstants.largeSpacing) {
                VStack {
                    Text("우리팀")
                        .font(.caption)
                        .foregroundColor(Color.secondaryText)
                    Text("\(matchEvent.ourScore ?? 0)")
                        .font(.title.bold())
                        .foregroundColor(Color.primaryText)
                }
                
                Text("-")
                    .font(.title)
                    .foregroundColor(Color.secondaryText)
                
                VStack {
                    Text("상대팀")
                        .font(.caption)
                        .foregroundColor(Color.secondaryText)
                    Text("\(matchEvent.opponentScore ?? 0)")
                        .font(.title.bold())
                        .foregroundColor(Color.primaryText)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(DesignConstants.cardPadding)
            .background(
                RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                    .fill(Color.cardBackground)
            )
        }
        .alert("스코어 입력", isPresented: $showScoreInput) {
            TextField("우리팀 점수", value: $ourScore, format: .number)
            TextField("상대팀 점수", value: $opponentScore, format: .number)
            Button("저장") {
                // 스코어 저장 로직
            }
            Button("취소", role: .cancel) { }
        }
    }
    
    private var attendanceSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            Text("출석 현황")
                .font(.title2.bold())
                .foregroundColor(Color.primaryText)
            
            // 출석 현황 표시
            Text("출석 관리 기능은 추후 업데이트 예정입니다.")
                .font(.subheadline)
                .foregroundColor(Color.secondaryText)
                .frame(maxWidth: .infinity)
                .padding(DesignConstants.cardPadding)
                .background(
                    RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                        .fill(Color.cardBackground)
                )
        }
    }
}

struct MatchInfoRow: View {
    let title: String
    let value: Any
    var dateStyle: Text.DateStyle?
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(Color.secondaryText)
            
            Spacer()
            
            if let date = value as? Date, let style = dateStyle {
                Text(date, style: style)
                    .font(.subheadline)
                    .foregroundColor(Color.primaryText)
            } else {
                Text("\(value)")
                    .font(.subheadline)
                    .foregroundColor(Color.primaryText)
            }
        }
    }
}

#Preview {
    MatchManagementView()
        .environmentObject(AttendanceStore())
        .environmentObject(TeamEventStore())
}
