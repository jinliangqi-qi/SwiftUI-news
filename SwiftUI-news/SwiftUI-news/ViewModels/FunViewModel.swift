//
//  FunViewModel.swift
//  SwiftUI-news
//
//  Created by v_jinlqi on 2026/1/30.
//
//  趣味娱乐模块视图模型 - 管理周公解梦、星座运势等状态

import Foundation
import SwiftUI
import Combine

// MARK: - 趣味娱乐视图模型
/// 趣味娱乐页面状态管理
@MainActor
final class FunViewModel: ObservableObject {
    
    // MARK: - 周公解梦状态
    
    /// 解梦搜索关键词
    @Published var dreamKeyword: String = ""
    
    /// 解梦搜索结果
    @Published var dreamResults: [DreamData] = []
    
    /// 解梦加载状态
    @Published var isDreamLoading: Bool = false
    
    /// 解梦错误信息
    @Published var dreamError: String?
    
    /// 是否已搜索过
    @Published var hasSearched: Bool = false
    
    // MARK: - 星座运势状态
    
    /// 当前选中的星座
    @Published var selectedConstellation: Constellation = .aries
    
    /// 星座运势数据
    @Published var starFortune: [StarItem] = []
    
    /// 星座运势加载状态
    @Published var isStarLoading: Bool = false
    
    /// 星座运势错误信息
    @Published var starError: String?
    
    // MARK: - 故事大全状态
    
    /// 当前选中的故事类型
    @Published var selectedStoryType: StoryType = .fable
    
    /// 故事搜索关键词
    @Published var storyKeyword: String = ""
    
    /// 故事列表
    @Published var storyList: [StoryData] = []
    
    /// 故事加载状态
    @Published var isStoryLoading: Bool = false
    
    /// 故事错误信息
    @Published var storyError: String?
    
    /// 当前故事页码
    private var storyPage: Int = 1
    
    /// 是否有更多故事
    @Published var hasMoreStory: Bool = true
    
    // MARK: - 服务
    
    private let funService = FunService.shared
    
    // MARK: - 周公解梦方法
    
    /// 搜索解梦
    func searchDream() async {
        let keyword = dreamKeyword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !keyword.isEmpty else { return }
        
        isDreamLoading = true
        dreamError = nil
        hasSearched = true
        
        do {
            dreamResults = try await funService.fetchDream(word: keyword)
        } catch {
            dreamError = error.localizedDescription
            dreamResults = []
        }
        
        isDreamLoading = false
    }
    
    /// 清除搜索结果
    func clearDreamResults() {
        dreamKeyword = ""
        dreamResults = []
        dreamError = nil
        hasSearched = false
    }
    
    // MARK: - 星座运势方法
    
    /// 获取星座运势
    func fetchStarFortune() async {
        isStarLoading = true
        starError = nil
        
        do {
            starFortune = try await funService.fetchStarFortune(constellation: selectedConstellation)
        } catch {
            starError = error.localizedDescription
            starFortune = []
        }
        
        isStarLoading = false
    }
    
    /// 切换星座
    func selectConstellation(_ constellation: Constellation) async {
        selectedConstellation = constellation
        await fetchStarFortune()
    }
    
    // MARK: - 故事大全方法
    
    /// 获取故事列表
    func fetchStory(refresh: Bool = false) async {
        if refresh {
            storyPage = 1
            hasMoreStory = true
        }
        
        isStoryLoading = true
        storyError = nil
        
        do {
            let keyword = storyKeyword.trimmingCharacters(in: .whitespacesAndNewlines)
            let stories = try await funService.fetchStory(
                type: selectedStoryType,
                word: keyword,
                num: 10,
                page: storyPage,
                forceRefresh: refresh
            )
            
            if refresh {
                storyList = stories
            } else {
                storyList.append(contentsOf: stories)
            }
            
            hasMoreStory = stories.count >= 10
        } catch {
            storyError = error.localizedDescription
            if refresh {
                storyList = []
            }
        }
        
        isStoryLoading = false
    }
    
    /// 加载更多故事
    func loadMoreStory() async {
        guard !isStoryLoading && hasMoreStory else { return }
        storyPage += 1
        await fetchStory(refresh: false)
    }
    
    /// 切换故事类型
    func selectStoryType(_ type: StoryType) async {
        selectedStoryType = type
        await fetchStory(refresh: true)
    }
    
    /// 清除故事搜索
    func clearStorySearch() {
        storyKeyword = ""
    }
}
