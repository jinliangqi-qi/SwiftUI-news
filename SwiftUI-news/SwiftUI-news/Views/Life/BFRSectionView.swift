//
//  BFRSectionView.swift
//  SwiftUI-news
//
//  Created by v_jinlqi on 2026/1/30.
//
//  BFR体脂率区域视图

import SwiftUI

// MARK: - BFR体脂率区域
struct BFRSectionView: View {
    @Binding var sex: BFRSex
    @Binding var age: Int
    @Binding var height: Int
    @Binding var weight: Int
    let bfrData: BFRData?
    let loading: Bool
    let onCalculate: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 标题栏
            HStack {
                Image(systemName: "figure.stand")
                    .foregroundStyle(.green.gradient)
                Text("BFR体脂率")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding(16)
            
            Divider()
            
            // 输入表单
            bfrInputForm
                .padding(16)
            
            // 计算按钮
            Button(action: onCalculate) {
                HStack {
                    if loading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "function")
                        Text("计算体脂率")
                    }
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.green)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
            .disabled(loading)
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            
            // 结果展示
            if let bfr = bfrData {
                Divider()
                BFRResultView(bfr: bfr)
            }
        }
        .background(Color.platformBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    /// BFR输入表单
    private var bfrInputForm: some View {
        VStack(spacing: 16) {
            // 性别选择
            HStack {
                Text("性别")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .frame(width: 50, alignment: .leading)
                
                HStack(spacing: 12) {
                    ForEach(BFRSex.allCases) { sexOption in
                        Button {
                            sex = sexOption
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: sexOption == .male ? "person.fill" : "person.fill")
                                Text(sexOption.displayName)
                            }
                            .font(.system(size: 14, weight: .medium))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(sex == sexOption ? Color.green : Color.platformGray6)
                            .foregroundColor(sex == sexOption ? .white : .primary)
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                Spacer()
            }
            
            Divider()
            
            // 年龄输入
            HStack {
                Text("年龄")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .frame(width: 50, alignment: .leading)
                
                Spacer()
                
                Stepper(value: $age, in: 10...100, step: 1) {
                    Text("\(age) 岁")
                        .font(.system(size: 15, weight: .medium))
                }
            }
            
            Divider()
            
            // 身高输入
            HStack {
                Text("身高")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .frame(width: 50, alignment: .leading)
                
                Spacer()
                
                Stepper(value: $height, in: 100...250, step: 1) {
                    Text("\(height) cm")
                        .font(.system(size: 15, weight: .medium))
                }
            }
            
            Divider()
            
            // 体重输入
            HStack {
                Text("体重")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .frame(width: 50, alignment: .leading)
                
                Spacer()
                
                Stepper(value: $weight, in: 30...200, step: 1) {
                    Text("\(weight) kg")
                        .font(.system(size: 15, weight: .medium))
                }
            }
        }
    }
}

// MARK: - BFR结果展示
struct BFRResultView: View {
    let bfr: BFRData
    
    var body: some View {
        VStack(spacing: 16) {
            // 主要数据
            HStack(spacing: 20) {
                // 体脂率
                VStack(spacing: 4) {
                    Text(bfr.bfr)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.green)
                    Text("当前体脂率")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                    .frame(height: 60)
                
                // 标准体重
                VStack(spacing: 4) {
                    Text("\(bfr.idealweight)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.blue)
                    Text("标准体重(kg)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(16)
            
            Divider()
            
            // 详细信息
            VStack(spacing: 0) {
                BFRInfoRow(label: "健康风险", value: bfr.healthy)
                Divider().padding(.leading, 16)
                BFRInfoRow(label: "正常体脂率", value: bfr.normbfr)
                Divider().padding(.leading, 16)
                BFRInfoRow(label: "正常体重范围", value: "\(bfr.normweight) kg")
            }
            
            // 提示信息
            if !bfr.tip.isEmpty {
                Divider()
                
                Text(bfr.tip)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineSpacing(4)
                    .padding(16)
            }
        }
    }
}

// MARK: - BFR信息行
struct BFRInfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
