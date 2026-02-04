//
//  NewsViewModel.swift
//  SwiftUI-news
//
//  Created by v_jinlqi on 2026/1/30.
//
//  新闻视图模型 - 管理新闻列表的状态和业务逻辑

import Foundation
import SwiftUI
import Combine

// MARK: - 加载状态
/// 数据加载状态枚举
enum LoadingState: Sendable {
    case idle       // 空闲
    case loading    // 加载中
    case loaded     // 加载完成
    case error(String)  // 错误
}

// MARK: - 新闻视图模型
/// 新闻列表的 ViewModel，管理数据加载和状态
@MainActor
final class NewsViewModel: ObservableObject {
    
    // MARK: - 发布属性
    
    /// 新闻列表
    @Published var newsList: [NewsItem] = []
    
    /// 抖音热搜列表
    @Published var douyinHotList: [DouyinHotItem] = []
    
    /// 是否显示热搜
    @Published var showDouyinHot: Bool = false
    
    /// 热搜加载状态
    @Published var isDouyinHotLoading: Bool = false
    
    /// 热搜错误信息
    @Published var douyinHotError: String?
    
    /// 加载状态
    @Published var loadingState: LoadingState = .idle
    
    /// 当前页码
    @Published var currentPage: Int = 1
    
    /// 是否还有更多数据
    @Published var hasMoreData: Bool = true
    
    /// 搜索关键词
    @Published var searchKeyword: String = ""
    
    /// 当前分类
    @Published var currentCategory: NewsCategory
    
    // MARK: - 私有属性
    
    /// 新闻服务
    private let newsService = NewsService.shared
    
    /// 每页数量
    private let pageSize: Int = 10
    
    // MARK: - 初始化方法
    
    /// 初始化方法
    /// - Parameter initialCategory: 初始分类，默认为国内新闻
    init(initialCategory: NewsCategory = .guonei) {
        self.currentCategory = initialCategory
    }
    
    // MARK: - 公开方法
    
    /// 加载新闻列表（刷新）
    func loadNews() async {
        currentPage = 1
        hasMoreData = true
        loadingState = .loading
        
        do {
            let news = try await newsService.fetchNews(
                category: currentCategory,
                page: currentPage,
                num: pageSize,
                keyword: searchKeyword.isEmpty ? nil : searchKeyword
            )
            
            newsList = news
            hasMoreData = news.count >= pageSize
            loadingState = .loaded
        } catch {
            loadingState = .error(error.localizedDescription)
        }
    }
    
    /// 加载更多新闻（分页）
    func loadMoreNews() async {
        // 防止重复加载
        guard case .loaded = loadingState, hasMoreData else { return }
        
        currentPage += 1
        
        do {
            let news = try await newsService.fetchNews(
                category: currentCategory,
                page: currentPage,
                num: pageSize,
                keyword: searchKeyword.isEmpty ? nil : searchKeyword
            )
            
            newsList.append(contentsOf: news)
            hasMoreData = news.count >= pageSize
        } catch {
            // 加载更多失败时回退页码
            currentPage -= 1
            print("加载更多失败: \(error.localizedDescription)")
        }
    }
    
    /// 切换分类
    /// - Parameter category: 新闻分类
    func switchCategory(_ category: NewsCategory) async {
        guard currentCategory != category else { return }
        currentCategory = category
        searchKeyword = ""
        await loadNews()
    }
    
    /// 搜索新闻
    /// - Parameter keyword: 搜索关键词
    func searchNews(keyword: String) async {
        searchKeyword = keyword
        await loadNews()
    }
    
    /// 刷新新闻列表
    func refresh() async {
        await loadNews()
    }
    
    // MARK: - 抖音热搜方法
    
    /// 加载抖音热搜
    func loadDouyinHot() async {
        isDouyinHotLoading = true
        douyinHotError = nil
        
        do {
            let hotList = try await newsService.fetchDouyinHot()
            douyinHotList = hotList
        } catch {
            douyinHotError = error.localizedDescription
        }
        
        isDouyinHotLoading = false
    }
    
    /// 刷新抖音热搜
    func refreshDouyinHot() async {
        isDouyinHotLoading = true
        douyinHotError = nil
        
        do {
            let hotList = try await newsService.fetchDouyinHot(forceRefresh: true)
            douyinHotList = hotList
        } catch {
            douyinHotError = error.localizedDescription
        }
        
        isDouyinHotLoading = false
    }
    
    /// 切换热搜显示
    func toggleDouyinHot() async {
        showDouyinHot.toggle()
        if showDouyinHot && douyinHotList.isEmpty {
            await loadDouyinHot()
        }
    }
}
