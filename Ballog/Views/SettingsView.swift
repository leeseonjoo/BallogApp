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
    @State private var showLogoutAlert = false

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("계정")) {
                    NavigationLink("프로필") {
                        ProfileView()
                    }
                    Button("로그아웃") { showLogoutAlert = true }
                }

                Section(header: Text("정보")) {
                    Text("버전 1.0")
                }
            }
            .listStyle(.insetGrouped)
            .padding(.horizontal, Layout.padding)
            .navigationTitle("설정")
            .alert("로그아웃 하시겠습니까?", isPresented: $showLogoutAlert) {
                Button("예", role: .destructive) {
                    storedCard = ""
                    isLoggedIn = false
                    currentTeamID = ""
                }
                Button("아니오", role: .cancel) { }
            }
            .scrollContentBackground(.hidden)
        }
        .background(Color.pageBackground)
        .ignoresSafeArea()
        .ballogTopBar()
    }
}

#Preview {
    SettingsView()
}
