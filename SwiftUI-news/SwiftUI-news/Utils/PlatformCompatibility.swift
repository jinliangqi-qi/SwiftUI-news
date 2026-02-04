//
//  PlatformCompatibility.swift
//  SwiftUI-news
//
//  跨平台兼容性扩展 - 统一 iOS/macOS/iPad 差异
//

import SwiftUI

// MARK: - 设备类型检测
enum DeviceType {
    case iPhone
    case iPad
    case mac
    
    static var current: DeviceType {
        #if os(macOS)
        return .mac
        #else
        if UIDevice.current.userInterfaceIdiom == .pad {
            return .iPad
        } else {
            return .iPhone
        }
        #endif
    }
    
    var isIPad: Bool { self == .iPad }
    var isIPhone: Bool { self == .iPhone }
    var isMac: Bool { self == .mac }
}

// MARK: - 跨平台颜色扩展
extension Color {
    /// 系统背景色（跨平台）
    static var platformBackground: Color {
        #if canImport(UIKit)
        return Color(.systemBackground)
        #else
        return Color(NSColor.windowBackgroundColor)
        #endif
    }
    
    /// 分组背景色（跨平台）
    static var platformGroupedBackground: Color {
        #if canImport(UIKit)
        return Color(.systemGroupedBackground)
        #else
        return Color(NSColor.controlBackgroundColor)
        #endif
    }
    
    /// 次级分组背景色（跨平台）
    static var platformSecondaryGroupedBackground: Color {
        #if canImport(UIKit)
        return Color(.secondarySystemGroupedBackground)
        #else
        return Color(NSColor.windowBackgroundColor)
        #endif
    }
    
    /// 灰色6（跨平台）
    static var platformGray6: Color {
        #if canImport(UIKit)
        return Color(.systemGray6)
        #else
        return Color(NSColor.controlBackgroundColor)
        #endif
    }
    
    /// 灰色5（跨平台）
    static var platformGray5: Color {
        #if canImport(UIKit)
        return Color(.systemGray5)
        #else
        return Color(NSColor.separatorColor)
        #endif
    }
    
    /// 第三级标签颜色（跨平台）
    static var tertiaryLabel: Color {
        #if canImport(UIKit)
        return Color(.tertiaryLabel)
        #else
        return Color(NSColor.tertiaryLabelColor)
        #endif
    }
    
    // MARK: - 深色模式适配颜色
    
    /// 卡片背景色（深色模式自适应）
    static var cardBackground: Color {
        #if canImport(UIKit)
        return Color(.secondarySystemGroupedBackground)
        #else
        return Color(NSColor.controlBackgroundColor)
        #endif
    }
    
    /// 分隔线颜色（深色模式自适应）
    static var platformSeparator: Color {
        #if canImport(UIKit)
        return Color(.separator)
        #else
        return Color(NSColor.separatorColor)
        #endif
    }
    
    /// 主要文本颜色（深色模式自适应）
    static var primaryText: Color {
        #if canImport(UIKit)
        return Color(.label)
        #else
        return Color(NSColor.labelColor)
        #endif
    }
    
    /// 次要文本颜色（深色模式自适应）
    static var secondaryText: Color {
        #if canImport(UIKit)
        return Color(.secondaryLabel)
        #else
        return Color(NSColor.secondaryLabelColor)
        #endif
    }
    
    /// 填充色（深色模式自适应）
    static var platformFill: Color {
        #if canImport(UIKit)
        return Color(.systemFill)
        #else
        return Color(NSColor.controlBackgroundColor)
        #endif
    }
    
    /// 次级填充色（深色模式自适应）
    static var platformSecondaryFill: Color {
        #if canImport(UIKit)
        return Color(.secondarySystemFill)
        #else
        return Color(NSColor.controlBackgroundColor.withAlphaComponent(0.5))
        #endif
    }
    
    /// 第三级填充色（深色模式自适应）
    static var platformTertiaryFill: Color {
        #if canImport(UIKit)
        return Color(.tertiarySystemFill)
        #else
        return Color(NSColor.controlBackgroundColor.withAlphaComponent(0.3))
        #endif
    }
    
    /// 灰色4（跨平台）
    static var platformGray4: Color {
        #if canImport(UIKit)
        return Color(.systemGray4)
        #else
        return Color(NSColor.systemGray)
        #endif
    }
    
    /// 灰色3（跨平台）
    static var platformGray3: Color {
        #if canImport(UIKit)
        return Color(.systemGray3)
        #else
        return Color(NSColor.systemGray)
        #endif
    }
    
    /// 灰色2（跨平台）
    static var platformGray2: Color {
        #if canImport(UIKit)
        return Color(.systemGray2)
        #else
        return Color(NSColor.systemGray)
        #endif
    }
}

// MARK: - 跨平台 View 扩展
extension View {
    /// 隐藏键盘（跨平台）
    func hideKeyboard() {
        #if canImport(UIKit)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        #endif
    }
    
