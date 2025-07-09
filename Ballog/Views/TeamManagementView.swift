//
//  TeamManagementView.swift
//  Ballog
//
//  Created by 이선주 on 7/9/25.
//

import SwiftUI

private enum Layout {
    static let spacing = DesignConstants.spacing
    static let padding = DesignConstants.horizontalPadding
}

// MARK: - TeamMember 모델 정의
struct TeamMember: Identifiable {
    var id = UUID()
    var name: String
}

// MARK: - 메인 팀 관리 뷰
struct TeamManagementView: View {
    // 선택된 팀원 정보 (팝업용)
    @State private var selectedMember: TeamMember? = nil

    // 팀원 리스트
    let teamMembers = [
        TeamMember(name: "민수"),
        TeamMember(name: "태호"),
        TeamMember(name: "지현")
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Layout.spacing) {
                    
                    // 1. 팀명 + 로고
                    HStack {
                        Image(systemName: "soccerball")
                            .resizable()
                            .frame(width: 30, height: 30)
                        Text("해그래 FS")
                            .font(.title)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding(.horizontal, Layout.padding)
                    
                    // 2. 팀원 한마디
                    HStack {
                        Image(systemName: "quote.bubble")
                            .foregroundColor(.gray)
                        Text("“오늘도 파이팅!” - 잔디요정")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, Layout.padding)
                    
                    Divider()
                    
                    // 3. 팀원 캐릭터
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 24) {
                            ForEach(teamMembers) { member in
                                VStack {
                                    Image(systemName: "person.fill")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(.blue)
                                    Text(member.name)
                                }
                                .onTapGesture {
                                    selectedMember = member
                                }
                            }
                        }
                        .padding(.horizontal, Layout.padding)
                    }
                    
                    // 4. 훈련 일정
                    VStack(alignment: .leading, spacing: 12) {
                        Text("📅 팀 훈련 일정")
                            .font(.headline)
                        ForEach(0..<4) { index in
                            HStack {
                                Text("7월 \(20 + index)일 (일)")
                                Spacer()
                                Text("풋살장 A")
                                Spacer()
                                Button("✅ 참석") {
                                    // 참석 처리
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        }
                    }
                    .padding(.horizontal, Layout.padding)
                    
                    // 5. 훈련 일지 요약
                    VStack(alignment: .leading, spacing: 12) {
                        Text("📋 최근 팀 훈련 일지")
                            .font(.headline)
                        ForEach(1..<6) { idx in
                            HStack {
                                Text("7월 \(14 + idx)일 • 전술 훈련")
                                Spacer()
                                Text("작성 완료")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                            Divider()
                        }
                        Button("전체 보기 →") {
                            // 이동
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                    .padding(.horizontal, Layout.padding)
                    
                    // 6. 작성 버튼
                    Button(action: {
                        // 훈련일지 작성 페이지로 이동
                    }) {
                        Text("✏️ 팀 훈련일지 작성")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.yellow.opacity(0.2))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, Layout.padding)
                    
                    Spacer()
                }
            }
            .navigationTitle("팀 훈련")
            .sheet(item: $selectedMember) { member in
                TeamMemberCardView(memberName: member.name)
            }
        }
        .background(Color.pageBackground)
        .ignoresSafeArea()
    }
}

// MARK: - 팝업: 팀원 캐릭터 카드
struct TeamMemberCardView: View {
    let memberName: String
    
    var body: some View {
        VStack(spacing: Layout.spacing) {
            Text("⚽️ \(memberName)의 캐릭터 카드")
                .font(.title2)
                .padding()
            Image(systemName: "person.crop.square")
                .resizable()
                .frame(width: 100, height: 100)
                .padding(.bottom, 8)
            Text("최근 훈련 4회 참석\n드리블 기술 향상 중")
                .multilineTextAlignment(.center)
                .padding()
        }
    }
}
