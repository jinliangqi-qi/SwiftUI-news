//
//  SafariView.swift
//  SwiftUI-news
//
//  Created by v_jinlqi on 2026/1/30.
//
//  Safari 视图 - 封装网页浏览（跨平台）

import SwiftUI

#if os(iOS)
import SafariServices

// MARK: - Safari 视图包装器 (iOS)
/// 使用 UIViewControllerRepresentable 封装 SFSafariViewController
struct SafariView: UIViewControllerRepresentable {
    
    /// 要加载的 URL
    let url: URL
    
    /// 创建 UIViewController
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true  // 如果可用则进入阅读模式
        
        let safariVC = SFSafariViewController(url: url, configuration: config)
        
        return safariVC
    }
    
    /// 更新 UIViewController（此处不需要更新）
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

#elseif os(macOS)

import AppKit

// MARK: - Web 视图包装器 (macOS)
/// macOS 下使用 Link 打开默认浏览器
struct SafariView: View {
    
    /// 要加载的 URL
    let url: URL
    
    /// 关闭弹窗
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            .padding(.top, 12)
            
            Spacer()
            
            Image(systemName: "safari")
                .font(.system(size: 60))
                .foregroundStyle(.blue.gradient)
            
            Text("已在浏览器中打开")
                .font(.title2)
                .fontWeight(.medium)
            
            Text(url.absoluteString)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .padding(.horizontal)
            
            Button("再次打开") {
                NSWorkspace.shared.open(url)
            }
            .buttonStyle(.borderedProminent)
            
            Spacer()
        }
        .frame(minWidth: 400, minHeight: 300)
        .onAppear {
            // 自动打开浏览器
            NSWorkspace.shared.open(url)
        }
    }
}

#endif
