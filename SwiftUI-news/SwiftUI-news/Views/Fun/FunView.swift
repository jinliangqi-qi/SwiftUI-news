//
//  FunView.swift
//  SwiftUI-news
//
//  Created by v_jinlqi on 2026/1/30.
//
//  趣味娱乐页面 - 周公解梦、星座运势等趣味功能

import SwiftUI

// MARK: - 趣味娱乐页面
/// 趣味娱乐主页面
struct FunView: View {
    
    @StateObject private var viewModel = FunViewModel()
    @State private var selectedDream: DreamData?
    @State private var selectedStory: StoryData?
    
    /// 热门梦境关键词
    private let hotDreamKeywords = [
        "蛇", "水", "狗", "猫", "鱼", "死人", "结婚", "怀孕", 
        "掉牙", "飞", "钱", "火", "下雨", "老虎", "龙"
    ]
    
    /// 是否为iPad大屏布局
    private var isWideLayout: Bool {
        DeviceType.current.isIPad || DeviceType.current.isMac
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView(showsIndicators: false) {
                    if isWideLayout && geometry.size.width > 700 {
                        // iPad 双列瀑布流布局
                        HStack(alignment: .top, spacing: 20) {
                            // 左列
                            VStack(spacing: 20) {
                                starFortuneSection
                                dreamSection
                            }
                            .frame(maxWidth: .infinity)
                            
                            // 右列
                            VStack(spacing: 20) {
                                storySection
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(24)
                    } else {
                        // iPhone 单列布局
                        VStack(spacing: 20) {
                            starFortuneSection
                            storySection
                            dreamSection
                        }
                        .padding()
                    }
                }
                .background(Color.platformGroupedBackground)
            }
            .navigationTitle("趣味娱乐")
            .sheet(item: $selectedDream) { dream in
                DreamDetailSheet(dream: dream)
            }
            .sheet(item: $selectedStory) { story in
                StoryDetailSheet(story: story)
            }
        }
        .task {
            await viewModel.fetchStarFortune()
            await viewModel.fetchStory(refresh: true)
        }
    }
    
    // MARK: - 星座运势区域
    
