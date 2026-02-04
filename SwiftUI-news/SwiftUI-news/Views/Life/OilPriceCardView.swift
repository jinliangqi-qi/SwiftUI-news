//
//  OilPriceCardView.swift
//  SwiftUI-news
//
//  Created by v_jinlqi on 2026/2/2.
//
//  实时油价卡片视图

import SwiftUI

// MARK: - 实时油价卡片
struct OilPriceCardView: View {
    let oilPrice: OilPriceData?
    let loading: Bool
    let onRefresh: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 标题栏
            headerView
            
            Divider()
            
            // 内容区
            if loading {
                loadingView
            } else if let data = oilPrice {
                oilPriceContent(data)
            } else {
                emptyView
            }
        }
        .background(Color.platformBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - 标题栏
    private var headerView: some View {
        HStack {
            Image(systemName: "fuelpump.fill")
                .foregroundStyle(.orange.gradient)
            Text("实时油价")
                .font(.headline)
                .fontWeight(.semibold)
            
            // 显示当前省份
            if let province = oilPrice?.prov {
                Text("(\(province))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // 刷新按钮
            Button(action: onRefresh) {
                Image(systemName: "arrow.clockwise")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .padding(8)
                    .background(Color.platformGray6)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(16)
    }
    
    // MARK: - 加载中视图
    private var loadingView: some View {
        HStack {
            Spacer()
            ProgressView()
            Spacer()
        }
        .padding(.vertical, 40)
    }
    
    // MARK: - 空数据视图
    private var emptyView: some View {
        Text("暂无油价数据")
            .font(.subheadline)
            .foregroundColor(.secondary)
            .padding(16)
    }
    
    // MARK: - 油价内容
    private func oilPriceContent(_ data: OilPriceData) -> some View {
        VStack(spacing: 12) {
            // 油价网格
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                oilPriceItem(type: "92#", price: data.p92, color: .green)
                oilPriceItem(type: "95#", price: data.p95, color: .blue)
                oilPriceItem(type: "98#", price: data.p98, color: .purple)
                oilPriceItem(type: "0#柴油", price: data.p0, color: .orange)
                if !data.p89.isEmpty && data.p89 != "0" {
                    oilPriceItem(type: "89#", price: data.p89, color: .cyan)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            
            // 更新时间
            HStack {
                Image(systemName: "clock")
                    .font(.caption2)
                Text("更新时间：\(data.formattedTime)")
                    .font(.caption)
            }
            .foregroundColor(.secondary)
            .padding(.bottom, 12)
        }
    }
    
    // MARK: - 油价项
    private func oilPriceItem(type: String, price: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(type)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("¥")
                    .font(.caption)
                    .foregroundColor(color)
                Text(price)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            
            Text("元/升")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
