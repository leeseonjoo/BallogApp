import SwiftUI

struct FeedView: View {
    @State private var selectedTab: FeedTab = .all
    @State private var posts: [FeedPost] = []
    @State private var showCreatePost = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header with Search
                headerSection
                
                // Tab Picker
                tabPickerSection
                
                // Feed Content
                feedContentSection
            }
            .background(Color.pageBackground)
            .navigationTitle("피드")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showCreatePost = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Color.primaryBlue)
                    }
                }
            }
            .sheet(isPresented: $showCreatePost) {
                CreatePostView { newPost in
                    posts.insert(newPost, at: 0)
                }
            }
            .onAppear {
                loadSamplePosts()
            }
        }
        .ballogTopBar()
    }
    
    private var headerSection: some View {
        VStack(spacing: DesignConstants.smallSpacing) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color.secondaryText)
                
                TextField("피드 검색...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button("취소") {
                        searchText = ""
                    }
                    .foregroundColor(Color.primaryBlue)
                }
            }
            .padding(DesignConstants.cardPadding)
            .background(
                RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                    .fill(Color.cardBackground)
            )
            .padding(.horizontal, DesignConstants.horizontalPadding)
        }
        .padding(.vertical, DesignConstants.verticalPadding)
    }
    
    private var tabPickerSection: some View {
        Picker("FeedTab", selection: $selectedTab) {
            ForEach(FeedTab.allCases, id: \.self) { tab in
                Text(tab.rawValue).tag(tab)
            }
        }
        .pickerStyle(.segmented)
        .padding(DesignConstants.horizontalPadding)
        .padding(.bottom, DesignConstants.verticalPadding)
    }
    
    private var feedContentSection: some View {
        ScrollView {
            LazyVStack(spacing: DesignConstants.spacing) {
                ForEach(filteredPosts) { post in
                    FeedPostCard(post: post) { updatedPost in
                        if let index = posts.firstIndex(where: { $0.id == updatedPost.id }) {
                            posts[index] = updatedPost
                        }
                    }
                }
            }
            .padding(DesignConstants.horizontalPadding)
        }
    }
    
    private var filteredPosts: [FeedPost] {
        let filtered = posts.filter { post in
            if !searchText.isEmpty {
                return post.content.localizedCaseInsensitiveContains(searchText) ||
                       post.author.localizedCaseInsensitiveContains(searchText)
            }
            return true
        }
        
        switch selectedTab {
        case .all:
            return filtered
        case .communication:
            return filtered.filter { $0.type == .communication }
        case .training:
            return filtered.filter { $0.type == .training }
        case .achievement:
            return filtered.filter { $0.type == .achievement }
        }
    }
    
    private func loadSamplePosts() {
        posts = [
            FeedPost(
                id: UUID(),
                author: "김철수",
                content: "오늘 팀 훈련에서 새로운 전술을 배웠어요! 모두가 열심히 참여해서 정말 뿌듯했습니다. 다음 경기에서 이 전술을 활용해보겠습니다! 💪",
                type: .communication,
                likes: 12,
                comments: 5,
                time: Date().addingTimeInterval(-3600),
                imageURL: nil,
                isLiked: false
            ),
            FeedPost(
                id: UUID(),
                author: "이영희",
                content: "오늘 개인 훈련 완료! 체력이 많이 좋아진 것 같아요. 내일도 화이팅! 🔥",
                type: .training,
                likes: 8,
                comments: 3,
                time: Date().addingTimeInterval(-7200),
                imageURL: nil,
                isLiked: true
            ),
            FeedPost(
                id: UUID(),
                author: "박민수",
                content: "이번 주 경기에서 첫 골을 넣었습니다! 팀원들의 도움이 컸어요. 감사합니다! ⚽️",
                type: .achievement,
                likes: 25,
                comments: 8,
                time: Date().addingTimeInterval(-10800),
                imageURL: nil,
                isLiked: false
            ),
            FeedPost(
                id: UUID(),
                author: "최지영",
                content: "훈련 후 팀원들과 함께 찍은 사진입니다. 모두가 하나되어 정말 좋았어요! 📸",
                type: .training,
                likes: 15,
                comments: 6,
                time: Date().addingTimeInterval(-14400),
                imageURL: nil,
                isLiked: true
            )
        ]
    }
}

enum FeedTab: String, CaseIterable {
    case all = "전체"
    case communication = "소통"
    case training = "훈련"
    case achievement = "성과"
}

struct FeedPost: Identifiable {
    let id: UUID
    let author: String
    let content: String
    let type: PostType
    var likes: Int
    var comments: Int
    let time: Date
    let imageURL: String?
    var isLiked: Bool
}

enum PostType {
    case communication, training, achievement
    
    var icon: String {
        switch self {
        case .communication:
            return "message.circle"
        case .training:
            return "figure.walk"
        case .achievement:
            return "trophy"
        }
    }
    
    var color: Color {
        switch self {
        case .communication:
            return Color.primaryBlue
        case .training:
            return Color.primaryGreen
        case .achievement:
            return Color.primaryOrange
        }
    }
    
    var title: String {
        switch self {
        case .communication:
            return "팀 소통"
        case .training:
            return "훈련 기록"
        case .achievement:
            return "성과 공유"
        }
    }
}

