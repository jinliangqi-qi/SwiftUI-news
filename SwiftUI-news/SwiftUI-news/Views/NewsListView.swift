//
//  NewsListView.swift
//  SwiftUI-news
//
//  Created by v_jinlqi on 2026/1/30.
//
//  新闻列表视图 - 支持横向滑动切换分类、列表/网格切换、下拉刷新和加载更多

import SwiftUI
import Combine

// MARK: - 新闻列表视图
/// 主要的新闻列表展示视图，支持横向滑动切换分类
struct NewsListView: View {
    
    /// 当前选中的分类索引
    @State private var selectedCategoryIndex: Int = 0
    
    /// 所有分类
    private let categories = NewsCategory.allCases
    
    /// 当前选中的新闻URL（用于打开WebView）
    @State private var selectedNewsURL: URL?
    
    /// 当前布局类型
    @State private var layoutType: NewsLayoutType = .list
    
    /// 是否显示热搜弹窗
    @State private var showDouyinHotSheet: Bool = false
    
    /// 热搜ViewModel（共享）
    @StateObject private var hotViewModel = DouyinHotViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 顶部分类标签栏
                categoryTabBar
                
                // 横向滑动的分类内容
                categoryPagerView
            }
            .navigationTitle("新闻资讯")
            .platformNavigationBarTitleDisplayMode(.inline)
            .toolbar {
                // 热搜按钮
                ToolbarItem(placement: .automatic) {
                    douyinHotButton
                }
                // 布局切换按钮
                ToolbarItem(placement: .automatic) {
                    layoutSwitchButton
                }
            }
            .sheet(item: $selectedNewsURL) { url in
                SafariView(url: url)
                    .ignoresSafeArea()
            }
            .sheet(isPresented: $showDouyinHotSheet) {
                DouyinHotSheet(
                    hotList: hotViewModel.hotList,
                    isLoading: hotViewModel.isLoading,
                    error: hotViewModel.error,
                    onRefresh: { await hotViewModel.refresh() }
                )
            }
        }
        .task {
            // 预加载热搜数据
            if hotViewModel.hotList.isEmpty {
                await hotViewModel.load()
            }
        }
    }
    
    // MARK: - 分类标签栏
    
    /// 顶部可滚动的分类标签栏
    private var categoryTabBar: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(Array(categories.enumerated()), id: \.element.id) { index, category in
                        categoryTabItem(category: category, index: index)
                            .id(index)
                    }
                }
                .padding(.horizontal, 12)
            }
            .background(Color.platformBackground)
            .onChange(of: selectedCategoryIndex) { _, newIndex in
                withAnimation(.easeInOut(duration: 0.3)) {
                    proxy.scrollTo(newIndex, anchor: .center)
                }
            }
        }
        .frame(height: 44)
    }
    
    /// 单个分类标签项
    private func categoryTabItem(category: NewsCategory, index: Int) -> some View {
        let isSelected = index == selectedCategoryIndex
        
        return Button {
            withAnimation(.easeInOut(duration: 0.25)) {
                selectedCategoryIndex = index
            }
        } label: {
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: category.icon)
                        .font(.system(size: 12))
                    Text(category.displayName)
                        .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                }
                .foregroundColor(isSelected ? .blue : .secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                
                // 选中指示条
                Rectangle()
                    .fill(isSelected ? Color.blue : Color.clear)
                    .frame(height: 2)
                    .cornerRadius(1)
            }
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - 横向分页视图
    
    /// 横向滑动的分类内容区域
    private var categoryPagerView: some View {
        #if os(iOS)
        TabView(selection: $selectedCategoryIndex) {
            ForEach(Array(categories.enumerated()), id: \.element.id) { index, category in
                NewsCategoryPageView(
                    category: category,
                    layoutType: $layoutType,
                    selectedNewsURL: $selectedNewsURL
                )
                .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .background(Color.platformGroupedBackground)
        #else
        // macOS: 直接显示当前分类内容，不使用TabView
        NewsCategoryPageView(
            category: categories[selectedCategoryIndex],
            layoutType: $layoutType,
            selectedNewsURL: $selectedNewsURL
        )
        .id(selectedCategoryIndex) // 切换时重建视图
        .background(Color.platformGroupedBackground)
        #endif
    }
    
    // MARK: - 抖音热搜按钮
    
    /// 导航栏热搜按钮
    private var douyinHotButton: some View {
        Button {
            showDouyinHotSheet = true
        } label: {
            Image(systemName: "flame.fill")
                .font(.system(size: 16))
                .foregroundStyle(.red.gradient)
        }
    }
    
    // MARK: - 布局切换按钮
    
    /// 导航栏布局切换按钮
    private var layoutSwitchButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.25)) {
                layoutType = layoutType.toggled
            }
        } label: {
            Image(systemName: layoutType.toggled.icon)
                .font(.system(size: 16))
                .foregroundColor(.primary)
        }
    }
}

// MARK: - 单个分类页面视图
/// 每个分类对应的独立页面，有独立的ViewModel
struct NewsCategoryPageView: View {
    
    let category: NewsCategory
    @Binding var layoutType: NewsLayoutType
    @Binding var selectedNewsURL: URL?
    
