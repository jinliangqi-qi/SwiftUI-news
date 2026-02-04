//
//  APIConfig.swift
//  SwiftUI-news
//
//  Created by v_jinlqi on 2026/1/30.
//
//  API 配置文件 - 存放接口地址和密钥配置

import Foundation

// MARK: - 新闻分类枚举
/// 新闻分类类型，对应不同的API接口
enum NewsCategory: String, CaseIterable, Identifiable {
    case guonei = "guonei"             // 国内新闻
    case social = "social"             // 社会新闻
    case world = "world"               // 国际新闻
    case internet = "internet"         // 互联网资讯
    case entertainment = "huabian"     // 娱乐新闻
    case it = "it"                     // IT资讯
    case general = "generalnews"       // 综合新闻
    case ai = "ai"                     // AI资讯
    case game = "game"                 // 游戏资讯
    case anime = "dongman"             // 动漫资讯
    case film = "film"                 // 影视资讯
    case military = "military"         // 军事新闻
    case science = "sicprobe"          // 科学探索
    
    var id: String { rawValue }
    
    /// 分类显示名称
    var displayName: String {
        switch self {
        case .guonei: return "国内"
        case .social: return "社会"
        case .world: return "国际"
        case .internet: return "互联网"
        case .entertainment: return "娱乐"
        case .it: return "IT"
        case .general: return "综合"
        case .ai: return "AI"
        case .game: return "游戏"
        case .anime: return "动漫"
        case .film: return "影视"
        case .military: return "军事"
        case .science: return "科学"
        }
    }
    
    /// 分类图标
    var icon: String {
        switch self {
        case .guonei: return "flag.fill"
        case .social: return "person.3.fill"
        case .world: return "globe.asia.australia.fill"
        case .internet: return "network"
        case .entertainment: return "star.fill"
        case .it: return "laptopcomputer"
        case .general: return "newspaper.fill"
        case .ai: return "brain.head.profile"
        case .game: return "gamecontroller.fill"
        case .anime: return "sparkles.tv.fill"
        case .film: return "film.fill"
        case .military: return "shield.fill"
        case .science: return "atom"
        }
    }
    
    /// 接口路径
    var apiPath: String {
        return "/\(rawValue)/index"
    }
}

// MARK: - API 配置
/// API 配置结构体
struct APIConfig {
    
    // MARK: - 天行API配置
    
    /// 天行API基础地址
    static let tianAPIBaseURL = "https://apis.tianapi.com"
    
    /// API Key（请替换为您自己的Key）
    /// 获取地址: https://www.tianapi.com/
    static let apiKey = "1d8093121b94bcec6f91b847ac3e9fd8"
    
    // MARK: - 新闻接口地址
    
    /// 根据分类获取完整接口地址
    /// - Parameter category: 新闻分类
    /// - Returns: 完整的API URL
    static func newsURL(for category: NewsCategory) -> String {
        return tianAPIBaseURL + category.apiPath
    }
    
    // MARK: - 生活模块接口地址
    
    /// 天气预报接口
    static let weatherURL = tianAPIBaseURL + "/tianqi/index"
    
    /// 旅游景区大全接口
    static let scenicURL = tianAPIBaseURL + "/scenic/index"
    
    /// BFR体脂率接口
    static let bfrURL = tianAPIBaseURL + "/bfrsum/index"
    
    /// 中药大全接口
    static let zhongyaoURL = tianAPIBaseURL + "/zhongyao/index"
    
    /// 实时油价接口
    static let oilPriceURL = tianAPIBaseURL + "/oilprice/index"
    
    // MARK: - 趣味娱乐模块接口地址
    
    /// 周公解梦接口
    static let dreamURL = tianAPIBaseURL + "/dream/index"
    
    /// 星座运势接口
    static let starURL = tianAPIBaseURL + "/star/index"
    
    /// 故事大全接口
    static let storyURL = tianAPIBaseURL + "/story/index"
    
    // MARK: - 知识模块接口地址
    
    /// 脑筋急转弯接口
    static let brainTeaserURL = tianAPIBaseURL + "/naowan/index"
    
    /// 百科题库接口
    static let quizURL = tianAPIBaseURL + "/baiketiku/index"
    
    // MARK: - 热搜榜接口地址
    
    /// 抖音热搜榜接口
    static let douyinHotURL = tianAPIBaseURL + "/douyinhot/index"
}
