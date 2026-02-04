//
//  LifeModel.swift
//  SwiftUI-news
//
//  Created by v_jinlqi on 2026/1/30.
//
//  生活模块数据模型 - 天气预报、空气质量、健康提示、BFR体脂率

import Foundation

// MARK: - 天气预报数据模型

/// 天气预报API响应
struct WeatherResponse: Decodable {
    let code: Int
    let msg: String
    let result: WeatherData?
}

/// 天气预报数据
struct WeatherData: Codable, Identifiable {
    var id: String { area + date }
    
    let area: String          // 地区
    let date: String          // 日期
    let week: String          // 星期
    let weather: String       // 天气状况
    let real: String          // 实时气温
    let highest: String       // 最高气温
    let lowest: String        // 最低气温
    let wind: String          // 风向
    let windsc: String        // 风力等级
    let humidity: String      // 相对湿度
    let tips: String          // 生活指数提示
    let sunrise: String?      // 日出时间
    let sunset: String?       // 日落时间
    let aqi: String?          // 空气质量指数
    let quality: String?      // 空气质量
    let alarmlist: [WeatherAlarm]?  // 预警列表
    
    /// 天气图标
    var weatherIcon: String {
        if weather.contains("晴") {
            return "sun.max.fill"
        } else if weather.contains("云") || weather.contains("阴") {
            return "cloud.fill"
        } else if weather.contains("雨") {
            return "cloud.rain.fill"
        } else if weather.contains("雪") {
            return "cloud.snow.fill"
        } else if weather.contains("雾") || weather.contains("霾") {
            return "cloud.fog.fill"
        } else if weather.contains("雷") {
            return "cloud.bolt.fill"
        } else {
            return "cloud.sun.fill"
        }
    }
    
    /// 天气图标颜色
    var weatherColor: String {
        if weather.contains("晴") {
            return "orange"
        } else if weather.contains("云") || weather.contains("阴") {
            return "gray"
        } else if weather.contains("雨") {
            return "blue"
        } else if weather.contains("雪") {
            return "cyan"
        } else {
            return "gray"
        }
    }
}

/// 天气预警
struct WeatherAlarm: Codable, Identifiable {
    var id: String { type + level }
    
    let type: String      // 预警类型
    let level: String     // 预警级别
    let content: String   // 预警内容
    let time: String?     // 发布时间
}

// MARK: - 旅游景区数据模型

/// 旅游景区API响应
struct ScenicResponse: Decodable {
    let code: Int
    let msg: String
    let result: ScenicResult?
}

/// 旅游景区结果
struct ScenicResult: Decodable {
    let list: [ScenicData]
}

/// 旅游景区数据
struct ScenicData: Codable, Identifiable, Hashable {
    var id: String = UUID().uuidString
    
    let name: String        // 景点名称
    let province: String    // 省份
    let city: String        // 城市
    let content: String     // 景点介绍
    
    enum CodingKeys: String, CodingKey {
        case name, province, city, content
    }
    
    // 实现 Hashable - 使用 id 进行哈希
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // 实现 Equatable - 使用 id 判断相等
    static func == (lhs: ScenicData, rhs: ScenicData) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - 实时油价数据模型

/// 油价API响应
struct OilPriceResponse: Decodable {
    let code: Int
    let msg: String
    let result: OilPriceData?
}

/// 油价数据
struct OilPriceData: Codable, Identifiable {
    var id: String { prov }
    
    let p0: String       // 0号柴油价格
    let p89: String      // 89号汽油价格
    let p92: String      // 92号汽油价格
    let p95: String      // 95号汽油价格
    let p98: String      // 98号汽油价格
    let prov: String     // 省区名
    let time: String     // 更新时间
    
    /// 格式化更新时间（只显示日期部分）
    var formattedTime: String {
        if let dotIndex = time.firstIndex(of: ".") {
            return String(time[..<dotIndex])
        }
        return time
    }
}

// MARK: - BFR体脂率数据模型

/// BFR体脂率API响应
struct BFRResponse: Decodable {
    let code: Int
    let msg: String
    let result: BFRData?
}

/// BFR体脂率数据
struct BFRData: Decodable {
    let bfr: String           // 当前体脂率
    let tip: String           // 身材小贴士
    let healthy: String       // 健康风险
    let normbfr: String       // 正常体脂率范围
    let normweight: String    // 正常体重范围
    let idealweight: Int      // 标准体重
}

// MARK: - BFR性别枚举
/// BFR计算性别选项
enum BFRSex: Int, CaseIterable, Identifiable {
    case male = 1       // 男性
    case female = 0     // 女性
    
