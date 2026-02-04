//
//  NewsService.swift
//  SwiftUI-news
//
//  Created by v_jinlqi on 2026/1/30.
//
//  新闻服务层 - 封装新闻相关的网络请求（支持缓存）

import Foundation

// MARK: - 新闻服务
/// 新闻数据服务类，封装所有新闻相关的API调用
final class NewsService: Sendable {
    
    /// 单例实例
    static let shared = NewsService()
    
    /// 网络管理器
    private let networkManager = NetworkManager.shared
    
    /// 缓存管理器
    private let cacheManager = DataCacheManager.shared
    
    private init() {}
    
    // MARK: - 获取新闻列表（通用方法）
    /// 根据分类获取新闻列表
    /// - Parameters:
    ///   - category: 新闻分类
    ///   - page: 页码，默认为1
    ///   - num: 返回数量，默认为10，最大50
    ///   - keyword: 搜索关键词（可选）
    ///   - forceRefresh: 是否强制刷新（忽略缓存）
    /// - Returns: 新闻列表
    func fetchNews(
        category: NewsCategory,
        page: Int = 1,
        num: Int = 10,
        keyword: String? = nil,
        forceRefresh: Bool = false
    ) async throws -> [NewsItem] {
        
        // 搜索时不使用缓存
        let useCache = keyword == nil || keyword?.isEmpty == true
        let cacheKey = CacheKey.newsList(category: category.rawValue, page: page)
        
        // 尝试从缓存获取（非强制刷新且无搜索关键词时）
        if useCache && !forceRefresh {
            if let cached = cacheManager.get([NewsItem].self, forKey: cacheKey) {
                return cached
            }
        }
        
        // 构建请求参数
        var parameters: [String: Any] = [
            "key": APIConfig.apiKey,
            "num": num,
            "page": page
        ]
        
        // 添加搜索关键词
        if let keyword = keyword, !keyword.isEmpty {
            parameters["word"] = keyword
        }
        
        // 发起请求
        let response: APIResponse = try await networkManager.request(
            url: APIConfig.newsURL(for: category),
            method: .GET,
            parameters: parameters
        )
        
        // 检查响应状态
        guard response.code == 200 else {
            throw NewsServiceError.apiError(code: response.code, message: response.msg)
        }
        
        // 检查是否有数据
        guard let result = response.result else {
            throw NewsServiceError.noData
        }
        
        let newsList = result.newsList
        
        // 保存到缓存（无搜索关键词时）
        if useCache {
            cacheManager.save(newsList, forKey: cacheKey)
        }
        
        return newsList
    }
    
    // MARK: - 获取抖音热搜榜
    /// 获取抖音热搜榜单
    /// - Parameter forceRefresh: 是否强制刷新（忽略缓存）
    /// - Returns: 热搜列表
    func fetchDouyinHot(forceRefresh: Bool = false) async throws -> [DouyinHotItem] {
        let cacheKey = CacheKey.douyinHot
        
        // 尝试从缓存获取
        if !forceRefresh {
            if let cached = cacheManager.get([DouyinHotItem].self, forKey: cacheKey) {
                return cached
            }
        }
        
        // 构建请求参数
        let parameters: [String: Any] = [
            "key": APIConfig.apiKey
        ]
        
        // 发起请求
        let response: DouyinHotResponse = try await networkManager.request(
            url: APIConfig.douyinHotURL,
            method: .GET,
            parameters: parameters
        )
        
        // 检查响应状态
        guard response.code == 200 else {
            throw NewsServiceError.apiError(code: response.code, message: response.msg)
        }
        
        // 检查是否有数据
        guard let result = response.result else {
            throw NewsServiceError.noData
        }
        
        let hotList = result.list
        
        // 保存到缓存
        cacheManager.save(hotList, forKey: cacheKey)
        
        return hotList
    }
}

// MARK: - 新闻服务错误
/// 新闻服务相关错误类型
enum NewsServiceError: Error, LocalizedError {
    case apiError(code: Int, message: String)  // API返回错误
    case noData  // 无数据
    
    var errorDescription: String? {
        switch self {
        case .apiError(let code, let message):
            return "API错误[\(code)]: \(message)"
        case .noData:
            return "暂无数据"
        }
    }
}
