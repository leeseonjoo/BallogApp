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

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignConstants.sectionSpacing) {
                    // Account Section
                    accountSection
                    
                    // App Info Section
                    appInfoSection
                    
                    // Logout Section
                    logoutSection
                }
                .padding(DesignConstants.horizontalPadding)
            }
            .background(Color.pageBackground)
            .alert("로그아웃 하시겠습니까?", isPresented: $showLogoutAlert) {
                Button("예", role: .destructive) {
                    storedCard = ""
                    isLoggedIn = false
                    currentTeamID = ""
                    autoLogin = false
                    savedUsername = ""
                    savedPassword = ""
                    isAdminUser = false
                }
                Button("아니오", role: .cancel) { }
            }
        }
        .ballogTopBar()
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
                    SettingsItem(
                        icon: "lock.shield",
                        title: "관리자",
                        subtitle: "관리자 기능"
                    )
                }
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
            }
        }
    }
    
    private var logoutSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionHeaderSpacing) {
            Text("계정 관리")
                .font(.title2.bold())
                .foregroundColor(Color.primaryText)
            
            Button(action: { showLogoutAlert = true }) {
                SettingsItem(
                    icon: "rectangle.portrait.and.arrow.right",
                    title: "로그아웃",
                    subtitle: "계정에서 로그아웃",
                    isDestructive: true
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
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

#Preview {
    SettingsView()
}
