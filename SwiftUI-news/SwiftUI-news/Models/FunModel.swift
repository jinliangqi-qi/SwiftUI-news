//
//  FunModel.swift
//  SwiftUI-news
//
//  Created by v_jinlqi on 2026/1/30.
//
//  趣味娱乐模块数据模型 - 周公解梦、星座运势

import Foundation
import SwiftUI

// MARK: - 周公解梦数据模型

/// 周公解梦API响应
struct DreamResponse: Decodable {
    let code: Int
    let msg: String
    let result: DreamResult?
}

/// 周公解梦结果
struct DreamResult: Decodable {
    let list: [DreamData]
}

/// 解梦数据
struct DreamData: Codable, Identifiable {
    let id: Int
    let type: String       // 梦境分类类型
    let title: String      // 解梦条目标题
    let result: String     // 具体的解梦释义内容
    
    /// 清理后的解梦内容
    var cleanedResult: String {
        var cleaned = result
        // 移除HTML标签
        let htmlTags = ["<br>", "<br/>", "<br />", "</p>", "<p>", "&nbsp;"]
        for tag in htmlTags {
            cleaned = cleaned.replacingOccurrences(of: tag, with: "\n", options: .caseInsensitive)
        }
        // 移除多余换行
        while cleaned.contains("\n\n\n") {
            cleaned = cleaned.replacingOccurrences(of: "\n\n\n", with: "\n\n")
        }
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// 分类图标
    var typeIcon: String {
        switch type {
        case "人物类": return "person.fill"
        case "动物类": return "hare.fill"
        case "植物类": return "leaf.fill"
        case "物品类": return "cube.fill"
        case "活动类": return "figure.walk"
        case "生活类": return "house.fill"
        case "自然类": return "sun.max.fill"
        case "鬼神类": return "moon.stars.fill"
        case "建筑类": return "building.2.fill"
        case "其他类", "综合类": return "square.grid.2x2.fill"
        default: return "sparkles"
        }
    }
    
    /// 分类颜色
    var typeColor: Color {
        switch type {
        case "人物类": return .blue
        case "动物类": return .orange
        case "植物类": return .green
        case "物品类": return .purple
        case "活动类": return .red
        case "生活类": return .pink
        case "自然类": return .cyan
        case "鬼神类": return .indigo
        case "建筑类": return .brown
        default: return .gray
        }
    }
}

// MARK: - 星座运势数据模型

/// 星座枚举
enum Constellation: String, CaseIterable, Identifiable {
    case aries = "白羊座"
    case taurus = "金牛座"
    case gemini = "双子座"
    case cancer = "巨蟹座"
    case leo = "狮子座"
    case virgo = "处女座"
    case libra = "天秤座"
    case scorpio = "天蝎座"
    case sagittarius = "射手座"
    case capricorn = "摩羯座"
    case aquarius = "水瓶座"
    case pisces = "双鱼座"
    
    var id: String { rawValue }
    
    /// 星座图标
    var icon: String {
        switch self {
        case .aries: return "♈️"
        case .taurus: return "♉️"
        case .gemini: return "♊️"
        case .cancer: return "♋️"
        case .leo: return "♌️"
        case .virgo: return "♍️"
        case .libra: return "♎️"
        case .scorpio: return "♏️"
        case .sagittarius: return "♐️"
        case .capricorn: return "♑️"
        case .aquarius: return "♒️"
        case .pisces: return "♓️"
        }
    }
    
    /// 星座颜色
    var color: Color {
        switch self {
        case .aries: return .red
        case .taurus: return .green
        case .gemini: return .yellow
        case .cancer: return .cyan
        case .leo: return .orange
        case .virgo: return .brown
        case .libra: return .pink
        case .scorpio: return .purple
        case .sagittarius: return .blue
        case .capricorn: return .gray
        case .aquarius: return .teal
        case .pisces: return .indigo
        }
    }
    
    /// 日期范围
    var dateRange: String {
        switch self {
        case .aries: return "3.21 - 4.19"
        case .taurus: return "4.20 - 5.20"
        case .gemini: return "5.21 - 6.21"
        case .cancer: return "6.22 - 7.22"
        case .leo: return "7.23 - 8.22"
        case .virgo: return "8.23 - 9.22"
        case .libra: return "9.23 - 10.23"
        case .scorpio: return "10.24 - 11.22"
        case .sagittarius: return "11.23 - 12.21"
        case .capricorn: return "12.22 - 1.19"
        case .aquarius: return "1.20 - 2.18"
        case .pisces: return "2.19 - 3.20"
        }
    }
}

/// 星座运势API响应
struct StarResponse: Decodable {
    let code: Int
    let msg: String
    let result: StarResult?
}

/// 星座运势结果
struct StarResult: Decodable {
    let list: [StarItem]
}

/// 星座运势条目
struct StarItem: Codable, Identifiable {
    let type: String      // 指标类型
    let content: String   // 指标内容
    
