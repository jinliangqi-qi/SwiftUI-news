//
//  ZhongyaoSectionView.swift
//  SwiftUI-news
//
//  Created by v_jinlqi on 2026/1/30.
//
//  中药大全区域视图

import SwiftUI

// MARK: - 中药大全区域
struct ZhongyaoSectionView: View {
    @Binding var keyword: String
    let zhongyaoList: [ZhongyaoData]
    let loading: Bool
    let onSearch: () -> Void
    let onSelect: (ZhongyaoData) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 标题栏
            HStack {
                Image(systemName: "leaf.fill")
                    .foregroundStyle(.green.gradient)
                Text("中药大全")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding(16)
            
            Divider()
            
            // 搜索框
            HStack(spacing: 12) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("输入中药名称，如：金银花", text: $keyword)
                        .textFieldStyle(.plain)
                        .submitLabel(.search)
                        .onSubmit(onSearch)
                }
                .padding(10)
                .background(Color.platformGray6)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                Button(action: onSearch) {
                    Text("搜索")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.green)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
                .disabled(loading)
            }
            .padding(16)
            
            // 加载状态或结果
            if loading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .padding(.vertical, 20)
            } else if !zhongyaoList.isEmpty {
                Divider()
                
                // 搜索结果列表
                VStack(spacing: 0) {
                    ForEach(Array(zhongyaoList.enumerated()), id: \.element.id) { index, zhongyao in
                        Button {
                            onSelect(zhongyao)
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(zhongyao.title)
                                        .font(.body)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                    
                                    let info = zhongyao.parsedInfo
                                    if !info.function.isEmpty {
                                        Text("功效：\(info.function)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .lineLimit(2)
                                    }
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.tertiaryLabel)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        
                        if index < zhongyaoList.count - 1 {
                            Divider()
                                .padding(.leading, 16)
                        }
                    }
                }
            } else if !keyword.isEmpty {
                Text("未找到相关中药，请尝试其他关键词")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            } else {
                // 常用中药推荐
                zhongyaoRecommendView
            }
        }
        .background(Color.platformBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    /// 常用中药推荐
    private var zhongyaoRecommendView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("常用中药")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            FlowLayout(spacing: 8) {
                ForEach(["人参", "金银花", "枸杞", "黄芪", "当归", "甘草"], id: \.self) { name in
                    Button {
                        keyword = name
                        onSearch()
                    } label: {
                        Text(name)
                            .font(.subheadline)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(Color.green.opacity(0.1))
                            .foregroundColor(.green)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
}

// MARK: - 中药详情弹窗
struct ZhongyaoDetailSheet: View {
    let zhongyao: ZhongyaoData
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // 标题
                    HStack {
                        Image(systemName: "leaf.fill")
                            .font(.title2)
                            .foregroundStyle(.green.gradient)
                        Text(zhongyao.title)
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .padding(.bottom, 8)
                    
                    let info = zhongyao.parsedInfo
                    
                    // 基本信息
                    if !info.category.isEmpty {
                        ZhongyaoInfoSection(title: "类别", content: info.category, icon: "tag.fill")
                    }
                    
                    if !info.alias.isEmpty {
                        ZhongyaoInfoSection(title: "别名", content: info.alias, icon: "textformat.alt")
                    }
                    
                    if !info.property.isEmpty {
                        ZhongyaoInfoSection(title: "性味", content: info.property, icon: "drop.fill")
                    }
                    
                    if !info.function.isEmpty {
                        ZhongyaoInfoSection(title: "功能主治", content: info.function, icon: "cross.case.fill")
                    }
                    
                    if !info.usage.isEmpty {
                        ZhongyaoInfoSection(title: "用法用量", content: info.usage, icon: "scalemass.fill")
                    }
                    
                    if !info.source.isEmpty {
                        ZhongyaoInfoSection(title: "来源", content: info.source, icon: "leaf.arrow.triangle.circlepath")
                    }
                    
                    if !info.morphology.isEmpty {
                        ZhongyaoInfoSection(title: "植物形态", content: info.morphology, icon: "tree.fill")
                    }
                    
                    if !info.habitat.isEmpty {
                        ZhongyaoInfoSection(title: "生长地", content: info.habitat, icon: "map.fill")
                    }
                    
                    if !info.chemistry.isEmpty {
                        ZhongyaoInfoSection(title: "化学成份", content: info.chemistry, icon: "flask.fill")
                    }
                }
                .padding(20)
            }
            .background(Color.platformGroupedBackground)
            .navigationTitle("中药详情")
            .platformNavigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("关闭") { dismiss() }
                }
            }
        }
        #if os(iOS)
        .presentationDetents([.large])
        #else
        .frame(minWidth: 450, idealWidth: 500, minHeight: 500, idealHeight: 600)
        #endif
    }
}

// MARK: - 中药信息区块
struct ZhongyaoInfoSection: View {
    let title: String
    let content: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(.green)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            
            Text(content)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineSpacing(4)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.platformBackground)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