    var id: Int { rawValue }
    
    /// 显示名称
    var displayName: String {
        switch self {
        case .male: return "男"
        case .female: return "女"
        }
    }
    
    /// 图标
    var icon: String {
        switch self {
        case .male: return "person.fill"
        case .female: return "person.fill"
        }
    }
}

// MARK: - 中药大全数据模型

/// 中药大全API响应
struct ZhongyaoResponse: Decodable {
    let code: Int
    let msg: String
    let result: ZhongyaoResult?
}

/// 中药大全结果（兼容单个对象或列表）
struct ZhongyaoResult: Decodable {
    let list: [ZhongyaoData]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        // 尝试解析为包含list的对象
        if let listContainer = try? container.decode(ZhongyaoListResult.self) {
            self.list = listContainer.list
            return
        }
        
        // 尝试解析为单个对象
        if let single = try? container.decode(ZhongyaoData.self) {
            self.list = [single]
            return
        }
        
        // 尝试解析为数组
        if let array = try? container.decode([ZhongyaoData].self) {
            self.list = array
            return
        }
        
        self.list = []
    }
}

/// 中药列表结果
struct ZhongyaoListResult: Decodable {
    let list: [ZhongyaoData]
}

/// 中药数据
struct ZhongyaoData: Codable, Identifiable {
    var id: String { title }
    
    let title: String      // 中草药名称
    let content: String    // 详细内容
    
    /// 解析内容获取各字段
    var parsedInfo: ZhongyaoParsedInfo {
        ZhongyaoParsedInfo(content: content)
    }
}

/// 解析后的中药信息
struct ZhongyaoParsedInfo {
    let category: String       // 类别
    let alias: String          // 别名
    let source: String         // 来源
    let property: String       // 性味
    let function: String       // 功能主治
    let usage: String          // 用法用量
    let morphology: String     // 植物形态
    let habitat: String        // 生长地
    let chemistry: String      // 化学成份
    
    init(content: String) {
        // 清理HTML标签并格式化序号
        func cleanHTML(_ text: String) -> String {
            var cleaned = text
            // 移除常见HTML标签
            let htmlTags = ["<br>", "<br/>", "<br />", "</p>", "<p>", "</div>", "<div>", 
                           "&nbsp;", "&lt;", "&gt;", "&amp;", "</span>", "<span>"]
            for tag in htmlTags {
                cleaned = cleaned.replacingOccurrences(of: tag, with: "", options: .caseInsensitive)
            }
            // 使用正则移除其他HTML标签
            if let regex = try? NSRegularExpression(pattern: "<[^>]+>", options: .caseInsensitive) {
                cleaned = regex.stringByReplacingMatches(in: cleaned, options: [], 
                    range: NSRange(cleaned.startIndex..., in: cleaned), withTemplate: "")
            }
            
            // 在带圈序号前添加换行（①②③④⑤⑥⑦⑧⑨⑩等）
            let circledNumbers = ["①", "②", "③", "④", "⑤", "⑥", "⑦", "⑧", "⑨", "⑩",
                                 "⑪", "⑫", "⑬", "⑭", "⑮", "⑯", "⑰", "⑱", "⑲", "⑳"]
            for (index, num) in circledNumbers.enumerated() {
                // 第一个序号不需要换行
                if index == 0 {
                    continue
                }
                cleaned = cleaned.replacingOccurrences(of: num, with: "\n\n\(num)")
            }
            
            return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        // 解析各字段
        func extract(_ key: String) -> String {
            let pattern = "【\(key)】[：:]?([^【]*)"
            if let range = content.range(of: pattern, options: .regularExpression) {
                var result = String(content[range])
                result = result.replacingOccurrences(of: "【\(key)】", with: "")
                result = result.replacingOccurrences(of: "：", with: "")
                result = result.replacingOccurrences(of: ":", with: "")
                return cleanHTML(result)
            }
            return ""
        }
        
        self.category = extract("类别")
        self.alias = extract("别名")
        self.source = extract("来源")
        self.property = extract("性味")
        self.function = extract("功能主治")
        self.usage = extract("用法用量")
        self.morphology = extract("植物形态")
        self.habitat = extract("生长地")
        self.chemistry = extract("化学成份")
    }
}
