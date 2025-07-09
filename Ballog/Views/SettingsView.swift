//
//  SettingsView.swift
//  Ballog
//
//  Created by 이선주 on 7/9/25.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("계정")) {
                    Text("프로필")
                    Text("로그아웃")
                }

                Section(header: Text("정보")) {
                    Text("버전 1.0")
                }
            }
            .navigationTitle("설정")
            .scrollContentBackground(.hidden)
            .background(Color.pageBackground)
        }
        .background(Color.pageBackground)
        .ignoresSafeArea()
    }
}

#Preview {
    SettingsView()
}
