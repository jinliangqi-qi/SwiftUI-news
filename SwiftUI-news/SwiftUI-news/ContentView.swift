//
//  ContentView.swift
//  SwiftUI-news
//
//  Created by v_jinlqi on 2026/1/30.
//
//  主内容视图 - 应用的根视图入口
//  使用 TabBar 进行页面切换

import SwiftUI

// MARK: - 主内容视图
/// 应用的主入口视图，使用 TabBar 管理页面切换
struct ContentView: View {
    var body: some View {
        MainTabView()
    }
}

// MARK: - 预览
#Preview {
    ContentView()
}
