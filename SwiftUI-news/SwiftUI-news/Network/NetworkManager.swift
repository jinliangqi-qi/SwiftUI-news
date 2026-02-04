//
//  NetworkManager.swift
//  SwiftUI-news
//
//  Created by v_jinlqi on 2026/1/30.
//
//  网络请求管理器 - 封装原生 URLSession 进行网络请求

import Foundation

// MARK: - 网络错误类型
/// 定义网络请求可能出现的错误类型
enum NetworkError: Error, LocalizedError {
    case invalidURL           // 无效的URL
    case noData               // 无返回数据
    case decodingError        // JSON解码错误
    case serverError(Int)     // 服务器错误，包含状态码
    case networkError(Error)  // 网络连接错误
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的请求地址"
        case .noData:
            return "服务器未返回数据"
        case .decodingError:
            return "数据解析失败"
        case .serverError(let code):
            return "服务器错误: \(code)"
        case .networkError(let error):
            return "网络错误: \(error.localizedDescription)"
        }
    }
}

// MARK: - HTTP 请求方法
/// 支持的 HTTP 请求方法
enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
}

// MARK: - 网络管理器
/// 网络请求管理器单例类，封装所有网络请求逻辑
final class NetworkManager {
    
    /// 单例实例
    static let shared = NetworkManager()
    
    /// URLSession 配置
    private let session: URLSession
    
    /// 私有初始化方法，配置 URLSession
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30  // 请求超时时间
        config.timeoutIntervalForResource = 60 // 资源加载超时时间
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - 通用请求方法
    /// 发起网络请求并返回解码后的数据
    /// - Parameters:
    ///   - url: 请求URL字符串
    ///   - method: HTTP请求方法
    ///   - parameters: 请求参数（可选）
    /// - Returns: 解码后的泛型数据
    func request<T: Decodable>(
        url: String,
        method: HTTPMethod = .GET,
        parameters: [String: Any]? = nil
    ) async throws -> T {
        // 构建 URL
        guard var urlComponents = URLComponents(string: url) else {
            throw NetworkError.invalidURL
        }
        
        // GET 请求时将参数添加到 URL
        if method == .GET, let parameters = parameters {
            urlComponents.queryItems = parameters.map {
                URLQueryItem(name: $0.key, value: "\($0.value)")
            }
        }
        
        guard let finalURL = urlComponents.url else {
            throw NetworkError.invalidURL
        }
        
        // 创建请求
        var request = URLRequest(url: finalURL)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // POST 请求时将参数放入 body
        if method == .POST, let parameters = parameters {
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            let bodyString = parameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
            request.httpBody = bodyString.data(using: .utf8)
        }
        
        do {
            // 发起请求
            let (data, response) = try await session.data(for: request)
            
            // 打印原始响应数据（调试用）
            if let jsonString = String(data: data, encoding: .utf8) {
                print("API响应: \(jsonString)")
            }
            
            // 检查 HTTP 响应状态
            if let httpResponse = response as? HTTPURLResponse {
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw NetworkError.serverError(httpResponse.statusCode)
                }
            }
            
            // 解码数据
            let decoder = JSONDecoder()
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                print("解码错误: \(error)")
                throw NetworkError.decodingError
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.networkError(error)
        }
    }
}
