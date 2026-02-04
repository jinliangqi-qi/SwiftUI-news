//
//  LifeViewModel.swift
//  SwiftUI-news
//
//  Created by v_jinlqi on 2026/1/30.
//
//  生活模块视图模型 - 管理天气、旅游景区、油价、BFR体脂率、中药大全数据

import Foundation
import SwiftUI
import Combine

// MARK: - 生活视图模型
/// 生活模块的 ViewModel，管理各项生活数据
@MainActor
final class LifeViewModel: ObservableObject {
    
    // MARK: - 发布属性
    
    /// 天气预报数据
    @Published var weather: WeatherData?
    
    /// 天气加载状态
    @Published var weatherLoading: Bool = false
    
    /// 旅游景区搜索关键词
    @Published var scenicKeyword: String = ""
    
    /// 旅游景区列表
    @Published var scenicList: [ScenicData] = []
    
    /// 旅游景区加载状态
    @Published var scenicLoading: Bool = false
    
    /// 旅游景区当前页
    @Published var scenicPage: Int = 1
    
    /// 是否还有更多景区
    @Published var hasMoreScenic: Bool = true
    
    /// 实时油价数据
    @Published var oilPrice: OilPriceData?
    
    /// 油价加载状态
    @Published var oilPriceLoading: Bool = false
    
    /// BFR体脂率数据
    @Published var bfrData: BFRData?
    
    /// BFR加载状态
    @Published var bfrLoading: Bool = false
    
    /// BFR输入参数
    @Published var bfrAge: Int = 25
    @Published var bfrHeight: Int = 170
    @Published var bfrWeight: Int = 65
    @Published var bfrSex: BFRSex = .male
    
    /// 中药搜索关键词
    @Published var zhongyaoKeyword: String = ""
    
    /// 中药搜索结果
    @Published var zhongyaoList: [ZhongyaoData] = []
    
    /// 中药加载状态
    @Published var zhongyaoLoading: Bool = false
    
    /// 当前城市
    @Published var currentCity: String = "北京"
    
    /// 错误消息
    @Published var errorMessage: String?
    
    // MARK: - 私有属性
    
    private let lifeService = LifeService.shared
    
    // MARK: - 公开方法
    
    /// 加载所有生活数据
    func loadAllData() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadWeather() }
            group.addTask { await self.loadOilPrice() }
        }
    }
    
    /// 加载天气预报
    func loadWeather() async {
        weatherLoading = true
        do {
            weather = try await lifeService.fetchWeather(city: currentCity)
        } catch {
            print("天气预报加载失败: \(error.localizedDescription)")
        }
        weatherLoading = false
    }
    
    /// 搜索旅游景区
    func searchScenic(refresh: Bool = true) async {
        guard !scenicKeyword.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        if refresh {
            scenicPage = 1
            hasMoreScenic = true
        }
        
        guard !scenicLoading else { return }
        
        scenicLoading = true
        do {
            let results = try await lifeService.fetchScenic(
                keyword: scenicKeyword,
                num: 10,
                page: scenicPage,
                forceRefresh: refresh
            )
            
            if refresh {
                scenicList = results
            } else {
                scenicList.append(contentsOf: results)
            }
            
            hasMoreScenic = results.count >= 10
        } catch {
            print("景区搜索失败: \(error.localizedDescription)")
            if refresh {
                scenicList = []
            }
        }
        scenicLoading = false
    }
    
    /// 加载更多景区
    func loadMoreScenic() async {
        guard hasMoreScenic && !scenicLoading else { return }
        scenicPage += 1
        await searchScenic(refresh: false)
    }
    
    /// 加载实时油价
    func loadOilPrice() async {
        oilPriceLoading = true
        do {
            oilPrice = try await lifeService.fetchOilPrice(province: currentCity)
        } catch {
            print("油价加载失败: \(error.localizedDescription)")
        }
        oilPriceLoading = false
    }
    
    /// 刷新油价
    func refreshOilPrice() async {
        oilPriceLoading = true
        do {
            oilPrice = try await lifeService.fetchOilPrice(province: currentCity, forceRefresh: true)
        } catch {
            print("油价刷新失败: \(error.localizedDescription)")
        }
        oilPriceLoading = false
    }
    
    /// 计算BFR体脂率
    func calculateBFR() async {
        bfrLoading = true
        errorMessage = nil
        do {
            bfrData = try await lifeService.fetchBFR(
                age: bfrAge,
                height: bfrHeight,
                weight: bfrWeight,
                sex: bfrSex
            )
        } catch {
            errorMessage = error.localizedDescription
            print("BFR计算失败: \(error.localizedDescription)")
        }
        bfrLoading = false
    }
    
    /// 搜索中药
    func searchZhongyao() async {
        guard !zhongyaoKeyword.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        zhongyaoLoading = true
        do {
            zhongyaoList = try await lifeService.fetchZhongyao(word: zhongyaoKeyword)
        } catch {
            print("中药搜索失败: \(error.localizedDescription)")
            zhongyaoList = []
        }
        zhongyaoLoading = false
    }
    
    /// 切换城市（同时刷新天气、油价）
    func switchCity(_ city: String) async {
        currentCity = city
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadWeather() }
            group.addTask { await self.loadOilPrice() }
        }
    }
}
