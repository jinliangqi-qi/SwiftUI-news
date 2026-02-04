//
//  StoryTypeButton.swift
//  SwiftUI-news
//
//  Created by v_jinlqi on 2026/1/30.
//
//  故事类型按钮组件

import SwiftUI

// MARK: - 故事类型按钮
struct StoryTypeButton: View {
    let type: StoryType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: type.icon)
                    .font(.subheadline)
                Text(type.name)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(isSelected ? type.color.opacity(0.15) : Color.platformGray6)
            .foregroundColor(isSelected ? type.color : .primary)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? type.color : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}
