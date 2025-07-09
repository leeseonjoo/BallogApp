//
//  TabBarView.swift
//  Ballog
//
//  Created by 이선주 on 7/9/25.
//

import SwiftUI

struct TabBarView: View {
    var body: some View {
        HStack {
            Spacer()
            TabBarItem(icon: "house", label: "홈")
            Spacer()
            TabBarItem(icon: "person", label: "개인")
            Spacer()
            TabBarItem(icon: "person.2", label: "팀")
            Spacer()
            TabBarItem(icon: "square.stack", label: "피드")
            Spacer()
            TabBarItem(icon: "gearshape", label: "설정")
            Spacer()
        }
        .padding(.vertical, 12)
        .background(Color.pageBackground)
        .ignoresSafeArea()
    }
}

struct TabBarItem: View {
    let icon: String
    let label: String
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .resizable()
                .frame(width: 20, height: 20)
            Text(label)
                .font(.caption)
        }
        .foregroundColor(.black)
    }
}
