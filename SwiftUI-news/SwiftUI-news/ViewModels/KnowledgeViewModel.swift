//
//  KnowledgeViewModel.swift
//  SwiftUI-news
//
//  Created by v_jinlqi on 2026/1/30.
//
//  知识模块视图模型 - 管理脑筋急转弯、百科题库等状态

import Foundation
import SwiftUI
import Combine

// MARK: - 知识视图模型
/// 知识页面状态管理
@MainActor
final class KnowledgeViewModel: ObservableObject {
    
    // MARK: - 脑筋急转弯状态
    
    /// 脑筋急转弯列表
    @Published var brainTeaserList: [BrainTeaserData] = []
    
    /// 脑筋急转弯加载状态
    @Published var isBrainTeaserLoading: Bool = false
    
    /// 脑筋急转弯错误信息
    @Published var brainTeaserError: String?
    
    /// 当前页码
    @Published var brainTeaserPage: Int = 1
    
    /// 是否还有更多数据
    @Published var hasMoreBrainTeaser: Bool = true
    
    /// 展开显示答案的题目ID集合
    @Published var expandedBrainTeaserIds: Set<String> = []
    
    // MARK: - 百科题库状态
    
    /// 当前题目
    @Published var currentQuiz: QuizData?
    
    /// 百科题库加载状态
    @Published var isQuizLoading: Bool = false
    
    /// 百科题库错误信息
    @Published var quizError: String?
    
    /// 用户选择的答案
    @Published var selectedAnswer: String?
    
    /// 是否已提交答案
    @Published var hasSubmitted: Bool = false
    
    // MARK: - 服务
    
    private let knowledgeService = KnowledgeService.shared
    
    // MARK: - 脑筋急转弯方法
    
    /// 获取脑筋急转弯
    func fetchBrainTeaser(refresh: Bool = false) async {
        if refresh {
            brainTeaserPage = 1
            hasMoreBrainTeaser = true
            expandedBrainTeaserIds = []
        }
        
        guard !isBrainTeaserLoading else { return }
        
        isBrainTeaserLoading = true
        brainTeaserError = nil
        
        do {
            let results = try await knowledgeService.fetchBrainTeaser(
                num: 10,
                page: brainTeaserPage,
                forceRefresh: refresh
            )
            
            if refresh {
                brainTeaserList = results
            } else {
                brainTeaserList.append(contentsOf: results)
            }
            
            hasMoreBrainTeaser = results.count >= 10
            
        } catch {
            brainTeaserError = error.localizedDescription
            if refresh {
                brainTeaserList = []
            }
        }
        
        isBrainTeaserLoading = false
    }
    
    /// 加载更多脑筋急转弯
    func loadMoreBrainTeaser() async {
        guard hasMoreBrainTeaser && !isBrainTeaserLoading else { return }
        brainTeaserPage += 1
        await fetchBrainTeaser()
    }
    
    /// 切换显示答案
    func toggleBrainTeaserAnswer(_ id: String) {
        if expandedBrainTeaserIds.contains(id) {
            expandedBrainTeaserIds.remove(id)
        } else {
            expandedBrainTeaserIds.insert(id)
        }
    }
    
    /// 检查是否显示答案
    func isAnswerExpanded(_ id: String) -> Bool {
        expandedBrainTeaserIds.contains(id)
    }
    
    // MARK: - 百科题库方法
    
    /// 获取百科题目
    func fetchQuiz(forceRefresh: Bool = false) async {
        isQuizLoading = true
        quizError = nil
        selectedAnswer = nil
        hasSubmitted = false
        
        do {
            currentQuiz = try await knowledgeService.fetchQuiz(forceRefresh: forceRefresh)
        } catch {
            quizError = error.localizedDescription
        }
        
        isQuizLoading = false
    }
    
    /// 刷新题目（获取新题）
    func refreshQuiz() async {
        await fetchQuiz(forceRefresh: true)
    }
    
    /// 选择答案
    func selectAnswer(_ answer: String) {
        guard !hasSubmitted else { return }
        selectedAnswer = answer
    }
    
    /// 提交答案
    func submitAnswer() {
        guard selectedAnswer != nil else { return }
        hasSubmitted = true
    }
    
    /// 检查答案是否正确
    var isAnswerCorrect: Bool {
        guard let quiz = currentQuiz, let selected = selectedAnswer else { return false }
        return selected == quiz.answer
    }
}
