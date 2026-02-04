//
//  CityPickerSheet.swift
//  SwiftUI-news
//
//  Created by v_jinlqi on 2026/1/30.
//
//  城市选择弹窗

import SwiftUI

// MARK: - 城市选择弹窗
struct CityPickerSheet: View {
    let currentCity: String
    let onSelect: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    
    private let cities = [
        "北京", "上海", "广州", "深圳", "杭州",
        "成都", "重庆", "武汉", "西安", "南京",
        "天津", "苏州", "郑州", "长沙", "东莞",
        "沈阳", "青岛", "宁波", "昆明", "大连"
    ]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(cities, id: \.self) { city in
                    Button {
                        onSelect(city)
                        dismiss()
                    } label: {
                        HStack {
                            Text(city)
                                .font(.body)
                                .foregroundColor(.primary)
                            Spacer()
                            if city == currentCity {
                                Image(systemName: "checkmark")
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("选择城市")
            .platformNavigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("取消") { dismiss() }
                }
            }
        }
        #if os(iOS)
        .presentationDetents([.medium])
        #else
        .frame(minWidth: 300, idealWidth: 350, minHeight: 400, idealHeight: 450)
        #endif
    }
}
