//
//  TabBarView.swift
//  Ballog
//
//  Created by 이선주 on 7/9/25.
//

import SwiftUI

struct TabBarView: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 0) {
            TabBarItem(
                icon: "house",
                selectedIcon: "house.fill",
                label: "홈",
                isSelected: selectedTab == 0
            ) {
                selectedTab = 0
            }
            
            TabBarItem(
                icon: "figure.walk",
                selectedIcon: "figure.walk",
                label: "개인",
                isSelected: selectedTab == 1
            ) {
                selectedTab = 1
            }
            
            TabBarItem(
                icon: "person.3",
                selectedIcon: "person.3.fill",
                label: "팀",
                isSelected: selectedTab == 2
            ) {
                selectedTab = 2
            }
            
            TabBarItem(
                icon: "square.stack",
                selectedIcon: "square.stack.fill",
                label: "피드",
                isSelected: selectedTab == 3
            ) {
                selectedTab = 3
            }
            
            TabBarItem(
                icon: "gearshape",
                selectedIcon: "gearshape.fill",
                label: "설정",
                isSelected: selectedTab == 4
            ) {
                selectedTab = 4
            }
        }
        .padding(.horizontal, DesignConstants.horizontalPadding)
        .padding(.vertical, DesignConstants.verticalPadding)
        .background(
            Color.tabBarBackground
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: -2)
        )
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color.borderColor),
            alignment: .top
        )
    }
}

struct TabBarItem: View {
    let icon: String
    let selectedIcon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: DesignConstants.smallSpacing) {
                Image(systemName: isSelected ? selectedIcon : icon)
                    .resizable()
                    .frame(width: DesignConstants.tabBarIconSize, height: DesignConstants.tabBarIconSize)
                    .foregroundColor(isSelected ? Color.primaryBlue : Color.secondaryText)
                
                Text(label)
                    .font(.caption2)
                    .fontWeight(isSelected ? .semibold : .medium)
                    .foregroundColor(isSelected ? Color.primaryBlue : Color.secondaryText)
            }
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
    }
}

#Preview {
    TabBarView(selectedTab: .constant(0))
}
