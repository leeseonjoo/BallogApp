//
//  FeedView.swift
//  Ballog
//
//  Created by 이선주 on 7/9/25.
//

import SwiftUI

private enum Layout {
    static let padding = DesignConstants.horizontalPadding
    static let spacing: CGFloat = 12
}

struct Comment: Identifiable, Equatable {
    let id = UUID()
    var author: String
    var content: String
}

struct FeedView: View {
    @State private var comments: [Comment] = [
        Comment(author: "윤혜진", content: "저희 가능합니다 연락주세요 010xxxxxxxx")
    ]
    @State private var isAddingComment = false
    @State private var newComment = ""
    @State private var editingCommentID: Comment.ID? = nil
    @State private var editedContent = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Layout.spacing) {
                    header
                    postContent
                    commentSection
                }
                .padding(Layout.padding)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .navigationTitle("피드")
        }
        .background(Color.pageBackground)
        .ignoresSafeArea()
    }

    // MARK: - Components

    private var header: some View {
        HStack {
            Text("이선주")
                .fontWeight(.bold)
            Spacer()
            Text("35분 전")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private var postContent: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("매치 상대팀 구합니다.")
                .font(.headline)
            Text("1. 팀명: 해그래FS")
            Text("2. 구장 예약: 서수원 풋살장 (구장비 무료)")
            Text("3. 날짜&시간: 8/30 (토) 18:00 - 20:00")
            Text("4. 매치 방식: 5vs5")
            Text("5. 팀수준: 하하하")
            Text("편하게 연락 주세요!!")
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray)
        )
    }

    private var commentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("댓글")
                .font(.headline)

            ForEach(comments) { comment in
                if editingCommentID == comment.id {
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("", text: $editedContent)
                            .textFieldStyle(.roundedBorder)
                        HStack {
                            Button("저장") {
                                if let index = comments.firstIndex(of: comment) {
                                    comments[index].content = editedContent
                                    editingCommentID = nil
                                }
                            }
                            Button("취소") {
                                editingCommentID = nil
                            }
                        }
                        .font(.caption)
                    }
                } else {
                    HStack(alignment: .top) {
                        Text("\(comment.author) : \(comment.content)")
                        Spacer()
                        Button("수정") {
                            editingCommentID = comment.id
                            editedContent = comment.content
                        }
                        Button("삭제") {
                            comments.removeAll { $0.id == comment.id }
                        }
                    }
                    .font(.subheadline)
                }
            }

            if isAddingComment {
                VStack(alignment: .leading, spacing: 4) {
                    TextField("댓글을 입력하세요", text: $newComment)
                        .textFieldStyle(.roundedBorder)
                    Button("저장") {
                        let trimmed = newComment.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        comments.append(Comment(author: "익명", content: trimmed))
                        newComment = ""
                        isAddingComment = false
                    }
                    .font(.caption)
                }
            }

            Button("댓글 추가") {
                isAddingComment.toggle()
            }
            .padding(.top, 4)
        }
    }
}

#Preview {
    FeedView()
}
