//
//  DouyinWebPlayer.swift
//  SwiftUI-news
//
//  Created by v_jinlqi on 2026/2/2.
//
//  抖音自定义WebView播放器 - 优化抖音网页浏览体验

import SwiftUI
import WebKit

#if os(iOS)

// MARK: - 抖音WebView播放器
/// 自定义抖音WebView播放器，优化移动端浏览体验
struct DouyinWebPlayer: UIViewRepresentable {
    let keyword: String
    @Binding var isLoading: Bool
    @Binding var loadProgress: Double
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        
        // 允许内联播放视频
        configuration.allowsInlineMediaPlayback = true
        // 不需要用户手势即可播放
        configuration.mediaTypesRequiringUserActionForPlayback = []
        // 允许AirPlay
        configuration.allowsAirPlayForMediaPlayback = true
        // 允许画中画
        configuration.allowsPictureInPictureMediaPlayback = true
        
        // 注入自定义CSS和JS优化体验
        let userScript = WKUserScript(
            source: Self.injectedScript,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false
        )
        configuration.userContentController.addUserScript(userScript)
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.isOpaque = false
        webView.backgroundColor = .black
        webView.scrollView.backgroundColor = .black
        
        // 模拟移动端UA以获得更好的体验
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
        
        // 加载抖音搜索页
        if let encoded = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: "https://www.douyin.com/search/\(encoded)") {
            webView.load(URLRequest(url: url))
        }
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {}
    
    // MARK: - 注入的JS/CSS脚本
    /// 优化抖音网页体验的脚本
    private static var injectedScript: String {
        """
        (function() {
            // 注入自定义样式
            var style = document.createElement('style');
            style.textContent = `
                /* 隐藏顶部导航栏 */
                header, .header, [class*="header"] {
                    display: none !important;
                }
                
                /* 隐藏下载App提示 */
                [class*="download"], [class*="Download"],
                [class*="app-guide"], [class*="AppGuide"],
                [class*="open-app"], [class*="OpenApp"] {
                    display: none !important;
                }
                
                /* 隐藏底部导航 */
                footer, .footer, [class*="footer"],
                [class*="bottom-bar"], [class*="BottomBar"] {
                    display: none !important;
                }
                
                /* 隐藏登录弹窗 */
                [class*="login-modal"], [class*="LoginModal"],
                [class*="login-guide"], [class*="LoginGuide"] {
                    display: none !important;
                }
                
                /* 优化视频容器 */
                video {
                    object-fit: contain !important;
                    background: #000 !important;
                }
                
                /* 优化页面背景 */
                body {
                    background: #000 !important;
                }
                
                /* 隐藏遮罩层 */
                [class*="mask"], [class*="Mask"],
                [class*="overlay"], [class*="Overlay"] {
                    display: none !important;
                }
            `;
            document.head.appendChild(style);
            
            // 自动关闭弹窗
            function closePopups() {
                var closeButtons = document.querySelectorAll('[class*="close"], [class*="Close"], [aria-label="关闭"]');
                closeButtons.forEach(function(btn) {
                    if (btn.offsetParent !== null) {
                        btn.click();
                    }
                });
            }
            
            // 延迟执行关闭弹窗
            setTimeout(closePopups, 1000);
            setTimeout(closePopups, 2000);
            setTimeout(closePopups, 3000);
            
            // 监听DOM变化，自动关闭新弹窗
            var observer = new MutationObserver(function(mutations) {
                setTimeout(closePopups, 500);
            });
            observer.observe(document.body, { childList: true, subtree: true });
        })();
        """
    }
    
    // MARK: - Coordinator
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: DouyinWebPlayer
        
        init(_ parent: DouyinWebPlayer) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
            parent.loadProgress = 1.0
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
        }
        
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            parent.loadProgress = 0.5
        }
    }
}

// MARK: - 抖音播放器容器视图
/// 带有自定义控制栏的抖音播放器
struct DouyinPlayerView: View {
    let keyword: String
    @Environment(\.dismiss) private var dismiss
    
    @State private var isLoading = true
    @State private var loadProgress: Double = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 黑色背景
                Color.black.ignoresSafeArea()
                
                // WebView播放器
                DouyinWebPlayer(
                    keyword: keyword,
                    isLoading: $isLoading,
                    loadProgress: $loadProgress
                )
                .ignoresSafeArea(edges: .bottom)
                
                // 加载指示器
                if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.2)
                        
                        Text("正在加载...")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
            .navigationTitle(keyword)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.black, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    // 在Safari中打开
                    Button {
                        openInSafari()
                    } label: {
                        Image(systemName: "safari")
                            .font(.body)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    /// 在Safari中打开
    private func openInSafari() {
        if let encoded = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: "https://www.douyin.com/search/\(encoded)") {
            UIApplication.shared.open(url)
        }
    }
}

#else

// MARK: - macOS 版本
struct DouyinPlayerView: View {
    let keyword: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "play.rectangle")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("抖音播放器")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("macOS 暂不支持内嵌播放，请在浏览器中查看")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button("在浏览器中打开") {
                if let encoded = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                   let url = URL(string: "https://www.douyin.com/search/\(encoded)") {
                    NSWorkspace.shared.open(url)
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(minWidth: 400, minHeight: 300)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("关闭") { dismiss() }
            }
        }
    }
}

#endif
