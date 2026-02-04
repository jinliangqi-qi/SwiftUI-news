//
//  ConstellationButton.swift
//  SwiftUI-news
//
//  Created by v_jinlqi on 2026/1/30.
//
//  星座选择按钮组件

import SwiftUI

// MARK: - 星座选择按钮
struct ConstellationButton: View {
    let constellation: Constellation
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(constellation.icon)
                    .font(.title2)
                Text(constellation.rawValue)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .frame(width: 56)
            .padding(.vertical, 8)
            .background(isSelected ? constellation.color.opacity(0.15) : Color.clear)
            .foregroundColor(isSelected ? constellation.color : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? constellation.color : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}
