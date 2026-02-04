# SwiftUI News App

## 简介 (Introduction)

SwiftUI News 是一个基于 SwiftUI 开发的综合性 iOS 新闻与生活助手应用。它不仅提供多类别的新闻资讯，还集成了丰富的生活实用工具、知识科普以及趣味娱乐功能。项目采用 MVVM 架构，展示了 SwiftUI 在构建现代化 iOS 应用中的最佳实践。

## 功能特性 (Features)

应用包含四大核心模块：

### 1. 新闻资讯 (News)
- **多频道支持**：涵盖国内、国际、社会、互联网、娱乐、IT、AI、游戏、动漫、影视、军事、科学等 10+ 个新闻频道。
- **实时更新**：接入天行数据 API，提供最新的新闻资讯。
- **详情浏览**：支持新闻详情页展示（Safari View 集成）。

### 2. 生活助手 (Life)
- **天气预报**：实时查看天气情况。
- **油价查询**：实时监控油价变动。
- **健康工具**：体脂率 (BFR) 计算器。
- **中药百科**：提供中药材相关知识查询。
- **城市选择**：支持多城市切换。

### 3. 知识科普 (Knowledge)
- 提供各类知识科普文章和资讯，帮助用户碎片化学习。

### 4. 趣味娱乐 (Fun)
- **星座运势**：每日星座运势查询。
- **周公解梦**：梦境解析工具。
- **故事大全**：各类精彩故事阅读。

## 技术栈 (Tech Stack)

- **语言**：Swift 5
- **UI 框架**：SwiftUI
- **架构模式**：MVVM (Model-View-ViewModel)
- **网络层**：URLSession + Async/Await
- **数据源**：[天行数据 (TianAPI)](https://www.tianapi.com/)

## 项目结构 (Project Structure)

```
SwiftUI-news/
├── Models/          # 数据模型 (NewsModel, LifeModel, etc.)
├── Views/           # SwiftUI 视图层
│   ├── News/        # 新闻相关视图
│   ├── Life/        # 生活工具视图
│   ├── Knowledge/   # 知识页面视图
│   └── Fun/         # 娱乐功能视图
├── ViewModels/      # 业务逻辑与状态管理
├── Services/        # 数据服务层 (API 调用)
├── Network/         # 网络配置与请求封装 (APIConfig.swift)
└── Utils/           # 工具类 (图片加载, 布局等)
```

## 快速开始 (Getting Started)

### 环境要求
- Xcode 14.0+
- iOS 16.0+ (推荐)

### 安装步骤

1. **克隆项目**
   ```bash
   git clone <repository-url>
   cd SwiftUI-news
   ```

2. **打开项目**
   双击 `SwiftUI-news/SwiftUI-news.xcodeproj` 使用 Xcode 打开。

3. **配置 API 密钥**
   项目依赖天行数据 API。请前往 [天行数据官网](https://www.tianapi.com/) 注册并申请 API Key。
   
   打开 `SwiftUI-news/Network/APIConfig.swift`，找到以下代码并替换为您自己的 Key：
   ```swift
   static let apiKey = "YOUR_API_KEY_HERE"
   ```
   *注意：项目默认包含一个演示 Key，可能会有调用次数限制。*

4. **运行应用**
   选择模拟器或真机，点击 Xcode 顶部的 Run (▶) 按钮即可运行。

## 贡献 (Contributing)

欢迎提交 Issue 或 Pull Request 来改进本项目！

## 许可证 (License)

本项目采用 MIT 许可证。详情请参阅 LICENSE 文件。
