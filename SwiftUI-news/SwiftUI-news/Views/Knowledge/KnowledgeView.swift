//
//  KnowledgeView.swift
//  SwiftUI-news
//
//  Created by v_jinlqi on 2026/1/30.
//
//  知识页面 - 脑筋急转弯、百科题库

import SwiftUI

// MARK: - 知识页面
/// 知识主页面
struct KnowledgeView: View {
    
    @StateObject private var viewModel = KnowledgeViewModel()
    
    /// 是否为iPad大屏布局
    private var isWideLayout: Bool {
        DeviceType.current.isIPad || DeviceType.current.isMac
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView(showsIndicators: false) {
                    if isWideLayout && geometry.size.width > 700 {
                        // iPad 双列瀑布流布局
                        HStack(alignment: .top, spacing: 20) {
                            // 左列：百科题库
                            VStack(spacing: 20) {
                                quizCard
                            }
                            .frame(maxWidth: .infinity)
                            
                            // 右列：脑筋急转弯
                            VStack(spacing: 20) {
                                brainTeaserSection
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(24)
                    } else {
                        // iPhone 单列布局
                        VStack(spacing: 20) {
                            quizCard
                            brainTeaserSection
                        }
                        .padding()
                    }
                }
                .background(Color.platformGroupedBackground)
            }
            .navigationTitle("知识")
        }
        .task {
            await viewModel.fetchQuiz()
            await viewModel.fetchBrainTeaser(refresh: true)
        }
    }
    
    // MARK: - 百科题库卡片
    
