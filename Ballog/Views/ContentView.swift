//
//  ContentView.swift
//  Ballog
//
//  Created by 이선주 on 7/8/25.
//
import SwiftUI

struct ContentView: View {
    // 개인 세션만 사용하므로 팀 관련 상태 제거
    @State private var selectedTopTab = 0
    @State private var showProfile = false
    @State private var showNotifications = false
    @State private var showSettings = false

    var body: some View {
        VStack(spacing: 0) {
            // 상단 커스텀 탑바
            HStack(alignment: .center, spacing: 0) {
                // 왼쪽: 볼로그
                Text("볼로그")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.primaryBlue)
                    .frame(minWidth: 80, alignment: .leading)
                    .padding(.leading, DesignConstants.horizontalPadding)
                Spacer()
                // 중앙: 개인 탭만 남김
                HStack(spacing: 16) {
                    TopTabButton(title: "개인", isSelected: true) { selectedTopTab = 0 }
                }
                .frame(maxWidth: 220)
                Spacer()
                // 오른쪽: 프로필/알림/설정 아이콘
                HStack(spacing: 16) {
                    Button(action: { showProfile = true }) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(Color.primaryBlue)
                    }
                    .sheet(isPresented: $showProfile) {
                        ProfileView()
                    }
                    Button(action: { showNotifications = true }) {
                        Image(systemName: "bell")
                            .resizable()
                            .frame(width: 18, height: 18)
                            .foregroundColor(Color.primaryText)
                    }
                    .sheet(isPresented: $showNotifications) {
                        NotificationView()
                    }
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape")
                            .resizable()
                            .frame(width: 18, height: 18)
                            .foregroundColor(Color.primaryText)
                    }
                    .sheet(isPresented: $showSettings) {
                        SettingsView()
                    }
                }
                .padding(.trailing, DesignConstants.horizontalPadding)
            }
            .padding(.vertical, 8)
            .background(
                Color.pageBackground
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
            .overlay(
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(Color.borderColor),
                alignment: .bottom
            )

            // 본문
            PersonalPageView()
        }
    }
}

#Preview {
    ContentView()
}
