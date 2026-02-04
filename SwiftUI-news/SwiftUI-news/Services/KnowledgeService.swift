//
//  KnowledgeService.swift
//  SwiftUI-news
//
//  Created by v_jinlqi on 2026/1/30.
//
//  知识模块服务层 - 脑筋急转弯、百科题库API调用（支持缓存）

import Foundation

// MARK: - 知识服务错误类型
/// 知识服务相关错误
enum KnowledgeServiceError: LocalizedError {
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

// MARK: - 知识服务
/// 知识模块API服务，提供脑筋急转弯、百科题库等数据
final class KnowledgeService: Sendable {
    
    /// 单例实例
    static let shared = KnowledgeService()
    
    /// 网络管理器
    private let networkManager = NetworkManager.shared
    
    /// 缓存管理器
    private let cacheManager = DataCacheManager.shared
    
    private init() {}
    
    // MARK: - 脑筋急转弯
    
    /// 获取脑筋急转弯列表
    /// - Parameters:
    ///   - num: 返回数量（1-10）
    ///   - page: 页码
    ///   - forceRefresh: 是否强制刷新
    /// - Returns: 脑筋急转弯数据列表
    func fetchBrainTeaser(num: Int = 10, page: Int = 1, forceRefresh: Bool = false) async throws -> [BrainTeaserData] {
        let cacheKey = CacheKey.brainTeaserList(page: page)
        
        // 尝试从缓存获取
        if !forceRefresh {
            if let cached = cacheManager.get([BrainTeaserData].self, forKey: cacheKey) {
                return cached
            }
        }
        
        let parameters: [String: Any] = [
            "key": APIConfig.apiKey,
            "num": num,
            "page": page
        ]
        
        let response: BrainTeaserResponse = try await networkManager.request(
            url: APIConfig.brainTeaserURL,
            method: .GET,
            parameters: parameters
        )
        
        guard response.code == 200, let result = response.result else {
            throw KnowledgeServiceError.apiError(code: response.code, message: response.msg)
        }
        
        // 保存到缓存
        cacheManager.save(result.list, forKey: cacheKey)
        
        return result.list
    }
    
    // MARK: - 百科题库
    
    /// 获取百科题目（每次返回一道随机题目）
    /// - Parameter forceRefresh: 是否强制刷新
    /// - Returns: 百科题目数据
    func fetchQuiz(forceRefresh: Bool = false) async throws -> QuizData {
        let cacheKey = CacheKey.quiz
        
        // 尝试从缓存获取
        if !forceRefresh {
            if let cached = cacheManager.get(QuizData.self, forKey: cacheKey) {
                return cached
            }
        }
        
        let parameters: [String: Any] = [
            "key": APIConfig.apiKey
        ]
        
        let response: QuizResponse = try await networkManager.request(
            url: APIConfig.quizURL,
            method: .GET,
            parameters: parameters
        )
        
        guard response.code == 200, let result = response.result else {
            throw KnowledgeServiceError.apiError(code: response.code, message: response.msg)
        }
        
        // 保存到缓存
        cacheManager.save(result, forKey: cacheKey)
        
        return result
    }
}
