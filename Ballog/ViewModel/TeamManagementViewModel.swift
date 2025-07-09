import Foundation

class TeamManagementViewModel: ObservableObject {
    @Published var teamMembers: [TeamMember] = [
        TeamMember(name: "민수"),
        TeamMember(name: "태호"),
        TeamMember(name: "지현")
    ]
}