    private var starFortuneSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 标题栏
            HStack {
                Image(systemName: "sparkles")
                    .font(.title2)
                    .foregroundStyle(.orange.gradient)
                Text("星座运势")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
                Text("今日运势")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            
            Divider()
                .padding(.horizontal, 16)
            
            // 星座选择器
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Constellation.allCases) { constellation in
                        ConstellationButton(
                            constellation: constellation,
                            isSelected: viewModel.selectedConstellation == constellation
                        ) {
                            Task { await viewModel.selectConstellation(constellation) }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            
            Divider()
                .padding(.horizontal, 16)
            
            // 运势内容
            if viewModel.isStarLoading {
                HStack {
                    Spacer()
                    ProgressView()
                        .padding(.vertical, 40)
                    Spacer()
                }
            } else if let error = viewModel.starError {
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.title2)
                        .foregroundColor(.orange)
                    Text(error)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else if !viewModel.starFortune.isEmpty {
                StarFortuneContentView(
                    constellation: viewModel.selectedConstellation,
                    items: viewModel.starFortune
                )
            }
        }
        .background(Color.platformBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - 故事大全区域
    
    private var storySection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 标题栏
            HStack {
                Image(systemName: "book.pages.fill")
                    .font(.title2)
                    .foregroundStyle(.pink.gradient)
                Text("故事大全")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            
            Divider()
                .padding(.horizontal, 16)
            
            // 故事类型选择器
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(StoryType.allCases) { type in
                        StoryTypeButton(
                            type: type,
                            isSelected: viewModel.selectedStoryType == type
                        ) {
                            Task { await viewModel.selectStoryType(type) }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            
            Divider()
                .padding(.horizontal, 16)
            
            // 搜索框
            HStack(spacing: 12) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("搜索故事标题...", text: $viewModel.storyKeyword)
                        .textFieldStyle(.plain)
                        .submitLabel(.search)
                        .onSubmit {
                            Task { await viewModel.fetchStory(refresh: true) }
                        }
                    
                    if !viewModel.storyKeyword.isEmpty {
                        Button {
                            viewModel.clearStorySearch()
                            Task { await viewModel.fetchStory(refresh: true) }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(10)
                .background(Color.platformGray6)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                Button {
                    Task { await viewModel.fetchStory(refresh: true) }
                } label: {
                    Text("搜索")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.pink)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }
            .padding(16)
            
            // 故事列表
            if viewModel.isStoryLoading && viewModel.storyList.isEmpty {
                HStack {
                    Spacer()
                    ProgressView()
                        .padding(.vertical, 40)
                    Spacer()
                }
            } else if let error = viewModel.storyError, viewModel.storyList.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.title2)
                        .foregroundColor(.orange)
                    Text(error)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else if !viewModel.storyList.isEmpty {
                LazyVStack(spacing: 0) {
                    ForEach(Array(viewModel.storyList.enumerated()), id: \.element.id) { index, story in
                        Button {
                            selectedStory = story
                        } label: {
                            StoryRowView(story: story)
                        }
                        .buttonStyle(.plain)
                        .onAppear {
                            // 当倒数第3项出现时自动加载更多
                            if index >= viewModel.storyList.count - 3 && viewModel.hasMoreStory && !viewModel.isStoryLoading {
                                Task { await viewModel.loadMoreStory() }
                            }
                        }
                        
                        if index < viewModel.storyList.count - 1 {
                            Divider()
                                .padding(.leading, 60)
                        }
                    }
                    
                    // 加载状态指示器
                    if viewModel.hasMoreStory {
                        HStack {
                            Spacer()
                            if viewModel.isStoryLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("加载中...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 12)
                    } else if viewModel.storyList.count > 0 {
                        Text("已加载全部")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                }
            }
        }
        .background(Color.platformBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - 周公解梦区域
    
    private var dreamSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 标题栏
            HStack {
                Image(systemName: "moon.stars.fill")
                    .font(.title2)
                    .foregroundStyle(.purple.gradient)
                Text("周公解梦")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            
            Divider()
                .padding(.horizontal, 16)
            
            // 搜索框
            HStack(spacing: 12) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("输入梦境关键词，如：蛇、水、飞...", text: $viewModel.dreamKeyword)
                        .textFieldStyle(.plain)
                        .submitLabel(.search)
                        .onSubmit {
                            Task { await viewModel.searchDream() }
                        }
                    
                    if !viewModel.dreamKeyword.isEmpty {
                        Button {
                            viewModel.clearDreamResults()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(10)
                .background(Color.platformGray6)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                Button {
                    Task { await viewModel.searchDream() }
                } label: {
                    Text("解梦")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.purple)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
                .disabled(viewModel.dreamKeyword.trimmingCharacters(in: .whitespaces).isEmpty)
                .opacity(viewModel.dreamKeyword.trimmingCharacters(in: .whitespaces).isEmpty ? 0.6 : 1)
            }
            .padding(16)
            
            // 热门梦境标签
            if !viewModel.hasSearched {
                VStack(alignment: .leading, spacing: 10) {
                    Text("热门梦境")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    FlowLayout(spacing: 8) {
                        ForEach(hotDreamKeywords, id: \.self) { keyword in
                            Button {
                                viewModel.dreamKeyword = keyword
                                Task { await viewModel.searchDream() }
                            } label: {
                                Text(keyword)
                                    .font(.subheadline)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 7)
                                    .background(Color.purple.opacity(0.1))
                                    .foregroundColor(.purple)
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            
            // 搜索结果
            if viewModel.isDreamLoading {
                HStack {
                    Spacer()
                    ProgressView()
                        .padding(.vertical, 30)
                    Spacer()
                }
            } else if let error = viewModel.dreamError {
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
            } else if viewModel.hasSearched && viewModel.dreamResults.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "moon.zzz")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    Text("未找到相关解梦")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
            } else if !viewModel.dreamResults.isEmpty {
                VStack(spacing: 0) {
                    ForEach(Array(viewModel.dreamResults.enumerated()), id: \.element.id) { index, dream in
                        Button {
                            selectedDream = dream
                        } label: {
                            DreamRowView(dream: dream)
                        }
                        .buttonStyle(.plain)
                        
                        if index < viewModel.dreamResults.count - 1 {
                            Divider()
                                .padding(.leading, 60)
                        }
                    }
                }
            }
        }
        .background(Color.platformBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - 预览
#Preview {
    FunView()
}