    private var quizCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 标题栏
            HStack {
                Image(systemName: "questionmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.green.gradient)
                Text("百科题库")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
                
                Button {
                    Task { await viewModel.refreshQuiz() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .disabled(viewModel.isQuizLoading)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            
            Divider()
                .padding(.horizontal, 16)
            
            // 内容
            if viewModel.isQuizLoading && viewModel.currentQuiz == nil {
                HStack {
                    Spacer()
                    ProgressView()
                        .padding(.vertical, 40)
                    Spacer()
                }
            } else if let error = viewModel.quizError, viewModel.currentQuiz == nil {
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.title2)
                        .foregroundColor(.orange)
                    Text(error)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
            } else if let quiz = viewModel.currentQuiz {
                quizContent(quiz: quiz)
            }
        }
        .background(Color.platformBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    /// 题目内容
    private func quizContent(quiz: QuizData) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // 题目
            Text(quiz.title)
                .font(.headline)
                .lineSpacing(4)
            
            // 选项
            VStack(spacing: 10) {
                ForEach(quiz.options, id: \.key) { option in
                    quizOptionButton(key: option.key, value: option.value, quiz: quiz)
                }
            }
            
            // 提交按钮或结果
            if !viewModel.hasSubmitted {
                Button {
                    viewModel.submitAnswer()
                } label: {
                    Text("提交答案")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(viewModel.selectedAnswer == nil ? Color.gray : Color.green)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
                .disabled(viewModel.selectedAnswer == nil)
            } else {
                // 显示结果
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: viewModel.isAnswerCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(viewModel.isAnswerCorrect ? .green : .red)
                        Text(viewModel.isAnswerCorrect ? "回答正确！" : "回答错误")
                            .fontWeight(.medium)
                            .foregroundColor(viewModel.isAnswerCorrect ? .green : .red)
                        Spacer()
                        Text("正确答案: \(quiz.answer)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // 解析
                    if let analytic = quiz.analytic, !analytic.isEmpty {
                        Divider()
                        VStack(alignment: .leading, spacing: 6) {
                            Text("解析")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            Text(analytic)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineSpacing(4)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.platformGray6)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    
                    // 下一题按钮
                    Button {
                        Task { await viewModel.refreshQuiz() }
                    } label: {
                        Text("下一题")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.green)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
    }
    
    /// 选项按钮
    private func quizOptionButton(key: String, value: String, quiz: QuizData) -> some View {
        let isSelected = viewModel.selectedAnswer == key
        let isCorrect = quiz.answer == key
        let showResult = viewModel.hasSubmitted
        
        var backgroundColor: Color {
            if showResult {
                if isCorrect {
                    return Color.green.opacity(0.15)
                } else if isSelected && !isCorrect {
                    return Color.red.opacity(0.15)
                }
            } else if isSelected {
                return Color.green.opacity(0.15)
            }
            return Color.platformGray6
        }
        
        var borderColor: Color {
            if showResult {
                if isCorrect {
                    return .green
                } else if isSelected && !isCorrect {
                    return .red
                }
            } else if isSelected {
                return .green
            }
            return .clear
        }
        
        return Button {
            viewModel.selectAnswer(key)
        } label: {
            HStack(spacing: 12) {
                Text(key)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(isSelected || (showResult && isCorrect) ? .white : .primary)
                    .frame(width: 28, height: 28)
                    .background(
                        Circle()
                            .fill(isSelected || (showResult && isCorrect) ? Color.green : Color.platformGray5)
                    )
                
                Text(value)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if showResult && isCorrect {
                    Image(systemName: "checkmark")
                        .foregroundColor(.green)
                        .fontWeight(.bold)
                } else if showResult && isSelected && !isCorrect {
                    Image(systemName: "xmark")
                        .foregroundColor(.red)
                        .fontWeight(.bold)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(borderColor, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .disabled(viewModel.hasSubmitted)
    }
    
    // MARK: - 脑筋急转弯区域
    
    private var brainTeaserSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 标题栏
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.title2)
                    .foregroundStyle(.orange.gradient)
                Text("脑筋急转弯")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
                
                Button {
                    Task { await viewModel.fetchBrainTeaser(refresh: true) }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .disabled(viewModel.isBrainTeaserLoading)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            
            Divider()
                .padding(.horizontal, 16)
            
            // 脑筋急转弯列表
            if viewModel.isBrainTeaserLoading && viewModel.brainTeaserList.isEmpty {
                HStack {
                    Spacer()
                    ProgressView()
                        .padding(.vertical, 40)
                    Spacer()
                }
            } else if let error = viewModel.brainTeaserError, viewModel.brainTeaserList.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.title2)
                        .foregroundColor(.orange)
                    Text(error)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else if !viewModel.brainTeaserList.isEmpty {
                LazyVStack(spacing: 0) {
                    ForEach(Array(viewModel.brainTeaserList.enumerated()), id: \.element.id) { index, item in
                        BrainTeaserRowView(
                            item: item,
                            index: index + 1,
                            isExpanded: viewModel.isAnswerExpanded(item.id),
                            onToggle: { viewModel.toggleBrainTeaserAnswer(item.id) }
                        )
                        .onAppear {
                            // 当倒数第3项出现时自动加载更多
                            if index >= viewModel.brainTeaserList.count - 3 && viewModel.hasMoreBrainTeaser && !viewModel.isBrainTeaserLoading {
                                Task { await viewModel.loadMoreBrainTeaser() }
                            }
                        }
                        
                        if index < viewModel.brainTeaserList.count - 1 {
                            Divider()
                                .padding(.horizontal, 16)
                        }
                    }
                    
                    // 加载状态指示器
                    if viewModel.hasMoreBrainTeaser {
                        HStack {
                            Spacer()
                            if viewModel.isBrainTeaserLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("加载中...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 12)
                    } else if viewModel.brainTeaserList.count > 0 {
                        Text("已加载全部")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                }
            }
        }
        .background(Color.platformBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - 脑筋急转弯行视图
struct BrainTeaserRowView: View {
    let item: BrainTeaserData
    let index: Int
    let isExpanded: Bool
    let onToggle: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 问题
            HStack(alignment: .top, spacing: 12) {
                // 序号
                Text("\(index)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 28, height: 28)
                    .background(Circle().fill(Color.orange))
                
                // 问题内容
                Text(item.quest)
                    .font(.subheadline)
                    .lineSpacing(4)
                    .foregroundColor(.primary)
                
                Spacer(minLength: 0)
            }
            
            // 答案区域
            Button(action: onToggle) {
                HStack {
                    if isExpanded {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.orange)
                        Text(item.answer)
                            .font(.subheadline)
                            .foregroundColor(.orange)
                            .lineSpacing(4)
                            .multilineTextAlignment(.leading)
                    } else {
                        Image(systemName: "eye.fill")
                            .foregroundColor(.secondary)
                        Text("点击查看答案")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(12)
                .background(isExpanded ? Color.orange.opacity(0.1) : Color.platformGray6)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
        }
        .padding(16)
    }
}

// MARK: - 预览
#Preview {
    KnowledgeView()
}
