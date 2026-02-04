//
//  LifeView.swift
//  SwiftUI-news
//
//  Created by v_jinlqi on 2026/1/30.
//
//  生活页面 - 展示天气预报、旅游景区、实时油价、BFR体脂率

import SwiftUI

// MARK: - 生活页面
/// 生活模块主页面，包含天气预报、旅游景区、实时油价、BFR体脂率
struct LifeView: View {
    
    /// 视图模型
    @StateObject private var viewModel = LifeViewModel()
    
    /// 显示城市选择
    @State private var showCityPicker: Bool = false
    
    /// 显示中药详情
    @State private var selectedZhongyao: ZhongyaoData?
    
    /// 显示景区详情
    @State private var selectedScenic: ScenicData?
    
    /// 是否为iPad大屏布局
    private var isWideLayout: Bool {
        DeviceType.current.isIPad || DeviceType.current.isMac
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView {
                    if isWideLayout && geometry.size.width > 700 {
                        // iPad/Mac 双列布局
                        iPadLayout
                            .padding(.horizontal, 24)
                            .padding(.vertical, 20)
                    } else {
                        // iPhone 单列布局
                        iPhoneLayout
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                    }
                }
                .background(Color.platformGroupedBackground)
            }
            .navigationTitle("生活")
            .platformNavigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showCityPicker) {
                CityPickerSheet(currentCity: viewModel.currentCity) { city in
                    Task {
                        await viewModel.switchCity(city)
                    }
                }
            }
            .sheet(item: $selectedZhongyao) { zhongyao in
                ZhongyaoDetailSheet(zhongyao: zhongyao)
            }
            .sheet(item: $selectedScenic) { scenic in
                ScenicDetailSheet(scenic: scenic)
            }
        }
        .task {
            await viewModel.loadAllData()
        }
    }
    
    // MARK: - iPhone 单列布局
    private var iPhoneLayout: some View {
        VStack(spacing: 20) {
            weatherCard
            scenicSection
            oilPriceCard
            zhongyaoSection
            bfrSection
        }
    }
    
    // MARK: - iPad 双列布局（瀑布流）
    private var iPadLayout: some View {
        HStack(alignment: .top, spacing: 20) {
            // 左列
            VStack(spacing: 20) {
                weatherCard
                oilPriceCard
                bfrSection
            }
            .frame(maxWidth: .infinity)
            
            // 右列
            VStack(spacing: 20) {
                scenicSection
                zhongyaoSection
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    // MARK: - 卡片组件
    private var weatherCard: some View {
        WeatherCardView(
            weather: viewModel.weather,
            loading: viewModel.weatherLoading,
            currentCity: viewModel.currentCity,
            onCityTap: { showCityPicker = true }
        )
    }
    
    private var scenicSection: some View {
        ScenicSectionView(
            keyword: $viewModel.scenicKeyword,
            scenicList: viewModel.scenicList,
            loading: viewModel.scenicLoading,
            hasMore: viewModel.hasMoreScenic,
            onSearch: {
                Task { await viewModel.searchScenic() }
            },
            onLoadMore: {
                Task { await viewModel.loadMoreScenic() }
            },
            onSelect: { scenic in
                selectedScenic = scenic
            }
        )
    }
    
    private var oilPriceCard: some View {
        OilPriceCardView(
            oilPrice: viewModel.oilPrice,
            loading: viewModel.oilPriceLoading,
            onRefresh: {
                Task { await viewModel.refreshOilPrice() }
            }
        )
    }
    
    private var zhongyaoSection: some View {
        ZhongyaoSectionView(
            keyword: $viewModel.zhongyaoKeyword,
            zhongyaoList: viewModel.zhongyaoList,
            loading: viewModel.zhongyaoLoading,
            onSearch: {
                Task { await viewModel.searchZhongyao() }
            },
            onSelect: { zhongyao in
                selectedZhongyao = zhongyao
            }
        )
    }
    
    private var bfrSection: some View {
        BFRSectionView(
            sex: $viewModel.bfrSex,
            age: $viewModel.bfrAge,
            height: $viewModel.bfrHeight,
            weight: $viewModel.bfrWeight,
            bfrData: viewModel.bfrData,
            loading: viewModel.bfrLoading,
            onCalculate: {
                Task { await viewModel.calculateBFR() }
            }
        )
    }
}

// MARK: - 旅游景区搜索区域
struct ScenicSectionView: View {
    @Binding var keyword: String
    let scenicList: [ScenicData]
    let loading: Bool
    let hasMore: Bool
    let onSearch: () -> Void
    let onLoadMore: () -> Void
    let onSelect: (ScenicData) -> Void
    
    /// 热门城市
    private let hotCities = ["北京", "上海", "杭州", "苏州", "西安", "成都", "厦门", "三亚"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 标题栏
            HStack {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundStyle(.orange.gradient)
                Text("旅游景区")
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
                    TextField("搜索景点、城市...", text: $keyword)
                        .textFieldStyle(.plain)
                        .submitLabel(.search)
                        .onSubmit(onSearch)
                    
                    if !keyword.isEmpty {
                        Button {
                            keyword = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(10)
                .background(Color.platformGray6)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                Button(action: onSearch) {
                    Text("搜索")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.orange)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }
            .padding(16)
            
            // 热门城市标签
            if keyword.isEmpty && scenicList.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("热门城市")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    FlowLayout(spacing: 8) {
                        ForEach(hotCities, id: \.self) { city in
                            Button {
                                keyword = city
                                onSearch()
                            } label: {
                                Text(city)
                                    .font(.subheadline)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 7)
                                    .background(Color.orange.opacity(0.1))
                                    .foregroundColor(.orange)
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            
            // 景区列表
            if loading && scenicList.isEmpty {
                HStack {
                    Spacer()
                    ProgressView()
                        .padding(.vertical, 30)
                    Spacer()
                }
            } else if !scenicList.isEmpty {
                LazyVStack(spacing: 0) {
                    ForEach(Array(scenicList.enumerated()), id: \.element.id) { index, scenic in
                        Button {
                            onSelect(scenic)
                        } label: {
                            ScenicRowView(scenic: scenic)
                        }
                        .buttonStyle(.plain)
                        .onAppear {
                            // 当倒数第3项出现时自动加载更多
                            if index >= scenicList.count - 3 && hasMore && !loading {
                                onLoadMore()
                            }
                        }
                        
                        if index < scenicList.count - 1 {
                            Divider()
                                .padding(.horizontal, 16)
                        }
                    }
                    
                    // 加载状态指示器
                    if hasMore {
                        HStack {
                            Spacer()
                            if loading {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("加载中...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 12)
                    } else if scenicList.count > 0 {
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

// MARK: - 景区行视图
struct ScenicRowView: View {
    let scenic: ScenicData
    
    var body: some View {
        HStack(spacing: 12) {
            // 图标
            Image(systemName: "photo.fill")
                .font(.title2)
                .foregroundColor(.orange)
                .frame(width: 44, height: 44)
                .background(Color.orange.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(scenic.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text("\(scenic.province) · \(scenic.city)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .contentShape(Rectangle())
    }
}

// MARK: - 景区详情弹窗
struct ScenicDetailSheet: View {
    let scenic: ScenicData
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 头部信息
                    VStack(alignment: .leading, spacing: 8) {
                        Text(scenic.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        HStack {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.orange)
                            Text("\(scenic.province) · \(scenic.city)")
                                .foregroundColor(.secondary)
                        }
                        .font(.subheadline)
                    }
                    
                    Divider()
                    
                    // 景区介绍
                    VStack(alignment: .leading, spacing: 10) {
                        Text("景区介绍")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(scenic.content)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineSpacing(6)
                    }
                }
                .padding(20)
            }
            .navigationTitle("景区详情")
            .platformNavigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - 预览
#Preview {
    LifeView()
}
