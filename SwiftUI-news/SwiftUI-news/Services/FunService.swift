//
//  FunService.swift
//  SwiftUI-news
//
//  Created by v_jinlqi on 2026/1/30.
//
//  趣味娱乐模块服务层 - 周公解梦、星座运势API调用（支持缓存）

import Foundation

// MARK: - 趣味娱乐服务错误类型
/// 趣味娱乐服务相关错误
enum FunServiceError: LocalizedError {
    case apiError(code: Int, message: String)
    case noData
    
    var errorDescription: String? {
        switch self {
        case .apiError(_, let message):
            return message
        case .noData:
            return "暂无数据"
        }
    }
}

// MARK: - 趣味娱乐服务
/// 趣味娱乐模块API服务，提供周公解梦、星座运势等数据
final class FunService: Sendable {
    
    /// 单例实例
    static let shared = FunService()
    
    /// 网络管理器
    private let networkManager = NetworkManager.shared
    
    /// 缓存管理器
    private let cacheManager = DataCacheManager.shared
    
    private init() {}
    
    // MARK: - 周公解梦
    
    /// 搜索解梦
    /// - Parameters:
    ///   - word: 梦境关键词
    ///   - num: 返回数量
    ///   - page: 页码
    ///   - forceRefresh: 是否强制刷新
    /// - Returns: 解梦数据列表
    func fetchDream(word: String, num: Int = 10, page: Int = 1, forceRefresh: Bool = false) async throws -> [DreamData] {
        let cacheKey = CacheKey.dreamSearch(keyword: word)
        
        // 尝试从缓存获取
        if !forceRefresh {
            if let cached = cacheManager.get([DreamData].self, forKey: cacheKey) {
                return cached
            }
        }
        
        let parameters: [String: Any] = [
            "key": APIConfig.apiKey,
            "word": word,
            "num": num,
            "page": page
        ]
        
        let response: DreamResponse = try await networkManager.request(
            url: APIConfig.dreamURL,
            method: .GET,
            parameters: parameters
        )
        
        guard response.code == 200, let result = response.result else {
            throw FunServiceError.apiError(code: response.code, message: response.msg)
        }
        
        // 保存到缓存
        cacheManager.save(result.list, forKey: cacheKey)
        
        return result.list
    }
    
    // MARK: - 星座运势
    
    /// 获取星座运势
    /// - Parameters:
    ///   - constellation: 星座
    ///   - date: 查询日期（可选，默认今天）
    ///   - forceRefresh: 是否强制刷新
    /// - Returns: 星座运势数据列表
    func fetchStarFortune(constellation: Constellation, date: String? = nil, forceRefresh: Bool = false) async throws -> [StarItem] {
        // 获取今天日期作为缓存key的一部分
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let today = date ?? dateFormatter.string(from: Date())
        
        let cacheKey = CacheKey.starFortune(constellation: constellation.rawValue, date: today)
        
        // 尝试从缓存获取
        if !forceRefresh {
            if let cached = cacheManager.get([StarItem].self, forKey: cacheKey) {
                return cached
            }
        }
        
        var parameters: [String: Any] = [
            "key": APIConfig.apiKey,
            "astro": constellation.rawValue
        ]
        
        if let date = date {
            parameters["date"] = date
        }
        
        let response: StarResponse = try await networkManager.request(
            url: APIConfig.starURL,
            method: .GET,
            parameters: parameters
        )
        
        guard response.code == 200, let result = response.result else {
            throw FunServiceError.apiError(code: response.code, message: response.msg)
        }
        
        // 保存到缓存
        cacheManager.save(result.list, forKey: cacheKey)
        
        return result.list
    }
    
    // MARK: - 故事大全
    
    /// 获取故事列表
    /// - Parameters:
    ///   - type: 故事类型（1-成语、2-睡前、3-童话、4-寓言）
    ///   - word: 故事标题关键词（可选）
    ///   - num: 返回数量
    ///   - page: 页码
    ///   - forceRefresh: 是否强制刷新
    /// - Returns: 故事数据列表
    func fetchStory(type: StoryType, word: String = "", num: Int = 10, page: Int = 1, forceRefresh: Bool = false) async throws -> [StoryData] {
        let cacheKey = CacheKey.storyList(type: type.rawValue, keyword: word, page: page)
        
        // 尝试从缓存获取
        if !forceRefresh {
            if let cached = cacheManager.get([StoryData].self, forKey: cacheKey) {
                return cached
            }
        }
        
        var parameters: [String: Any] = [
            "key": APIConfig.apiKey,
            "type": type.rawValue,
            "num": num,
            "page": page
        ]
        
        if !word.isEmpty {
            parameters["word"] = word
        }
        
        let response: StoryResponse = try await networkManager.request(
            url: APIConfig.storyURL,
            method: .GET,
            parameters: parameters
        )
        
        guard response.code == 200, let result = response.result else {
            throw FunServiceError.apiError(code: response.code, message: response.msg)
        }
        
        // 保存到缓存
        cacheManager.save(result.list, forKey: cacheKey)
        
        return result.list
    }
}
