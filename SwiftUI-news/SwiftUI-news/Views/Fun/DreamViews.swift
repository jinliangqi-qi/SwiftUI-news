//
//  DreamViews.swift
//  SwiftUI-news
//
//  Created by v_jinlqi on 2026/1/30.
//
//  解梦相关视图组件

import SwiftUI

// MARK: - 解梦行视图
struct DreamRowView: View {
    let dream: DreamData
    
    var body: some View {
        HStack(spacing: 12) {
            // 分类图标
            Image(systemName: dream.typeIcon)
                .font(.body)
                .foregroundStyle(dream.typeColor.gradient)
                .frame(width: 32, height: 32)
                .background(dream.typeColor.opacity(0.12))
                .clipShape(Circle())
            
            // 内容
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(dream.title)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(dream.type)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(dream.typeColor.opacity(0.12))
                        .foregroundColor(dream.typeColor)
                        .clipShape(Capsule())
                }
                
                Text(dream.cleanedResult)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .lineSpacing(2)
            }
            
            Spacer(minLength: 8)
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.tertiaryLabel)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

// MARK: - 解梦详情弹窗
struct DreamDetailSheet: View {
    let dream: DreamData
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 标题区域
                    HStack(spacing: 14) {
                        Image(systemName: dream.typeIcon)
                            .font(.title2)
                            .foregroundStyle(dream.typeColor.gradient)
                            .frame(width: 48, height: 48)
                            .background(dream.typeColor.opacity(0.12))
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text(dream.title)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(dream.type)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(dream.typeColor.opacity(0.12))
                                .foregroundColor(dream.typeColor)
                                .clipShape(Capsule())
                        }
                        
                        Spacer()
                    }
                    
                    Divider()
                    
                    // 解梦内容
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 6) {
                            Image(systemName: "sparkles")
                                .foregroundColor(.purple)
                            Text("解梦释义")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        
                        Text(dream.cleanedResult)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineSpacing(6)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.platformGray6)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(20)
            }
            .background(Color.platformGroupedBackground)
            .navigationTitle("解梦详情")
            .platformNavigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("关闭") { dismiss() }
                }
            }
        }
        #if os(iOS)
        .presentationDetents([.medium, .large])
        #else
        .frame(minWidth: 420, idealWidth: 480, minHeight: 380, idealHeight: 450)
        #endif
    }
}