struct FeedPostCard: View {
    let post: FeedPost
    let onUpdate: (FeedPost) -> Void
    @State private var showComments = false
    @State private var commentText = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignConstants.cardSpacing) {
            // Header
            HStack {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(Color.primaryBlue)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.author)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Color.primaryText)
                    
                    HStack(spacing: 4) {
                        Image(systemName: post.type.icon)
                            .font(.caption)
                            .foregroundColor(post.type.color)
                        Text(post.type.title)
                            .font(.caption)
                            .foregroundColor(post.type.color)
                        Text("•")
                            .font(.caption)
                            .foregroundColor(Color.secondaryText)
                        Text(post.time, style: .relative)
                            .font(.caption)
                            .foregroundColor(Color.secondaryText)
                    }
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(Color.secondaryText)
                }
            }
            
            // Content
            Text(post.content)
                .font(.body)
                .foregroundColor(Color.primaryText)
                .multilineTextAlignment(.leading)
            
            // Image
            if let imageURL = post.imageURL {
                Image(imageURL)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(DesignConstants.cornerRadius)
            }
            
            // Actions
            HStack(spacing: DesignConstants.largeSpacing) {
                Button(action: { toggleLike() }) {
                    HStack(spacing: 4) {
                        Image(systemName: post.isLiked ? "heart.fill" : "heart")
                            .foregroundColor(post.isLiked ? Color.primaryRed : Color.secondaryText)
                        Text("\(post.likes)")
                            .font(.caption)
                            .foregroundColor(Color.secondaryText)
                    }
                }
                
                Button(action: { showComments.toggle() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "message")
                            .foregroundColor(Color.secondaryText)
                        Text("\(post.comments)")
                            .font(.caption)
                            .foregroundColor(Color.secondaryText)
                    }
                }
                
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(Color.secondaryText)
                        Text("공유")
                            .font(.caption)
                            .foregroundColor(Color.secondaryText)
                    }
                }
                
                Spacer()
            }
            
            // Comments Section
            if showComments {
                VStack(spacing: DesignConstants.smallSpacing) {
                    Divider()
                    
                    // Comment Input
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(Color.primaryBlue)
                        
                        TextField("댓글을 입력하세요...", text: $commentText)
                            .textFieldStyle(PlainTextFieldStyle())
                        
                        Button("게시") {
                            addComment()
                        }
                        .foregroundColor(Color.primaryBlue)
                        .disabled(commentText.isEmpty)
                    }
                    .padding(DesignConstants.smallPadding)
                    .background(
                        RoundedRectangle(cornerRadius: DesignConstants.smallCornerRadius)
                            .fill(Color.cardBackground)
                    )
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
    
    private func toggleLike() {
        var updatedPost = post
        updatedPost.isLiked.toggle()
        updatedPost.likes += updatedPost.isLiked ? 1 : -1
        onUpdate(updatedPost)
    }
    
    private func addComment() {
        guard !commentText.isEmpty else { return }
        var updatedPost = post
        updatedPost.comments += 1
        onUpdate(updatedPost)
        commentText = ""
    }
}

struct CreatePostView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var content = ""
    @State private var selectedType: PostType = .communication
    
    let onPost: (FeedPost) -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: DesignConstants.sectionSpacing) {
                // Post Type Selector
                VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
                    Text("게시 유형")
                        .font(.headline)
                        .foregroundColor(Color.primaryText)
                    
                    HStack(spacing: DesignConstants.smallSpacing) {
                        ForEach([PostType.communication, .training, .achievement], id: \.title) { type in
                            Button(action: { selectedType = type }) {
                                HStack(spacing: 4) {
                                    Image(systemName: type.icon)
                                        .foregroundColor(selectedType == type ? .white : type.color)
                                    Text(type.title)
                                        .font(.caption)
                                        .foregroundColor(selectedType == type ? .white : type.color)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: DesignConstants.smallCornerRadius)
                                        .fill(selectedType == type ? type.color : type.color.opacity(0.1))
                                )
                            }
                        }
                    }
                }
                
                // Content Input
                VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
                    Text("내용")
                        .font(.headline)
                        .foregroundColor(Color.primaryText)
                    
                    TextEditor(text: $content)
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
                
                // Image Picker
                VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
                    Text("사진 추가")
                        .font(.headline)
                        .foregroundColor(Color.primaryText)
                    
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "photo")
                                .foregroundColor(Color.secondaryText)
                            Text("사진 선택")
                                .foregroundColor(Color.secondaryText)
                            Spacer()
                        }
                        .padding(DesignConstants.cardPadding)
                        .background(
                            RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                                .fill(Color.cardBackground)
                        )
                    }
                    .disabled(true) // 이미지 선택 기능은 현재 비활성화
                }
                
                Spacer()
            }
            .padding(DesignConstants.horizontalPadding)
            .navigationTitle("새 게시물")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("게시") {
                        createPost()
                    }
                    .disabled(content.isEmpty)
                }
            }
        }
    }
    
    private func createPost() {
        let newPost = FeedPost(
            id: UUID(),
            author: "나",
            content: content,
            type: selectedType,
            likes: 0,
            comments: 0,
            time: Date(),
            imageURL: nil,
            isLiked: false
        )
        onPost(newPost)
        dismiss()
    }
}

#Preview {
    FeedView()
}
