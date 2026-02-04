//
//  ImageLoader.swift
//  SwiftUI-news
//
//  Created by v_jinlqi on 2026/1/30.
//
//  图片加载器 - 封装原生图片异步加载和缓存（内存+磁盘）

import SwiftUI
import Combine

#if canImport(UIKit)
import UIKit
typealias PlatformImage = UIImage
#elseif canImport(AppKit)
import AppKit
typealias PlatformImage = NSImage
#endif

// MARK: - 跨平台图片扩展
extension PlatformImage {
    #if canImport(AppKit)
    /// macOS 下获取 JPEG 数据
    func jpegData(compressionQuality: CGFloat) -> Data? {
        guard let tiffData = self.tiffRepresentation,
              let bitmapRep = NSBitmapImageRep(data: tiffData) else {
            return nil
        }
        return bitmapRep.representation(using: .jpeg, properties: [.compressionFactor: compressionQuality])
    }
    #endif
}

// MARK: - 图片缓存管理器
/// 图片缓存管理器，支持内存缓存和磁盘缓存
final class ImageCache: @unchecked Sendable {
    
    /// 单例实例
    static let shared = ImageCache()
    
    /// 内存缓存
    private let memoryCache = NSCache<NSString, PlatformImage>()
    
    /// 磁盘缓存目录
    private let diskCacheURL: URL
    
    /// 文件管理器
    private let fileManager = FileManager.default
    
    /// 缓存队列
    private let cacheQueue = DispatchQueue(label: "com.news.imagecache", qos: .utility)
    
    private init() {
        // 设置内存缓存限制
        memoryCache.countLimit = 50
        memoryCache.totalCostLimit = 30 * 1024 * 1024  // 30MB
        
        // 设置磁盘缓存目录
        let cacheDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        diskCacheURL = cacheDir.appendingPathComponent("ImageCache", isDirectory: true)
        
        // 创建缓存目录
        try? fileManager.createDirectory(at: diskCacheURL, withIntermediateDirectories: true)
    }
    
    /// 生成缓存文件名
    private func cacheFileName(for url: String) -> String {
        return url.data(using: .utf8)?.base64EncodedString()
            .replacingOccurrences(of: "/", with: "_") ?? UUID().uuidString
    }
    
    /// 获取缓存图片（先查内存，再查磁盘）
    func get(forKey url: String) -> PlatformImage? {
        // 先查内存缓存
        if let image = memoryCache.object(forKey: url as NSString) {
            return image
        }
        
        // 再查磁盘缓存
        let fileName = cacheFileName(for: url)
        let filePath = diskCacheURL.appendingPathComponent(fileName)
        
        if let data = try? Data(contentsOf: filePath),
           let image = PlatformImage(data: data) {
            // 加载到内存缓存
            memoryCache.setObject(image, forKey: url as NSString)
            return image
        }
        
        return nil
    }
    
    /// 设置缓存图片（同时存储到内存和磁盘）
    func set(_ image: PlatformImage, forKey url: String) {
        // 存入内存缓存
        memoryCache.setObject(image, forKey: url as NSString)
        
        // 异步存入磁盘缓存
        cacheQueue.async { [weak self] in
            guard let self = self else { return }
            let fileName = self.cacheFileName(for: url)
            let filePath = self.diskCacheURL.appendingPathComponent(fileName)
            
            if let data = image.jpegData(compressionQuality: 0.8) {
                try? data.write(to: filePath)
            }
        }
    }
    
    /// 清除内存缓存
    func clearMemoryCache() {
        memoryCache.removeAllObjects()
    }
}

// MARK: - 缓存图片视图（优化版）
/// 带缓存的异步图片加载视图组件，使用原生 AsyncImage 优化性能
struct CachedAsyncImage: View {
    
    let url: String
    let placeholder: String
    
    @State private var image: PlatformImage?
    @State private var isLoading = true
    
    init(url: String, placeholder: String = "photo") {
        self.url = url
        self.placeholder = placeholder
    }
    
    var body: some View {
        Group {
            if let image = image {
                #if canImport(UIKit)
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                #elseif canImport(AppKit)
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                #endif
            } else if isLoading {
                Rectangle()
                    .fill(Color.platformTertiaryFill)
                    .overlay {
                        ProgressView()
                            .tint(.secondary)
                    }
            } else {
                Rectangle()
                    .fill(Color.platformTertiaryFill)
                    .overlay {
                        Image(systemName: placeholder)
                            .foregroundColor(.secondary)
                    }
            }
        }
        .task(id: url) {
            await loadImage()
        }
    }
    
    /// 加载图片
    private func loadImage() async {
        guard !url.isEmpty else {
            isLoading = false
            return
        }
        
        // 检查缓存
        if let cached = ImageCache.shared.get(forKey: url) {
            self.image = cached
            isLoading = false
            return
        }
        
        // 网络加载 - 处理缺少协议前缀的URL
        var finalURL = url
        if url.hasPrefix("//") {
            finalURL = "https:" + url
        }
        
        guard let imageURL = URL(string: finalURL) else {
            isLoading = false
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: imageURL)
            if let loadedImage = PlatformImage(data: data) {
                ImageCache.shared.set(loadedImage, forKey: url)
                self.image = loadedImage
            }
        } catch {
            // 静默处理错误
        }
        
        isLoading = false
    }
}
