//
//  DataCacheManager.swift
//  SwiftUI-news
//
//  Created by v_jinlqi on 2026/1/30.
//
//  通用数据缓存管理器 - 支持内存和磁盘缓存

import Foundation

// MARK: - 缓存配置
/// 缓存过期时间配置
enum CacheExpiration {
    case never                    // 永不过期
    case seconds(TimeInterval)    // 指定秒数
    case minutes(Int)             // 指定分钟
    case hours(Int)               // 指定小时
    case days(Int)                // 指定天数
    
    var timeInterval: TimeInterval {
        switch self {
        case .never:
            return .infinity
        case .seconds(let seconds):
            return seconds
        case .minutes(let minutes):
            return TimeInterval(minutes * 60)
        case .hours(let hours):
            return TimeInterval(hours * 3600)
        case .days(let days):
            return TimeInterval(days * 86400)
        }
    }
}

// MARK: - 缓存条目
/// 缓存条目包装器
struct CacheEntry<T: Codable>: Codable {
    let data: T
    let timestamp: Date
    let expiration: TimeInterval
    
    var isExpired: Bool {
        guard expiration != .infinity else { return false }
        return Date().timeIntervalSince(timestamp) > expiration
    }
}

// MARK: - 缓存键
/// 预定义的缓存键
enum CacheKey {
    // 新闻缓存
    case newsList(category: String, page: Int)
    case douyinHot
    
    // 生活服务缓存
    case weather(city: String)
    case scenicList(keyword: String, page: Int)
    case oilPrice(province: String)
    case zhongyaoList(page: Int)
    
    // 趣味娱乐缓存
    case starFortune(constellation: String, date: String)
    case dreamSearch(keyword: String)
    case storyList(type: Int, keyword: String, page: Int)
    
    // 知识缓存
    case brainTeaserList(page: Int)
    case quiz
    
    var key: String {
        switch self {
        case .newsList(let category, let page):
            return "news_\(category)_\(page)"
        case .douyinHot:
            return "douyin_hot"
        case .weather(let city):
            return "weather_\(city)"
        case .scenicList(let keyword, let page):
            return "scenic_\(keyword)_\(page)"
        case .oilPrice(let province):
            return "oil_\(province)"
        case .zhongyaoList(let page):
            return "zhongyao_\(page)"
        case .starFortune(let constellation, let date):
            return "star_\(constellation)_\(date)"
        case .dreamSearch(let keyword):
            return "dream_\(keyword)"
        case .storyList(let type, let keyword, let page):
            return "story_\(type)_\(keyword)_\(page)"
        case .brainTeaserList(let page):
            return "brainteaser_\(page)"
        case .quiz:
            return "quiz"
        }
    }
    
    /// 默认过期时间
    var defaultExpiration: CacheExpiration {
        switch self {
        case .newsList:
            return .minutes(10)      // 新闻10分钟过期
        case .douyinHot:
            return .minutes(3)       // 抖音热搜3分钟过期（接口每3分钟更新）
        case .weather:
            return .hours(1)         // 天气1小时过期
        case .scenicList:
            return .days(7)          // 景区7天过期
        case .oilPrice:
            return .hours(6)         // 油价6小时过期
        case .zhongyaoList:
            return .days(7)          // 中药列表7天过期
        case .starFortune:
            return .hours(3)         // 星座运势3小时过期
        case .dreamSearch:
            return .days(30)         // 解梦结果30天过期
        case .storyList:
            return .days(7)          // 故事7天过期
        case .brainTeaserList:
            return .minutes(30)      // 脑筋急转弯30分钟过期
        case .quiz:
            return .minutes(5)       // 百科题库5分钟过期（每次刷新获取新题）
        }
    }
}

// MARK: - 数据缓存管理器
/// 通用数据缓存管理器，支持内存和磁盘双层缓存
final class DataCacheManager: @unchecked Sendable {
    
    /// 单例实例
    static let shared = DataCacheManager()
    
    /// 内存缓存
    private var memoryCache: [String: Any] = [:]
    
    /// 内存缓存锁
    private let memoryCacheLock = NSLock()
    
    /// 磁盘缓存目录
    private let diskCacheURL: URL
    
    /// 文件管理器
    private let fileManager = FileManager.default
    
    /// 磁盘操作队列
    private let diskQueue = DispatchQueue(label: "com.news.datacache", qos: .utility)
    
    /// JSON编码器
    private let encoder = JSONEncoder()
    
    /// JSON解码器
    private let decoder = JSONDecoder()
    
    private init() {
        let cacheDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        diskCacheURL = cacheDir.appendingPathComponent("DataCache", isDirectory: true)
        
        // 创建缓存目录
        try? fileManager.createDirectory(at: diskCacheURL, withIntermediateDirectories: true)
    }
    
    // MARK: - 公共方法
    
    /// 保存数据到缓存
    /// - Parameters:
    ///   - data: 要缓存的数据
    ///   - key: 缓存键
    ///   - expiration: 过期时间（可选，默认使用键的默认过期时间）
    func save<T: Codable>(_ data: T, forKey key: CacheKey, expiration: CacheExpiration? = nil) {
        let exp = expiration ?? key.defaultExpiration
        let entry = CacheEntry(data: data, timestamp: Date(), expiration: exp.timeInterval)
        
        // 保存到内存
        memoryCacheLock.lock()
        memoryCache[key.key] = entry
        memoryCacheLock.unlock()
        
        // 异步保存到磁盘
        diskQueue.async { [weak self] in
            self?.saveToDisk(entry, forKey: key.key)
        }
    }
    