    var id: String { type }
    
    /// 指标图标
    var icon: String {
        switch type {
        case "综合指数": return "chart.bar.fill"
        case "爱情指数": return "heart.fill"
        case "工作指数": return "briefcase.fill"
        case "财运指数": return "yensign.circle.fill"
        case "健康指数": return "heart.text.square.fill"
        case "幸运颜色": return "paintpalette.fill"
        case "幸运数字": return "number.circle.fill"
        case "贵人星座": return "person.fill.checkmark"
        case "今日概述": return "doc.text.fill"
        default: return "star.fill"
        }
    }
    
    /// 指标颜色
    var color: Color {
        switch type {
        case "综合指数": return .blue
        case "爱情指数": return .pink
        case "工作指数": return .orange
        case "财运指数": return .yellow
        case "健康指数": return .green
        case "幸运颜色": return .purple
        case "幸运数字": return .cyan
        case "贵人星座": return .indigo
        case "今日概述": return .gray
        default: return .secondary
        }
    }
    
    /// 是否为指数类型（带百分比）
    var isIndex: Bool {
        type.contains("指数")
    }
    
    /// 百分比数值（如果是指数类型）
    var percentValue: Double? {
        guard isIndex else { return nil }
        let numStr = content.replacingOccurrences(of: "%", with: "")
        return Double(numStr)
    }
}

// MARK: - 故事大全数据模型

/// 故事类型枚举
enum StoryType: Int, CaseIterable, Identifiable {
    case idiom = 1      // 成语故事
    case bedtime = 2    // 睡前故事
    case fairy = 3      // 童话故事
    case fable = 4      // 寓言故事
    
    var id: Int { rawValue }
    
    /// 类型名称
    var name: String {
        switch self {
        case .idiom: return "成语故事"
        case .bedtime: return "睡前故事"
        case .fairy: return "童话故事"
        case .fable: return "寓言故事"
        }
    }
    
    /// 类型图标
    var icon: String {
        switch self {
        case .idiom: return "character.book.closed.fill"
        case .bedtime: return "moon.zzz.fill"
        case .fairy: return "wand.and.stars"
        case .fable: return "book.fill"
        }
    }
    
    /// 类型颜色
    var color: Color {
        switch self {
        case .idiom: return .orange
        case .bedtime: return .purple
        case .fairy: return .pink
        case .fable: return .blue
        }
    }
}

/// 故事API响应
struct StoryResponse: Decodable {
    let code: Int
    let msg: String
    let result: StoryResult?
}

/// 故事结果
struct StoryResult: Decodable {
    let list: [StoryData]
}

/// 故事数据
struct StoryData: Codable, Identifiable {
    var id: String { title }
    
    let title: String       // 故事标题
    let content: String     // 故事内容
    let storytype: Int      // 故事类型（1-成语、2-睡前、3-童话、4-寓言）
    
    /// 故事类型枚举
    var storyType: StoryType {
        StoryType(rawValue: storytype) ?? .fable
    }
    
    /// 类型名称
    var typeName: String {
        storyType.name
    }
    
    /// 类型图标
    var typeIcon: String {
        storyType.icon
    }
    
    /// 类型颜色
    var typeColor: Color {
        storyType.color
    }
    
    /// 清理后的内容
    var cleanedContent: String {
        var cleaned = content
        // 移除HTML标签
        let htmlTags = ["<br>", "<br/>", "<br />", "</p>", "<p>", "&nbsp;"]
        for tag in htmlTags {
            cleaned = cleaned.replacingOccurrences(of: tag, with: "\n", options: .caseInsensitive)
        }
        // 移除多余换行
        while cleaned.contains("\n\n\n") {
            cleaned = cleaned.replacingOccurrences(of: "\n\n\n", with: "\n\n")
        }
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// 预览内容（前100字）
    var previewContent: String {
        let cleaned = cleanedContent
        if cleaned.count > 100 {
            return String(cleaned.prefix(100)) + "..."
        }
        return cleaned
    }
}
