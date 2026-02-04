//
//  DouyinHotView.swift
//  SwiftUI-news
//
//  Created by v_jinlqi on 2026/1/30.
//
//  抖音热搜榜视图组件

import SwiftUI

// MARK: - String Identifiable 扩展
extension String: @retroactive Identifiable {
    public var id: String { self }
}

// MARK: - 抖音热搜面板
/// 抖音热搜榜单展示面板
struct DouyinHotPanel: View {
    let hotList: [DouyinHotItem]
    let isLoading: Bool
    let error: String?
    let onRefresh: () async -> Void
    let onItemTap: (DouyinHotItem) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 标题栏
            HStack {
                Image(systemName: "flame.fill")
                    .font(.title3)
                    .foregroundStyle(.red.gradient)
                Text("抖音热搜")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button {
                    Task { await onRefresh() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .disabled(isLoading)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            Divider()
                .padding(.horizontal, 16)
            
            // 内容区域
            if isLoading && hotList.isEmpty {
                HStack {
                    Spacer()
                    ProgressView()
                        .padding(.vertical, 40)
                    Spacer()
                }
            } else if let error = error, hotList.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.title2)
                        .foregroundColor(.orange)
                    Text(error)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(Array(hotList.prefix(20).enumerated()), id: \.element.id) { index, item in
                        Button {
                            onItemTap(item)
                        } label: {
                            DouyinHotRowView(item: item, rank: index + 1)
                        }
                        .buttonStyle(.plain)
                        
                        if index < min(hotList.count - 1, 19) {
                            Divider()
                                .padding(.leading, 50)
                        }
                    }
                }
            }
        }
        .background(Color.platformBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - 热搜行视图
/// 单条热搜条目展示
struct DouyinHotRowView: View {
    let item: DouyinHotItem
    let rank: Int
    
    /// 排名颜色
    private var rankColor: Color {
        switch rank {
        case 1: return .red
        case 2: return .orange
        case 3: return .yellow
        default: return .secondary
        }
    }
    
    /// 排名字体权重
    private var rankWeight: Font.Weight {
        rank <= 3 ? .bold : .medium
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // 排名
            Text("\(rank)")
                .font(.system(size: 16, weight: rankWeight))
                .foregroundColor(rankColor)
                .frame(width: 24)
            
            // 内容
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(item.word)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    // 标签
                    if !item.labelText.isEmpty {
                        Text(item.labelText)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(labelBackgroundColor)
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                    }
                }
                
                // 热度
                Text(item.formattedHotindex)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.tertiaryLabel)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }
    
    /// 标签背景色
    private var labelBackgroundColor: Color {
        switch item.label {
        case 1: return .blue
        case 2: return .orange
        case 3: return .red
        default: return .gray
        }
    }
}

// MARK: - 热搜弹窗
/// 完整热搜榜单弹窗
struct DouyinHotSheet: View {
    let hotList: [DouyinHotItem]
    let isLoading: Bool
    let error: String?
    let onRefresh: () async -> Void
    @Environment(\.dismiss) private var dismiss
    
    /// 选中的热搜关键词（用于打开播放器）
    @State private var selectedKeyword: String?
    
    /// 是否显示打开方式选择
    @State private var showOpenOptions: Bool = false
    @State private var pendingKeyword: String = ""
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                if isLoading && hotList.isEmpty {
                    VStack {
                        Spacer(minLength: 100)
                        ProgressView()
                        Spacer()
                    }
                } else if let error = error, hotList.isEmpty {
                    VStack(spacing: 12) {
                        Spacer(minLength: 80)
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Button("重试") {
                            Task { await onRefresh() }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(hotList.enumerated()), id: \.element.id) { index, item in
                            Button {
                                handleItemTap(keyword: item.word)
                            } label: {
                                DouyinHotRowView(item: item, rank: index + 1)
                            }
                            .buttonStyle(.plain)
                            
                            if index < hotList.count - 1 {
                                Divider()
                                    .padding(.leading, 50)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .background(Color.platformGroupedBackground)
            .navigationTitle("抖音热搜榜")
            .platformNavigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") { dismiss() }
                }
                ToolbarItem(placement: .automatic) {
                    Button {
                        Task { await onRefresh() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(isLoading)
                }
            }
            #if os(iOS)
            .fullScreenCover(item: $selectedKeyword) { keyword in
                DouyinPlayerView(keyword: keyword)
            }
            #else
            .sheet(item: $selectedKeyword) { keyword in
                DouyinPlayerView(keyword: keyword)
            }
            #endif
            .confirmationDialog("打开方式", isPresented: $showOpenOptions, titleVisibility: .visible) {
                Button("在App内播放") {
                    selectedKeyword = pendingKeyword
                }
                #if os(iOS)
                if DouyinLauncher.isDouyinInstalled {
                    Button("在抖音App中打开") {
                        openInDouyinApp(keyword: pendingKeyword)
                    }
                }
                #endif
                Button("取消", role: .cancel) {}
            } message: {
                Text("选择如何查看「\(pendingKeyword)」")
            }
        }
        #if os(iOS)
        .presentationDetents([.medium, .large])
        #else
        .frame(minWidth: 400, idealWidth: 450, minHeight: 500, idealHeight: 600)
        #endif
    }
    
    /// 处理热搜点击
    private func handleItemTap(keyword: String) {
        #if os(iOS)
        if DouyinLauncher.isDouyinInstalled {
            // 已安装抖音，显示选择弹窗
            pendingKeyword = keyword
            showOpenOptions = true
        } else {
            // 未安装抖音，直接打开内置播放器
            selectedKeyword = keyword
        }
        #else
        selectedKeyword = keyword
        #endif
    }
    
    #if os(iOS)
    /// 在抖音App中打开
    private func openInDouyinApp(keyword: String) {
        DouyinLauncher.openSearch(keyword: keyword) { success, _ in
            if !success {
                // App打开失败，用内置播放器兜底
                DispatchQueue.main.async {
                    selectedKeyword = keyword
                }
            }
        }
    }
    #endif
}
