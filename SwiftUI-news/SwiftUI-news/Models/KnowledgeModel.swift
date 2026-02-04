//
//  KnowledgeModel.swift
//  SwiftUI-news
//
//  Created by v_jinlqi on 2026/1/30.
//
//  知识模块数据模型 - 唐诗三百首、励志古言

import Foundation
import SwiftUI

// MARK: - 脑筋急转弯数据模型

/// 脑筋急转弯API响应
struct BrainTeaserResponse: Decodable {
    let code: Int
    let msg: String
    let result: BrainTeaserResult?
}

/// 脑筋急转弯结果
struct BrainTeaserResult: Decodable {
    let list: [BrainTeaserData]
}

/// 脑筋急转弯数据
struct BrainTeaserData: Codable, Identifiable {
    var id: String = UUID().uuidString  // 使用UUID作为唯一ID
    
    let quest: String      // 问题
    let result: String     // 答案（API返回字段名为result）
    
    enum CodingKeys: String, CodingKey {
        case quest, result
    }
    
    /// 答案（别名，方便使用）
    var answer: String { result }
}

// MARK: - 百科题库数据模型

/// 百科题库API响应
struct QuizResponse: Decodable {
    let code: Int
    let msg: String
    let result: QuizData?
}

/// 百科题库数据
struct QuizData: Codable, Identifiable {
    var id: String { title }
    
    let title: String      // 题目问题
    let answer: String     // 正确答案（A/B/C/D）
    let answerA: String    // 选项A
    let answerB: String    // 选项B
    let answerC: String    // 选项C
    let answerD: String    // 选项D
    let analytic: String?  // 答案解析
    
    /// 所有选项
    var options: [(key: String, value: String)] {
        [("A", answerA), ("B", answerB), ("C", answerC), ("D", answerD)]
    }
    
    /// 正确答案的完整内容
    var correctAnswerContent: String {
        switch answer {
        case "A": return answerA
        case "B": return answerB
        case "C": return answerC
        case "D": return answerD
        default: return answer
        }
    }
}
