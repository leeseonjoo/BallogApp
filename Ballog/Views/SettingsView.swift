//
//  SettingsView.swift
//  Ballog
//
//  Created by 이선주 on 7/9/25.
//

import SwiftUI

private enum Layout {
    static let padding = DesignConstants.horizontalPadding
}

struct SettingsView: View {
    @AppStorage("profileCard") private var storedCard: String = ""
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @AppStorage("currentTeamID") private var currentTeamID: String = ""
    @AppStorage("autoLogin") private var autoLogin: Bool = false
    @AppStorage("savedUsername") private var savedUsername: String = ""
    @AppStorage("savedPassword") private var savedPassword: String = ""
    @AppStorage("isAdminUser") private var isAdminUser: Bool = false
    @State private var showLogoutAlert = false
    @State private var showDeleteAccountAlert = false
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = false
    @State private var autoSaveEnabled = true

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignConstants.sectionSpacing) {
                    // Account Section
                    accountSection
                    
                    // App Settings Section
                    appSettingsSection
                    
                    // App Info Section
                    appInfoSection
                    
                    // Logout Section
                    logoutSection
                }
                .padding(DesignConstants.horizontalPadding)
            }
            .background(Color.pageBackground)
            .navigationTitle("설정")
            .navigationBarTitleDisplayMode(.large)
            .alert("로그아웃 하시겠습니까?", isPresented: $showLogoutAlert) {
                Button("예", role: .destructive) {
                    logout()
                }
                Button("아니오", role: .cancel) { }
            }
            .alert("계정 삭제", isPresented: $showDeleteAccountAlert) {
                Button("삭제", role: .destructive) {
                    deleteAccount()
                }
                Button("취소", role: .cancel) { }
            } message: {
                Text("계정을 삭제하면 모든 데이터가 영구적으로 삭제됩니다. 정말 삭제하시겠습니까?")
            }
        }
    }
    
    private var accountSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            Text("계정")
                .font(.title2.bold())
                .foregroundColor(Color.primaryText)
            
            VStack(spacing: DesignConstants.smallSpacing) {
                NavigationLink(destination: ProfileView()) {
                    SettingsItem(
                        icon: "person.circle",
                        title: "프로필",
                        subtitle: "개인 정보 관리"
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                if isAdminUser {
                    NavigationLink(destination: AdminView()) {
                        SettingsItem(
                            icon: "lock.shield",
                            title: "관리자",
                            subtitle: "관리자 기능"
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                SettingsItem(
                    icon: "key",
                    title: "비밀번호 변경",
                    subtitle: "계정 보안"
                )
            }
        }
    }
    
    private var appSettingsSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            Text("앱 설정")
                .font(.title2.bold())
                .foregroundColor(Color.primaryText)
            
            VStack(spacing: DesignConstants.smallSpacing) {
                ToggleSettingsItem(
                    icon: "bell",
                    title: "알림",
                    subtitle: "푸시 알림 설정",
                    isOn: $notificationsEnabled
                )
                
                ToggleSettingsItem(
                    icon: "moon",
                    title: "다크 모드",
                    subtitle: "어두운 테마 사용",
                    isOn: $darkModeEnabled
                )
                
                ToggleSettingsItem(
                    icon: "arrow.clockwise",
                    title: "자동 저장",
                    subtitle: "데이터 자동 저장",
                    isOn: $autoSaveEnabled
                )
            }
        }
    }
    
    private var appInfoSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            Text("앱 정보")
                .font(.title2.bold())
                .foregroundColor(Color.primaryText)
            
            VStack(spacing: DesignConstants.smallSpacing) {
                SettingsItem(
                    icon: "info.circle",
                    title: "버전",
                    subtitle: "1.0.0"
                )
                
                SettingsItem(
                    icon: "questionmark.circle",
                    title: "도움말",
                    subtitle: "사용법 안내"
                )
                
                SettingsItem(
                    icon: "envelope",
                    title: "문의하기",
                    subtitle: "개발자에게 연락"
                )
                
                SettingsItem(
                    icon: "hand.thumbsup",
                    title: "평가하기",
                    subtitle: "앱스토어에서 평가"
                )
            }
        }
    }
    
    private var logoutSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            Text("계정 관리")
                .font(.title2.bold())
                .foregroundColor(Color.primaryText)
            
            VStack(spacing: DesignConstants.smallSpacing) {
                Button(action: { showLogoutAlert = true }) {
                    SettingsItem(
                        icon: "rectangle.portrait.and.arrow.right",
                        title: "로그아웃",
                        subtitle: "계정에서 로그아웃",
                        isDestructive: true
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: { showDeleteAccountAlert = true }) {
                    SettingsItem(
                        icon: "trash",
                        title: "계정 삭제",
                        subtitle: "계정 영구 삭제",
                        isDestructive: true
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    private func logout() {
        storedCard = ""
        isLoggedIn = false
        currentTeamID = ""
        autoLogin = false
        savedUsername = ""
        savedPassword = ""
        isAdminUser = false
    }
    
    private func deleteAccount() {
        // 계정 삭제 로직
        logout()
    }
}

struct SettingsItem: View {
    let icon: String
    let title: String
    let subtitle: String
    var isDestructive: Bool = false
    
    var body: some View {
        HStack(spacing: DesignConstants.spacing) {
            Image(systemName: icon)
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(isDestructive ? Color.errorColor : Color.primaryBlue)
                .padding(DesignConstants.smallPadding)
                .background(
                    Circle()
                        .fill(isDestructive ? Color.errorColor.opacity(0.1) : Color.primaryBlue.opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isDestructive ? Color.errorColor : Color.primaryText)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(Color.secondaryText)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(Color.secondaryText)
        }
        .padding(DesignConstants.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                .fill(Color.cardBackground)
        )
    }
}

struct ToggleSettingsItem: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: DesignConstants.spacing) {
            Image(systemName: icon)
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(Color.primaryBlue)
                .padding(DesignConstants.smallPadding)
                .background(
                    Circle()
                        .fill(Color.primaryBlue.opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color.primaryText)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(Color.secondaryText)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding(DesignConstants.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                .fill(Color.cardBackground)
        )
    }
}

#Preview {
    SettingsView()
}
