import SwiftUI

struct TeamJoinRequestView: View {
    let team: Team
    @EnvironmentObject private var requestStore: TeamJoinRequestStore
    @Environment(\.dismiss) private var dismiss
    @AppStorage("profileCard") private var storedCard: String = ""
    
    @State private var message = ""
    @State private var showSuccessAlert = false
    
    private var userCard: ProfileCard? {
        guard let data = storedCard.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(ProfileCard.self, from: data)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignConstants.sectionSpacing) {
                    // Team Info Section
                    teamInfoSection
                    
                    // Request Form Section
                    requestFormSection
                }
                .padding(DesignConstants.horizontalPadding)
            }
            .background(Color.pageBackground)
            .navigationTitle("팀 가입 신청")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("신청") {
                        submitRequest()
                    }
                    .disabled(message.isEmpty)
                }
            }
            .alert("신청 완료", isPresented: $showSuccessAlert) {
                Button("확인") {
                    dismiss()
                }
            } message: {
                Text("팀 가입 신청이 완료되었습니다. 팀 생성자의 승인을 기다려주세요.")
            }
        }
    }
    
    private var teamInfoSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            Text("팀 정보")
                .font(.title2.bold())
                .foregroundColor(Color.primaryText)
            
            VStack(spacing: DesignConstants.smallSpacing) {
                InfoRow(title: "팀명", value: team.name)
                InfoRow(title: "스포츠", value: team.sport)
                InfoRow(title: "성별", value: team.gender)
                InfoRow(title: "지역", value: team.region.isEmpty ? "미설정" : team.region)
                InfoRow(title: "훈련시간", value: team.trainingTime)
                InfoRow(title: "생성자", value: team.creatorName)
            }
            .padding(DesignConstants.cardPadding)
            .background(
                RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                    .fill(Color.cardBackground)
            )
        }
    }
    
    private var requestFormSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            Text("신청 메시지")
                .font(.title2.bold())
                .foregroundColor(Color.primaryText)
            
            VStack(spacing: DesignConstants.smallSpacing) {
                Text("팀 생성자에게 보낼 메시지를 작성해주세요.")
                    .font(.subheadline)
                    .foregroundColor(Color.secondaryText)
                
                TextEditor(text: $message)
                    .frame(minHeight: 120)
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
    }
    
    private func submitRequest() {
        guard let userCard = userCard else { return }
        
        let request = TeamJoinRequest(
            teamId: team.id,
            applicantId: userCard.nickname,
            applicantName: userCard.nickname,
            applicantMessage: message
        )
        
        requestStore.addRequest(request)
        showSuccessAlert = true
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(Color.secondaryText)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(Color.primaryText)
        }
    }
}

#Preview {
    TeamJoinRequestView(team: Team(name: "샘플팀", region: "서울", creatorName: "홍길동"))
        .environmentObject(TeamJoinRequestStore())
} 