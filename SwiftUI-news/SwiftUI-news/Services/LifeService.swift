//
//  LifeService.swift
//  SwiftUI-news
//
//  Created by v_jinlqi on 2026/1/30.
//
//  生活模块服务层 - 天气、旅游景区、BFR体脂率API调用（支持缓存）

import Foundation

// MARK: - 生活服务错误类型
/// 生活服务相关错误
enum LifeServiceError: LocalizedError {
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

// MARK: - 生活服务
/// 生活模块API服务，提供天气、旅游景区、BFR体脂率数据
final class LifeService: Sendable {
    
    /// 单例实例
    static let shared = LifeService()
    
    /// 网络管理器
    private let networkManager = NetworkManager.shared
    
    /// 缓存管理器
    private let cacheManager = DataCacheManager.shared
    
    private init() {}
    
    // MARK: - 天气预报
    
    /// 获取天气预报数据
    /// - Parameters:
    ///   - city: 城市名称
    ///   - forceRefresh: 是否强制刷新
    /// - Returns: 天气预报数据
    func fetchWeather(city: String, forceRefresh: Bool = false) async throws -> WeatherData {
        let cacheKey = CacheKey.weather(city: city)
        
        // 尝试从缓存获取
        if !forceRefresh {
            if let cached = cacheManager.get(WeatherData.self, forKey: cacheKey) {
                return cached
            }
        }
        
        let parameters: [String: Any] = [
            "key": APIConfig.apiKey,
            "city": city,
            "type": 1  // 1=实时天气
        ]
        
        let response: WeatherResponse = try await networkManager.request(
            url: APIConfig.weatherURL,
            method: .GET,
            parameters: parameters
        )
        
        guard response.code == 200, let result = response.result else {
            throw LifeServiceError.apiError(code: response.code, message: response.msg)
        }
        
        // 保存到缓存
        cacheManager.save(result, forKey: cacheKey)
        
        return result
    }
    
    // MARK: - 旅游景区
    
    /// 获取旅游景区列表
    /// - Parameters:
    ///   - keyword: 搜索关键词（景点名称/省份/城市）
    ///   - num: 返回数量（1-15）
    ///   - page: 页码
    ///   - forceRefresh: 是否强制刷新
    /// - Returns: 景区数据列表
    func fetchScenic(keyword: String, num: Int = 10, page: Int = 1, forceRefresh: Bool = false) async throws -> [ScenicData] {
        let cacheKey = CacheKey.scenicList(keyword: keyword, page: page)
        
        // 尝试从缓存获取
        if !forceRefresh {
            if let cached = cacheManager.get([ScenicData].self, forKey: cacheKey) {
                return cached
            }
        }
        
        let parameters: [String: Any] = [
            "key": APIConfig.apiKey,
            "word": keyword,
            "num": num,
            "page": page
        ]
        
        let response: ScenicResponse = try await networkManager.request(
            url: APIConfig.scenicURL,
            method: .GET,
            parameters: parameters
        )
        
        guard response.code == 200, let result = response.result else {
            throw LifeServiceError.apiError(code: response.code, message: response.msg)
        }
        
        // 保存到缓存
        cacheManager.save(result.list, forKey: cacheKey)
        
        return result.list
    }
    
    // MARK: - 实时油价
    
    /// 获取实时油价
    /// - Parameters:
    ///   - province: 省份名称（不要带"省"或"市"字样）
    ///   - forceRefresh: 是否强制刷新
    /// - Returns: 油价数据
    func fetchOilPrice(province: String, forceRefresh: Bool = false) async throws -> OilPriceData {
        let cacheKey = CacheKey.oilPrice(province: province)
        
        // 尝试从缓存获取
        if !forceRefresh {
            if let cached = cacheManager.get(OilPriceData.self, forKey: cacheKey) {
                return cached
            }
        }
        
        let parameters: [String: Any] = [
            "key": APIConfig.apiKey,
            "prov": province
        ]
        
        let response: OilPriceResponse = try await networkManager.request(
            url: APIConfig.oilPriceURL,
            method: .GET,
            parameters: parameters
        )
        
        guard response.code == 200, let result = response.result else {
            throw LifeServiceError.apiError(code: response.code, message: response.msg)
        }
        
        // 保存到缓存
        cacheManager.save(result, forKey: cacheKey)
        
        return result
    }
    
    // MARK: - BFR体脂率
    
    /// 计算BFR体脂率（不缓存，每次实时计算）
    /// - Parameters:
    ///   - age: 年龄
    ///   - height: 身高（厘米）
    ///   - weight: 体重（千克）
    ///   - sex: 性别（0=女性，1=男性）
    /// - Returns: BFR体脂率数据
    func fetchBFR(
        age: Int,
        height: Int,
        weight: Int,
        sex: BFRSex = .male
    ) async throws -> BFRData {
        let parameters: [String: Any] = [
            "key": APIConfig.apiKey,
            "age": age,
            "height": height,
            "weight": weight,
            "sex": sex.rawValue
        ]
        
        let response: BFRResponse = try await networkManager.request(
            url: APIConfig.bfrURL,
            method: .GET,
            parameters: parameters
        )
        
        guard response.code == 200, let result = response.result else {
            throw LifeServiceError.apiError(code: response.code, message: response.msg)
        }
        
        return result
    }
    
    // MARK: - 中药大全
    
    /// 查询中药信息
    /// - Parameters:
    ///   - word: 中药名称
    ///   - forceRefresh: 是否强制刷新
    /// - Returns: 中药数据列表
    func fetchZhongyao(word: String, forceRefresh: Bool = false) async throws -> [ZhongyaoData] {
        let cacheKey = CacheKey.zhongyaoList(page: word.hashValue)
        
        // 尝试从缓存获取
        if !forceRefresh {
            if let cached = cacheManager.get([ZhongyaoData].self, forKey: cacheKey) {
                return cached
            }
        }
        
        let parameters: [String: Any] = [
            "key": APIConfig.apiKey,
            "word": word,
            "num": 10
        ]
        
        let response: ZhongyaoResponse = try await networkManager.request(
            url: APIConfig.zhongyaoURL,
            method: .GET,
            parameters: parameters
        )
        
        guard response.code == 200, let result = response.result else {
            throw LifeServiceError.apiError(code: response.code, message: response.msg)
        }
        
        // 保存到缓存
        cacheManager.save(result.list, forKey: cacheKey)
        
        return result.list
    }
}
