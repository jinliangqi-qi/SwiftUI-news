//
//  DouyinLauncher.swift
//  SwiftUI-news
//
//  Created by v_jinlqi on 2026/2/2.
//
//  抖音App跳转工具 - 优先跳转App，未安装则用WebView

import SwiftUI

#if os(iOS)
import UIKit

// MARK: - 抖音跳转工具
/// 处理抖音热搜的打开逻辑
enum DouyinLauncher {
    
    /// 抖音App URL Scheme
    private static let douyinScheme = "snssdk1128://"
    
    /// 抖音搜索页面 Scheme
    /// 格式: snssdk1128://search?keyword=关键词
    private static func douyinSearchURL(keyword: String) -> URL? {
        guard let encoded = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        return URL(string: "snssdk1128://search?keyword=\(encoded)")
    }
    
    /// 抖音网页搜索URL
    private static func webSearchURL(keyword: String) -> URL? {
        guard let encoded = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        return URL(string: "https://www.douyin.com/search/\(encoded)")
    }
    
    /// 检查是否安装了抖音App
    static var isDouyinInstalled: Bool {
        guard let url = URL(string: douyinScheme) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
    
    /// 打开抖音搜索
    /// - Parameters:
    ///   - keyword: 搜索关键词
    ///   - completion: 完成回调，返回是否成功跳转到App，以及备用的Web URL
    static func openSearch(keyword: String, completion: @escaping (Bool, URL?) -> Void) {
        // 优先尝试跳转抖音App
        if isDouyinInstalled, let appURL = douyinSearchURL(keyword: keyword) {
            UIApplication.shared.open(appURL, options: [:]) { success in
                if success {
                    completion(true, nil)
                } else {
                    // App跳转失败，返回Web URL
                    completion(false, webSearchURL(keyword: keyword))
                }
            }
        } else {
            // 未安装抖音，返回Web URL
            completion(false, webSearchURL(keyword: keyword))
        }
    }
    
    /// 同步方式获取打开方式
    /// - Parameter keyword: 搜索关键词
    /// - Returns: (是否能跳转App, App URL, Web URL)
    static func getOpenURLs(keyword: String) -> (canOpenApp: Bool, appURL: URL?, webURL: URL?) {
        let appURL = douyinSearchURL(keyword: keyword)
        let webURL = webSearchURL(keyword: keyword)
        let canOpen = isDouyinInstalled && appURL != nil
        return (canOpen, appURL, webURL)
    }
}

#else

// MARK: - macOS 版本（仅支持网页）
enum DouyinLauncher {
    
    static var isDouyinInstalled: Bool { false }
    
    static func webSearchURL(keyword: String) -> URL? {
        guard let encoded = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        return URL(string: "https://www.douyin.com/search/\(encoded)")
    }
    
    static func getOpenURLs(keyword: String) -> (canOpenApp: Bool, appURL: URL?, webURL: URL?) {
        return (false, nil, webSearchURL(keyword: keyword))
    }
}

#endif
