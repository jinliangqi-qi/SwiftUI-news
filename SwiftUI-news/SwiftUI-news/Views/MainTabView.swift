//
//  MainTabView.swift
//  SwiftUI-news
//
//  Created by v_jinlqi on 2026/1/30.
//
//  主TabBar视图 - 应用底部导航栏，控制不同页面的切换

import SwiftUI

// MARK: - Tab 类型枚举
/// 定义所有 Tab 页面类型
enum TabType: Int, CaseIterable, Identifiable {
    case news = 0       // 新闻首页
    case life = 1       // 生活页面
    case knowledge = 2  // 知识页面
    case fun = 3        // 趣味娱乐
    
    var id: Int { rawValue }
    
    /// Tab 标题
    var title: String {
        switch self {
        case .news: return "新闻"
        case .life: return "生活"
        case .knowledge: return "知识"
        case .fun: return "趣味娱乐"
        }
    }
    
    /// Tab 图标
    var icon: String {
        switch self {
        case .news: return "newspaper"
        case .life: return "leaf"
        case .knowledge: return "book"
        case .fun: return "sparkles"
        }
    }
    
    /// Tab 选中图标
    var selectedIcon: String {
        switch self {
        case .news: return "newspaper.fill"
        case .life: return "leaf.fill"
        case .knowledge: return "book.fill"
        case .fun: return "sparkles"
        }
    }
}

// MARK: - 主TabBar视图
/// 应用主入口TabBar，管理底部标签页切换
struct MainTabView: View {
    
    /// 当前选中的Tab
    @State private var selectedTab: TabType = .news
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 新闻页面
            NewsListView()
                .tabItem {
                    tabItemLabel(for: .news)
                }
                .tag(TabType.news)
            
            // 生活页面
            LifeView()
                .tabItem {
                    tabItemLabel(for: .life)
                }
                .tag(TabType.life)
            
            // 知识页面
            KnowledgeView()
                .tabItem {
                    tabItemLabel(for: .knowledge)
                }
                .tag(TabType.knowledge)
            
            // 趣味娱乐页面
            FunView()
                .tabItem {
                    tabItemLabel(for: .fun)
                }
                .tag(TabType.fun)
        }
        .tint(.blue)
    }
    
    // MARK: - 私有方法
    
    /// 创建Tab标签
    /// - Parameter type: Tab类型
    /// - Returns: 标签视图
    @ViewBuilder
    private func tabItemLabel(for type: TabType) -> some View {
        Label {
            Text(type.title)
        } icon: {
            Image(systemName: selectedTab == type ? type.selectedIcon : type.icon)
        }
    }
}

// MARK: - 预览
#Preview {
    MainTabView()
}
