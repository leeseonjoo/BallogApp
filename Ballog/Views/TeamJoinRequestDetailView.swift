import SwiftUI

struct TeamJoinRequestDetailView: View {
    let request: TeamJoinRequest
    let team: Team
    @EnvironmentObject private var requestStore: TeamJoinRequestStore
    @EnvironmentObject private var teamStore: TeamStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var showApprovalAlert = false
    @State private var showRejectionAlert = false
    @State private var approvalMessage = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignConstants.sectionSpacing) {
                    // Applicant Info Section
                    applicantInfoSection
                    
                    // Request Message Section
                    requestMessageSection
                    
                    // Action Buttons Section
                    if request.status == .pending {
                        actionButtonsSection
                    }
                }
                .padding(DesignConstants.horizontalPadding)
            }
            .background(Color.pageBackground)
            .navigationTitle("신청 상세")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("닫기") {
                        dismiss()
                    }
                }
            }
            .alert("승인", isPresented: $showApprovalAlert) {
                TextField("메시지 (선택사항)", text: $approvalMessage)
                Button("승인") {
                    approveRequest()
                }
                Button("취소", role: .cancel) { }
            } message: {
                Text("이 신청을 승인하시겠습니까?")
            }
            .alert("거절", isPresented: $showRejectionAlert) {
                TextField("사유 (선택사항)", text: $approvalMessage)
                Button("거절", role: .destructive) {
                    rejectRequest()
                }
                Button("취소", role: .cancel) { }
            } message: {
                Text("이 신청을 거절하시겠습니까?")
            }
        }
    }
    
    private var applicantInfoSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            Text("신청자 정보")
                .font(.title2.bold())
                .foregroundColor(Color.primaryText)
            
            VStack(spacing: DesignConstants.smallSpacing) {
                RequestInfoRow(title: "신청자", value: request.applicantName)
                RequestInfoRow(title: "신청일", value: request.createdAt, style: .date)
                RequestInfoRow(title: "상태", value: request.status.rawValue)
            }
            .padding(DesignConstants.cardPadding)
            .background(
                RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                    .fill(Color.cardBackground)
            )
        }
    }
    
    private var requestMessageSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            Text("신청 메시지")
                .font(.title2.bold())
                .foregroundColor(Color.primaryText)
            
            VStack(alignment: .leading, spacing: DesignConstants.smallSpacing) {
                if request.applicantMessage.isEmpty {
                    Text("메시지가 없습니다")
                        .font(.subheadline)
                        .foregroundColor(Color.secondaryText)
                        .italic()
                } else {
                    Text(request.applicantMessage)
                        .font(.subheadline)
                        .foregroundColor(Color.primaryText)
                }
            }
            .padding(DesignConstants.cardPadding)
            .background(
                RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                    .fill(Color.cardBackground)
            )
        }
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: DesignConstants.smallSpacing) {
            Button(action: { showApprovalAlert = true }) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("승인")
                }
                .frame(maxWidth: .infinity)
                .padding(DesignConstants.cardPadding)
                .background(Color.primaryGreen)
                .foregroundColor(.white)
                .cornerRadius(DesignConstants.cornerRadius)
            }
            
            Button(action: { showRejectionAlert = true }) {
                HStack {
                    Image(systemName: "xmark.circle.fill")
                    Text("거절")
                }
                .frame(maxWidth: .infinity)
                .padding(DesignConstants.cardPadding)
                .background(Color.primaryRed)
                .foregroundColor(.white)
                .cornerRadius(DesignConstants.cornerRadius)
            }
        }
    }
    
    private func approveRequest() {
        var updatedRequest = request
        updatedRequest = TeamJoinRequest(
            teamId: request.teamId,
            applicantId: request.applicantId,
            applicantName: request.applicantName,
            applicantMessage: request.applicantMessage,
            status: .approved,
            createdAt: request.createdAt
        )
        
        requestStore.updateRequest(updatedRequest)
        
        // 팀에 멤버 추가
        let newMember = TeamCharacter(
            name: request.applicantName,
            imageName: "soccer-player",
            isOnline: false
        )
        
        if let teamIndex = teamStore.teams.firstIndex(where: { $0.id == team.id }) {
            teamStore.teams[teamIndex].members.append(newMember)
        }
        
        dismiss()
    }
    
    private func rejectRequest() {
        var updatedRequest = request
        updatedRequest = TeamJoinRequest(
            teamId: request.teamId,
            applicantId: request.applicantId,
            applicantName: request.applicantName,
            applicantMessage: request.applicantMessage,
            status: .rejected,
            createdAt: request.createdAt
        )
        
        requestStore.updateRequest(updatedRequest)
        dismiss()
    }
}

struct RequestInfoRow: View {
    let title: String
    let value: Any
    var style: Text.DateStyle?
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(Color.secondaryText)
            
            Spacer()
            
            if let date = value as? Date, let dateStyle = style {
                Text(date, style: dateStyle)
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
    TeamJoinRequestDetailView(
        request: TeamJoinRequest(
            teamId: UUID(),
            applicantId: "user1",
            applicantName: "김철수",
            applicantMessage: "팀에 가입하고 싶습니다!"
        ),
        team: Team(name: "샘플팀", region: "서울", creatorName: "홍길동")
    )
    .environmentObject(TeamJoinRequestStore())
    .environmentObject(TeamStore())
} 