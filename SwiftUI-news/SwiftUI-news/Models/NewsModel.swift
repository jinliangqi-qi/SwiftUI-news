//
//  NewsModel.swift
//  SwiftUI-news
//
//  Created by v_jinlqi on 2026/1/30.
//
//  新闻数据模型 - 对应天行API返回的数据结构

import Foundation

// MARK: - API 响应模型
/// API 统一响应结构（result 可能是对象或数组）
struct APIResponse: Decodable {
    let code: Int           // 状态码，200表示成功
    let msg: String         // 返回消息
    let result: NewsResult? // 返回结果（数据为空时可能不存在）
}

// MARK: - 新闻结果（兼容两种格式）
/// 兼容 result 为对象或直接为数组的情况
enum NewsResult: Decodable {
    case list(NewsListResult)   // result 是包含 list 的对象
    case items([NewsItem])      // result 直接是数组
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        // 先尝试解析为对象格式 { list: [...] }
        if let listResult = try? container.decode(NewsListResult.self) {
            self = .list(listResult)
            return
        }
        
        // 再尝试解析为数组格式 [...]
        if let items = try? container.decode([NewsItem].self) {
            self = .items(items)
            return
        }
        
        // 都失败则返回空数组
        self = .items([])
    }
    
    /// 获取新闻列表
    var newsList: [NewsItem] {
        switch self {
        case .list(let result):
            return result.list
        case .items(let items):
            return items
        }
    }
}

// MARK: - 新闻列表结果
/// 新闻列表响应结果（对象格式）
struct NewsListResult: Decodable {
    let list: [NewsItem]      // 新闻列表（新版API返回字段名为list）
    let allnum: Int?          // 总数量（可能为空）
    let curpage: Int?         // 当前页码（可能为空）
    
    // 兼容旧版API的newslist字段
    enum CodingKeys: String, CodingKey {
        case list
        case newslist
        case allnum
        case curpage
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // 优先尝试解析list字段，如果不存在则尝试newslist
        if let listItems = try? container.decode([NewsItem].self, forKey: .list) {
            self.list = listItems
        } else if let newslistItems = try? container.decode([NewsItem].self, forKey: .newslist) {
            self.list = newslistItems
        } else {
            self.list = []
        }
        
        self.allnum = try? container.decode(Int.self, forKey: .allnum)
        self.curpage = try? container.decode(Int.self, forKey: .curpage)
    }
}

// MARK: - 新闻条目模型
/// 单条新闻数据模型
struct NewsItem: Codable, Identifiable {
    let id: String          // 新闻唯一标识
    let title: String       // 新闻标题
    let description: String // 新闻描述/摘要
    let picUrl: String      // 封面图片URL
    let ctime: String       // 发布时间
    let url: String         // 原文链接
    let source: String      // 新闻来源
    
    /// 自定义解码键，处理可能的字段名差异
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case picUrl
        case ctime
        case url
        case source
    }
    
    /// 自定义解码，处理可能的空值
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // 尝试解码 id，如果失败则生成 UUID
        if let idString = try? container.decode(String.self, forKey: .id) {
            self.id = idString
        } else if let idInt = try? container.decode(Int.self, forKey: .id) {
            self.id = String(idInt)
        } else {
            self.id = UUID().uuidString
        }
        
        self.title = try container.decodeIfPresent(String.self, forKey: .title) ?? "无标题"
        self.description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        self.picUrl = try container.decodeIfPresent(String.self, forKey: .picUrl) ?? ""
        self.ctime = try container.decodeIfPresent(String.self, forKey: .ctime) ?? ""
        self.url = try container.decodeIfPresent(String.self, forKey: .url) ?? ""
        self.source = try container.decodeIfPresent(String.self, forKey: .source) ?? "未知来源"
    }
}

// MARK: - 抖音热搜响应模型
/// 抖音热搜API响应结构
struct DouyinHotResponse: Decodable {
    let code: Int
    let msg: String
    let result: DouyinHotResult?
}

/// 抖音热搜结果
struct DouyinHotResult: Decodable {
    let list: [DouyinHotItem]
}

/// 抖音热搜条目
struct DouyinHotItem: Codable, Identifiable {
    let word: String       // 热点话题关键词
    let label: Int         // 标签类型：1=新，2=荐，3=热
    let hotindex: Int      // 热搜指数
    
    var id: String { word }
    
    /// 标签显示文本
    var labelText: String {
        switch label {
        case 1: return "新"
        case 2: return "荐"
        case 3: return "热"
        default: return ""
        }
    }
    
    /// 标签颜色
    var labelColor: String {
        switch label {
        case 1: return "blue"
        case 2: return "orange"
        case 3: return "red"
        default: return "gray"
        }
    }
    
    /// 格式化热度值
    var formattedHotindex: String {
        if hotindex >= 10000 {
            return String(format: "%.1f万", Double(hotindex) / 10000)
        }
        return "\(hotindex)"
    }
}

// MARK: - 预览数据
/// 用于 SwiftUI 预览的模拟数据
extension NewsItem {
    static let preview = NewsItem(
        id: "1",
        title: "这是一条示例新闻标题",
        description: "这是新闻的摘要描述，用于展示新闻的主要内容概览。",
        picUrl: "https://example.com/image.jpg",
        ctime: "2026-01-30 12:00",
        url: "https://example.com/news/1",
        source: "示例来源"
    )
    
    /// 手动初始化方法，用于创建预览数据
    init(id: String, title: String, description: String, picUrl: String, ctime: String, url: String, source: String) {
        self.id = id
        self.title = title
        self.description = description
        self.picUrl = picUrl
        self.ctime = ctime
        self.url = url
        self.source = source
    }
}
