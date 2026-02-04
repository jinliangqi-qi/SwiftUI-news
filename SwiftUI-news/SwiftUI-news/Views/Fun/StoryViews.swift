//
//  StoryViews.swift
//  SwiftUI-news
//
//  Created by v_jinlqi on 2026/1/30.
//
//  故事相关视图组件

import SwiftUI

// MARK: - 故事行视图
struct StoryRowView: View {
    let story: StoryData
    
    var body: some View {
        HStack(spacing: 12) {
            // 类型图标
            Image(systemName: story.typeIcon)
                .font(.body)
                .foregroundStyle(story.typeColor.gradient)
                .frame(width: 32, height: 32)
                .background(story.typeColor.opacity(0.12))
                .clipShape(Circle())
            
            // 内容
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(story.title)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(story.typeName)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(story.typeColor.opacity(0.12))
                        .foregroundColor(story.typeColor)
                        .clipShape(Capsule())
                }
                
                Text(story.previewContent)
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

// MARK: - 故事详情弹窗
struct StoryDetailSheet: View {
    let story: StoryData
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    // 标题区域
                    HStack(spacing: 14) {
                        Image(systemName: story.typeIcon)
                            .font(.title2)
                            .foregroundStyle(story.typeColor.gradient)
                            .frame(width: 48, height: 48)
                            .background(story.typeColor.opacity(0.12))
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text(story.title)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(story.typeName)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(story.typeColor.opacity(0.12))
                                .foregroundColor(story.typeColor)
                                .clipShape(Capsule())
                        }
                        
                        Spacer()
                    }
                    
                    Divider()
                    
                    // 故事内容
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 6) {
                            Image(systemName: "text.book.closed.fill")
                                .foregroundColor(.pink)
                            Text("故事内容")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        
                        Text(story.cleanedContent)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineSpacing(8)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.platformGray6)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(20)
            }
            .background(Color.platformGroupedBackground)
            .navigationTitle("故事详情")
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
        .frame(minWidth: 420, idealWidth: 520, minHeight: 400, idealHeight: 550)
        #endif
    }
}