    /// 从缓存获取数据
    /// - Parameter key: 缓存键
    /// - Returns: 缓存的数据，如果不存在或已过期则返回nil
    func get<T: Codable>(_ type: T.Type, forKey key: CacheKey) -> T? {
        // 先从内存获取
        memoryCacheLock.lock()
        if let entry = memoryCache[key.key] as? CacheEntry<T> {
            memoryCacheLock.unlock()
            if !entry.isExpired {
                return entry.data
            } else {
                // 已过期，删除
                remove(forKey: key)
                return nil
            }
        }
        memoryCacheLock.unlock()
        
        // 从磁盘获取
        if let entry: CacheEntry<T> = loadFromDisk(forKey: key.key) {
            if !entry.isExpired {
                // 加载到内存
                memoryCacheLock.lock()
                memoryCache[key.key] = entry
                memoryCacheLock.unlock()
                return entry.data
            } else {
                // 已过期，删除
                remove(forKey: key)
            }
        }
        
        return nil
    }
    
    /// 检查缓存是否存在且有效
    func exists(forKey key: CacheKey) -> Bool {
        // 检查内存
        memoryCacheLock.lock()
        let hasInMemory = memoryCache[key.key] != nil
        memoryCacheLock.unlock()
        
        if hasInMemory {
            return true
        }
        
        // 检查磁盘
        let filePath = diskCacheURL.appendingPathComponent(key.key.sha256Hash + ".cache")
        return fileManager.fileExists(atPath: filePath.path)
    }
    
    /// 删除指定缓存
    func remove(forKey key: CacheKey) {
        // 从内存删除
        memoryCacheLock.lock()
        memoryCache.removeValue(forKey: key.key)
        memoryCacheLock.unlock()
        
        // 从磁盘删除
        diskQueue.async { [weak self] in
            guard let self = self else { return }
            let filePath = self.diskCacheURL.appendingPathComponent(key.key.sha256Hash + ".cache")
            try? self.fileManager.removeItem(at: filePath)
        }
    }
    
    /// 清除所有缓存
    func clearAll() {
        // 清除内存
        memoryCacheLock.lock()
        memoryCache.removeAll()
        memoryCacheLock.unlock()
        
        // 清除磁盘
        diskQueue.async { [weak self] in
            guard let self = self else { return }
            try? self.fileManager.removeItem(at: self.diskCacheURL)
            try? self.fileManager.createDirectory(at: self.diskCacheURL, withIntermediateDirectories: true)
        }
    }
    
    /// 清除过期缓存
    func clearExpired() {
        diskQueue.async { [weak self] in
            guard let self = self else { return }
            
            guard let files = try? self.fileManager.contentsOfDirectory(
                at: self.diskCacheURL,
                includingPropertiesForKeys: [.contentModificationDateKey]
            ) else { return }
            
            let localDecoder = JSONDecoder()
            for file in files where file.pathExtension == "cache" {
                // 尝试读取并检查是否过期
                if let data = try? Data(contentsOf: file),
                   let entry = try? localDecoder.decode(CacheEntry<EmptyData>.self, from: data),
                   entry.isExpired {
                    try? self.fileManager.removeItem(at: file)
                }
            }
        }
    }
    
    /// 获取缓存大小
    func cacheSize() -> Int64 {
        var totalSize: Int64 = 0
        
        guard let files = try? fileManager.contentsOfDirectory(
            at: diskCacheURL,
            includingPropertiesForKeys: [.fileSizeKey]
        ) else { return 0 }
        
        for file in files {
            if let size = try? file.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                totalSize += Int64(size)
            }
        }
        
        return totalSize
    }
    
    // MARK: - 私有方法
    
    private func saveToDisk<T: Codable>(_ entry: CacheEntry<T>, forKey key: String) {
        let filePath = diskCacheURL.appendingPathComponent(key.sha256Hash + ".cache")
        
        do {
            let data = try encoder.encode(entry)
            try data.write(to: filePath)
        } catch {
            print("DataCache: Failed to save to disk - \(error)")
        }
    }
    
    private func loadFromDisk<T: Codable>(forKey key: String) -> CacheEntry<T>? {
        let filePath = diskCacheURL.appendingPathComponent(key.sha256Hash + ".cache")
        
        guard let data = try? Data(contentsOf: filePath) else { return nil }
        return try? decoder.decode(CacheEntry<T>.self, from: data)
    }
}

// MARK: - 辅助类型
/// 空数据类型，用于检查缓存是否过期
private struct EmptyData: Codable, Sendable {}

// MARK: - String扩展
extension String {
    /// 计算SHA256哈希值
    var sha256Hash: String {
        let data = Data(self.utf8)
        var hash = [UInt8](repeating: 0, count: 32)
        
        data.withUnsafeBytes { buffer in
            _ = CC_SHA256(buffer.baseAddress, CC_LONG(data.count), &hash)
        }
        
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - CommonCrypto桥接
import CommonCrypto
