//
//  NewsRowView.swift
//  SwiftUI-news
//
//  Created by v_jinlqi on 2026/1/30.
//
//  新闻行视图 - 支持列表和网格两种布局样式

import SwiftUI

// MARK: - 布局类型枚举
/// 新闻列表布局类型
enum NewsLayoutType: String, CaseIterable {
    case list = "list"      // 列表布局
    case grid = "grid"      // 网格布局
    
    /// 布局图标
    var icon: String {
        switch self {
        case .list: return "list.bullet"
        case .grid: return "square.grid.2x2"
        }
    }
    
    /// 切换到另一种布局
    var toggled: NewsLayoutType {
        switch self {
        case .list: return .grid
        case .grid: return .list
        }
    }
}

// MARK: - 新闻行视图（列表样式）
/// 新闻列表中单行的展示视图（左图右文样式）
struct NewsRowView: View {
    
    /// 新闻数据
    let news: NewsItem
    
    /// 是否有图片
    private var hasPicture: Bool {
        !news.picUrl.isEmpty
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // 左侧缩略图（仅有图片时显示）
            if hasPicture {
                CachedAsyncImage(url: news.picUrl, placeholder: "newspaper")
                    .frame(width: 100, height: 75)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            // 右侧内容区
            VStack(alignment: .leading, spacing: 6) {
                // 标题
                Text(news.title)
                    .font(.system(size: 15, weight: .medium))
                    .lineLimit(hasPicture ? 2 : 3)
                    .foregroundColor(.primary)
                
                Spacer(minLength: 0)
                
                // 底部信息栏
                HStack(spacing: 8) {
                    // 来源
                    Text(news.source)
                        .font(.system(size: 11))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.8))
                        .clipShape(Capsule())
                    
                    Spacer()
                    
                    // 时间
                    Text(news.ctime)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(10)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: Color.primary.opacity(0.08), radius: 4, x: 0, y: 2)
    }
}

// MARK: - 新闻网格视图
/// 新闻网格布局中单个卡片的展示视图
struct NewsGridView: View {
    
    /// 新闻数据
    let news: NewsItem
    
    /// 是否有图片
    private var hasPicture: Bool {
        !news.picUrl.isEmpty
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 顶部图片（仅有图片时显示）
            if hasPicture {
                CachedAsyncImage(url: news.picUrl, placeholder: "newspaper")
                    .frame(height: 100)
                    .frame(maxWidth: .infinity)
                    .clipped()
            }
            
            // 底部内容区
            VStack(alignment: .leading, spacing: 6) {
                // 标题
                Text(news.title)
                    .font(.system(size: 13, weight: .medium))
                    .lineLimit(hasPicture ? 2 : 4)
                    .foregroundColor(.primary)
                
                Spacer(minLength: 0)
                
                // 来源和时间
                HStack {
                    Text(news.source)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(formatTime(news.ctime))
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            }
            .padding(8)
            .frame(minHeight: hasPicture ? 70 : 100)
        }
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: Color.primary.opacity(0.08), radius: 4, x: 0, y: 2)
    }
    
    /// 格式化时间（简化显示）
    private func formatTime(_ time: String) -> String {
        // 只显示月-日 时:分
        let components = time.split(separator: " ")
        if components.count >= 2 {
            let datePart = components[0].split(separator: "-")
            if datePart.count >= 3 {
                return "\(datePart[1])-\(datePart[2])"
            }
        }
        return time
    }
}

// MARK: - 预览
#Preview("列表样式") {
    NewsRowView(news: NewsItem.preview)
        .padding()
        .background(Color.platformGroupedBackground)
}

#Preview("网格样式") {
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
        NewsGridView(news: NewsItem.preview)
        NewsGridView(news: NewsItem.preview)
    }
    .padding()
    .background(Color.platformGroupedBackground)
}