    /// 导航栏标题显示模式（跨平台）
    @ViewBuilder
    func platformNavigationBarTitleDisplayMode(_ mode: PlatformTitleDisplayMode) -> some View {
        #if os(iOS)
        switch mode {
        case .inline:
            self.navigationBarTitleDisplayMode(.inline)
        case .large:
            self.navigationBarTitleDisplayMode(.large)
        }
        #else
        self
        #endif
    }
}

/// 平台标题显示模式
enum PlatformTitleDisplayMode {
    case inline
    case large
}

// MARK: - iPad/macOS 布局适配
extension View {
    /// macOS/iPad 最大宽度容器（在大屏幕上居中显示内容）
    @ViewBuilder
    func macOSContentWidth(maxWidth: CGFloat = 700) -> some View {
        #if os(macOS)
        self
            .frame(maxWidth: maxWidth)
            .frame(maxWidth: .infinity)
        #else
        self
        #endif
    }
    
    /// macOS 列表样式优化
    @ViewBuilder
    func macOSListStyle() -> some View {
        #if os(macOS)
        self.listStyle(.inset(alternatesRowBackgrounds: true))
        #else
        self
        #endif
    }
    
    /// iPad 内容最大宽度限制
    @ViewBuilder
    func iPadContentWidth(maxWidth: CGFloat = 800) -> some View {
        if DeviceType.current.isIPad {
            self
                .frame(maxWidth: maxWidth)
                .frame(maxWidth: .infinity)
        } else {
            self
        }
    }
    
    /// iPad 卡片内边距优化
    func iPadPadding(_ edges: Edge.Set = .all, _ length: CGFloat = 16) -> some View {
        let padding = DeviceType.current.isIPad ? length * 1.5 : length
        return self.padding(edges, padding)
    }
}

// MARK: - 自适应网格列数
struct AdaptiveGridColumns {
    /// 根据屏幕宽度和设备类型计算网格列数
    static func columns(for width: CGFloat, minItemWidth: CGFloat = 160) -> [GridItem] {
        let spacing: CGFloat = 12
        let availableWidth = width - 32 // 减去左右padding
        
        // 根据设备类型设置基础列数
        let baseColumns: Int
        switch DeviceType.current {
        case .mac:
            baseColumns = 3
        case .iPad:
            // iPad根据屏幕宽度动态调整
            if availableWidth > 1000 {
                baseColumns = 4
            } else if availableWidth > 700 {
                baseColumns = 3
            } else {
                baseColumns = 2
            }
        case .iPhone:
            baseColumns = 2
        }
        
        // 确保每列宽度不小于最小宽度
        let calculatedColumns = Int(availableWidth / (minItemWidth + spacing))
        let finalColumns = max(1, min(baseColumns, calculatedColumns))
        
        return Array(repeating: GridItem(.flexible(), spacing: spacing), count: finalColumns)
    }
    
    /// 新闻网格列数
    static func newsColumns(for width: CGFloat) -> [GridItem] {
        return columns(for: width, minItemWidth: 160)
    }
    
    /// 卡片网格列数（如生活页面的卡片）
    static func cardColumns(for width: CGFloat) -> [GridItem] {
        let spacing: CGFloat = 16
        
        switch DeviceType.current {
        case .mac:
            return [
                GridItem(.flexible(), spacing: spacing),
                GridItem(.flexible(), spacing: spacing)
            ]
        case .iPad:
            if width > 1000 {
                return [
                    GridItem(.flexible(), spacing: spacing),
                    GridItem(.flexible(), spacing: spacing),
                    GridItem(.flexible(), spacing: spacing)
                ]
            } else {
                return [
                    GridItem(.flexible(), spacing: spacing),
                    GridItem(.flexible(), spacing: spacing)
                ]
            }
        case .iPhone:
            return [GridItem(.flexible())]
        }
    }
}

// MARK: - iPad 适配的 Sheet 尺寸
extension View {
    /// iPad 优化的 Sheet 展示
    @ViewBuilder
    func iPadSheet<Content: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        self.sheet(isPresented: isPresented) {
            content()
                .iPadSheetSize()
        }
    }
    
    /// iPad Sheet 尺寸优化
    @ViewBuilder
    func iPadSheetSize() -> some View {
        #if os(iOS)
        if DeviceType.current.isIPad {
            self.presentationDetents([.large])
                .presentationDragIndicator(.visible)
        } else {
            self.presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        #else
        self.frame(minWidth: 500, idealWidth: 600, minHeight: 500, idealHeight: 700)
        #endif
    }
}

// MARK: - 响应式字体大小
extension Font {
    /// 响应式标题字体
    static var adaptiveTitle: Font {
        DeviceType.current.isIPad ? .largeTitle : .title
    }
    
    /// 响应式副标题字体
    static var adaptiveTitle2: Font {
        DeviceType.current.isIPad ? .title : .title2
    }
    
    /// 响应式标题3字体
    static var adaptiveTitle3: Font {
        DeviceType.current.isIPad ? .title2 : .title3
    }
    
    /// 响应式正文字体
    static var adaptiveBody: Font {
        DeviceType.current.isIPad ? .body : .subheadline
    }
}
