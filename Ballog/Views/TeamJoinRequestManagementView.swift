import SwiftUI

struct TeamJoinRequestManagementView: View {
    let team: Team
    @EnvironmentObject private var requestStore: TeamJoinRequestStore
    @EnvironmentObject private var teamStore: TeamStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedRequest: TeamJoinRequest?
    @State private var showRequestDetail = false
    
    private var pendingRequests: [TeamJoinRequest] {
        requestStore.getPendingRequestsForTeam(team.id)
    }
    
    private var allRequests: [TeamJoinRequest] {
        requestStore.getRequestsForTeam(team.id)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignConstants.sectionSpacing) {
                    // Pending Requests Section
                    if !pendingRequests.isEmpty {
                        pendingRequestsSection
                    }
                    
                    // All Requests Section
                    allRequestsSection
                }
                .padding(DesignConstants.horizontalPadding)
            }
            .background(Color.pageBackground)
            .navigationTitle("가입 신청 관리")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showRequestDetail) {
                if let request = selectedRequest {
                    TeamJoinRequestDetailView(request: request, team: team)
                }
            }
        }
    }
    
    private var pendingRequestsSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            HStack {
                Text("대기중인 신청")
                    .font(.title2.bold())
                    .foregroundColor(Color.primaryText)
                
                Spacer()
                
                Text("\(pendingRequests.count)개")
                    .font(.caption)
                    .foregroundColor(Color.primaryOrange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: DesignConstants.smallCornerRadius)
                            .fill(Color.primaryOrange.opacity(0.1))
                    )
            }
            
            VStack(spacing: DesignConstants.smallSpacing) {
                ForEach(pendingRequests) { request in
                    RequestCard(request: request) {
                        selectedRequest = request
                        showRequestDetail = true
                    }
                }
            }
        }
    }
    
    private var allRequestsSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            Text("전체 신청")
                .font(.title2.bold())
                .foregroundColor(Color.primaryText)
            
            if allRequests.isEmpty {
                emptyRequestsView
            } else {
                VStack(spacing: DesignConstants.smallSpacing) {
                    ForEach(allRequests) { request in
                        RequestCard(request: request) {
                            selectedRequest = request
                            showRequestDetail = true
                        }
                    }
                }
            }
        }
    }
    
    private var emptyRequestsView: some View {
        VStack(spacing: DesignConstants.largeSpacing) {
            Image(systemName: "person.badge.plus")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundColor(Color.secondaryText)
            
            VStack(spacing: DesignConstants.smallSpacing) {
                Text("가입 신청이 없습니다")
                    .font(.headline)
                    .foregroundColor(Color.primaryText)
                
                Text("팀원들이 가입 신청을 보내면 여기에 표시됩니다")
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
}

struct RequestCard: View {
    let request: TeamJoinRequest
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: DesignConstants.smallSpacing) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(request.applicantName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(Color.primaryText)
                        
                        Text(request.createdAt, style: .date)
                            .font(.caption)
                            .foregroundColor(Color.secondaryText)
                    }
                    
                    Spacer()
                    
                    StatusBadge(status: request.status)
                }
                
                if !request.applicantMessage.isEmpty {
                    Text(request.applicantMessage)
                        .font(.caption)
                        .foregroundColor(Color.secondaryText)
                        .lineLimit(2)
                }
            }
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
        .buttonStyle(PlainButtonStyle())
    }
}

struct StatusBadge: View {
    let status: TeamJoinRequest.RequestStatus
    
    var body: some View {
        Text(status.rawValue)
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: DesignConstants.smallCornerRadius)
                    .fill(statusColor)
            )
    }
    
    private var statusColor: Color {
        switch status {
        case .pending:
            return Color.primaryOrange
        case .approved:
            return Color.primaryGreen
        case .rejected:
            return Color.primaryRed
        }
    }
}

#Preview {
    TeamJoinRequestManagementView(team: Team(name: "샘플팀", region: "서울", creatorName: "홍길동"))
        .environmentObject(TeamJoinRequestStore())
        .environmentObject(TeamStore())
} 