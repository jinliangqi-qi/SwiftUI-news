//
//  StarFortuneViews.swift
//  SwiftUI-news
//
//  Created by v_jinlqi on 2026/1/30.
//
//  星座运势相关视图组件

import SwiftUI

// MARK: - 星座运势内容视图
struct StarFortuneContentView: View {
    let constellation: Constellation
    let items: [StarItem]
    
    /// 指数类型的条目
    private var indexItems: [StarItem] {
        items.filter { $0.isIndex }
    }
    
    /// 非指数类型的条目
    private var otherItems: [StarItem] {
        items.filter { !$0.isIndex && $0.type != "今日概述" }
    }
    
    /// 今日概述
    private var overview: StarItem? {
        items.first { $0.type == "今日概述" }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 星座信息头部
            HStack(spacing: 14) {
                Text(constellation.icon)
                    .font(.system(size: 40))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(constellation.rawValue)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(constellation.dateRange)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            
            // 运势指数网格
            if !indexItems.isEmpty {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(indexItems) { item in
                        FortuneIndexCard(item: item)
                    }
                }
                .padding(.horizontal, 16)
            }
            
            // 其他信息
            if !otherItems.isEmpty {
                HStack(spacing: 0) {
                    ForEach(Array(otherItems.enumerated()), id: \.element.id) { index, item in
                        FortuneInfoItem(item: item)
                        
                        if index < otherItems.count - 1 {
                            Divider()
                                .frame(height: 40)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.platformGray6)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal, 16)
            }
            
            // 今日概述
            if let overview = overview {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 6) {
                        Image(systemName: overview.icon)
                            .foregroundColor(overview.color)
                        Text(overview.type)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    
                    Text(overview.content)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineSpacing(5)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.platformGray6)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal, 16)
            }
        }
        .padding(.bottom, 16)
    }
}

// MARK: - 运势指数卡片
struct FortuneIndexCard: View {
    let item: StarItem
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: item.icon)
                .font(.title3)
                .foregroundColor(item.color)
            
            Text(item.type.replacingOccurrences(of: "指数", with: ""))
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(item.content)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(item.color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(item.color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - 运势信息条目
struct FortuneInfoItem: View {
    let item: StarItem
    
    var body: some View {
        VStack(spacing: 4) {
            Text(item.type)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(item.content)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(item.color)
        }
        .frame(maxWidth: .infinity)
    }
}
