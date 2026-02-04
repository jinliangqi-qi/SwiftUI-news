//
//  WeatherCardView.swift
//  SwiftUI-news
//
//  Created by v_jinlqi on 2026/1/30.
//
//  天气预报卡片视图

import SwiftUI

// MARK: - 天气预报卡片
struct WeatherCardView: View {
    let weather: WeatherData?
    let loading: Bool
    let currentCity: String
    let onCityTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 标题栏
            HStack {
                Image(systemName: "cloud.sun.fill")
                    .foregroundStyle(.orange.gradient)
                Text("天气预报")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                // 城市选择按钮
                Button(action: onCityTap) {
                    HStack(spacing: 4) {
                        Text(currentCity)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Image(systemName: "chevron.down")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(16)
            
            Divider()
            
            if loading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .padding(.vertical, 40)
            } else if let weather = weather {
                // 主要天气信息
                HStack(alignment: .center, spacing: 20) {
                    // 天气图标和温度
                    VStack(spacing: 6) {
                        Image(systemName: weather.weatherIcon)
                            .font(.system(size: 44))
                            .foregroundStyle(weatherIconColor(weather.weather))
                        
                        Text(weather.real)
                            .font(.system(size: 32, weight: .bold))
                        
                        Text(weather.weather)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(width: 100)
                    
                    Divider()
                        .frame(height: 80)
                    
                    // 详细信息
                    VStack(alignment: .leading, spacing: 10) {
                        WeatherDetailRow(icon: "thermometer", label: "温度范围", value: "\(weather.lowest) ~ \(weather.highest)")
                        WeatherDetailRow(icon: "wind", label: "风力", value: "\(weather.wind) \(weather.windsc)")
                        WeatherDetailRow(icon: "humidity", label: "湿度", value: "\(weather.humidity)%")
                        if let sunrise = weather.sunrise, let sunset = weather.sunset {
                            WeatherDetailRow(icon: "sunrise", label: "日出/日落", value: "\(sunrise) / \(sunset)")
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(16)
                
                // 生活提示
                if !weather.tips.isEmpty {
                    Divider()
                    
                    Text(weather.tips)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                        .padding(16)
                }
                
                // 天气预警
                if let alarms = weather.alarmlist, !alarms.isEmpty {
                    ForEach(alarms) { alarm in
                        Divider()
                        
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(alarmColor(alarm.level))
                            Text("\(alarm.type)\(alarm.level)预警")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(alarmColor(alarm.level))
                            Spacer()
                        }
                        .padding(16)
                        .background(alarmColor(alarm.level).opacity(0.08))
                    }
                }
            } else {
                Text("暂无天气数据")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            }
        }
        .background(Color.platformBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    /// 天气图标颜色
    private func weatherIconColor(_ weather: String) -> some ShapeStyle {
        if weather.contains("晴") {
            return Color.orange.gradient
        } else if weather.contains("云") || weather.contains("阴") {
            return Color.gray.gradient
        } else if weather.contains("雨") {
            return Color.blue.gradient
        } else if weather.contains("雪") {
            return Color.cyan.gradient
        } else {
            return Color.gray.gradient
        }
    }
    
    /// 预警级别颜色
    private func alarmColor(_ level: String) -> Color {
        switch level {
        case "红色": return .red
        case "橙色": return .orange
        case "黄色": return .yellow
        case "蓝色": return .blue
        default: return .gray
        }
    }
}

// MARK: - 天气详情行
struct WeatherDetailRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 16)
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}