    /// 该分类的独立ViewModel
    @StateObject private var viewModel: NewsViewModel
    
    init(category: NewsCategory, layoutType: Binding<NewsLayoutType>, selectedNewsURL: Binding<URL?>) {
        self.category = category
        self._layoutType = layoutType
        self._selectedNewsURL = selectedNewsURL
        self._viewModel = StateObject(wrappedValue: NewsViewModel(initialCategory: category))
    }
    
    var body: some View {
        contentView
            .task {
                if viewModel.newsList.isEmpty {
                    await viewModel.loadNews()
                }
            }
    }
    
    // MARK: - 内容视图
    
    @ViewBuilder
    private var contentView: some View {
        switch viewModel.loadingState {
        case .idle, .loading:
            loadingView
            
        case .loaded:
            if viewModel.newsList.isEmpty {
                emptyView
            } else {
                newsListContent
            }
            
        case .error(let message):
            errorView(message: message)
        }
    }
    
    // MARK: - 新闻内容区域
    
    private var newsListContent: some View {
        Group {
            switch layoutType {
            case .list:
                ScrollView {
                    listLayoutView
                        .padding(.horizontal, DeviceType.current.isIPad ? 24 : 16)
                        .padding(.vertical, 12)
                }
                .background(Color.platformGroupedBackground)
                .refreshable {
                    await viewModel.refresh()
                }
            case .grid:
                gridLayoutView
                    .background(Color.platformGroupedBackground)
                    .refreshable {
                        await viewModel.refresh()
                    }
            }
        }
    }
    
    private var listLayoutView: some View {
        LazyVStack(spacing: 12) {
            ForEach(viewModel.newsList) { news in
                NewsRowView(news: news)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        openNews(news)
                    }
                    .onAppear {
                        checkLoadMore(news)
                    }
            }
            
            // 底部加载状态
            bottomLoadingIndicator
        }
    }
    
    private var gridLayoutView: some View {
        GeometryReader { geometry in
            let columns = AdaptiveGridColumns.newsColumns(for: geometry.size.width)
            let columnCount = columns.count
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(viewModel.newsList) { news in
                        NewsGridView(news: news)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                openNews(news)
                            }
                            .onAppear {
                                checkLoadMore(news)
                            }
                    }
                    
                    // 底部加载状态
                    bottomLoadingIndicator
                        .gridCellColumns(columnCount)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
    }
    
    // MARK: - 辅助方法
    
    private func openNews(_ news: NewsItem) {
        if let url = URL(string: news.url) {
            selectedNewsURL = url
        }
    }
    
    private func checkLoadMore(_ news: NewsItem) {
        if news.id == viewModel.newsList.suffix(3).first?.id {
            Task {
                await viewModel.loadMoreNews()
            }
        }
    }
    
    // MARK: - 状态视图
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.2)
            Text("正在加载...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.platformGroupedBackground)
    }
    
    private func errorView(message: String) -> some View {
        let isNoData = message.contains("暂无数据")
        
        return VStack(spacing: 20) {
            Image(systemName: isNoData ? "doc.text.magnifyingglass" : "wifi.exclamationmark")
                .font(.system(size: 60))
                .foregroundStyle(isNoData ? Color.gray.gradient : Color.orange.gradient)
            
            Text(isNoData ? "暂无数据" : "加载失败")
                .font(.title3)
                .fontWeight(.medium)
            
            Text(isNoData ? "未找到相关内容，换个关键词试试" : message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button {
                Task { await viewModel.loadNews() }
            } label: {
                Text("重新加载")
                    .fontWeight(.medium)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.platformGroupedBackground)
    }
    
    private var loadMoreIndicator: some View {
        HStack(spacing: 8) {
            ProgressView()
            Text("加载中...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }
    
    @ViewBuilder
    private var bottomLoadingIndicator: some View {
        if viewModel.hasMoreData {
            loadMoreIndicator
        } else if !viewModel.newsList.isEmpty {
            Text("已加载全部")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
        }
    }
    
    private var emptyView: some View {
        VStack(spacing: 20) {
            Image(systemName: category.icon)
                .font(.system(size: 60))
                .foregroundStyle(.gray.gradient)
            
            Text("暂无\(category.displayName)新闻")
                .font(.title3)
                .fontWeight(.medium)
            
            Button {
                Task { await viewModel.loadNews() }
            } label: {
                Text("刷新")
                    .fontWeight(.medium)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.platformGroupedBackground)
    }
}

// MARK: - 抖音热搜ViewModel
/// 独立的热搜ViewModel，用于在NewsListView中共享
@MainActor
final class DouyinHotViewModel: ObservableObject {
    @Published var hotList: [DouyinHotItem] = []
    @Published var isLoading: Bool = false
    @Published var error: String?
    
    private let newsService = NewsService.shared
    
    func load() async {
        isLoading = true
        error = nil
        
        do {
            hotList = try await newsService.fetchDouyinHot()
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func refresh() async {
        isLoading = true
        error = nil
        
        do {
            hotList = try await newsService.fetchDouyinHot(forceRefresh: true)
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
}

// MARK: - URL Identifiable 扩展
extension URL: @retroactive Identifiable {
    public var id: String { absoluteString }
}

// MARK: - 预览
#Preview {
    NewsListView()
}
