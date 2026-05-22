# 🌀 庄子的每日签 (Zhuangzi's Daily)

极简哲学运势 App — 每天一张签，给你一点庄子式的清醒。

## 项目结构

```
zhuangzi-daily/
├── ZhuangziDaily/
│   ├── ZhuangziDailyApp.swift      # App 入口
│   ├── ContentView.swift           # 根视图（Tab 导航）
│   ├── Models/
│   │   └── Sign.swift              # 数据模型
│   ├── Data/
│   │   └── signs.json              # 81 条签数据
│   ├── Views/
│   │   ├── TodaySignView.swift     # 今日签主界面
│   │   ├── CardFrontView.swift     # 卡片正面
│   │   ├── HistoryView.swift       # 签库/历史记录
│   │   └── SettingsView.swift      # 设置/订阅
│   ├── Services/
│   │   ├── SignService.swift       # 抽签逻辑
│   │   ├── NotificationService.swift # 本地推送
│   │   └── StoreKitService.swift   # 订阅服务
│   └── Extensions/
│       └── ImageGenerator.swift    # 卡片转图片
└── PRD.md
```

## 快速搭建 Xcode 项目

### 方法一：Xcode 新建项目（推荐）

1. 打开 Xcode → File → New → Project
2. 选 iOS → App → Next
3. Product Name: `ZhuangziDaily`
4. Interface: SwiftUI, Language: Swift, Minimum iOS: 16.0
5. 选好保存路径，取消勾选 "Create Git repository on my Mac"（已有）
6. 项目创建好后：
   - 删除自动生成的 `ZhuangziDailyApp.swift` 和 `ContentView.swift`
   - 把本仓库 `ZhuangziDaily/` 文件夹**拖入** Xcode 项目导航栏
   - 确认勾选 "Copy items if needed"
   - 确保 Add to targets 勾选了 ZhuangziDaily
7. 选择 iPhone 15 Pro 模拟器运行

### 方法二：安装 XcodeGen 自动生成

```bash
brew install xcodegen
cd zhuangzi-daily
xcodegen
open ZhuangziDaily.xcodeproj
```

## 功能清单

- ✅ 每日一签（日期种子保证每天同一签）
- ✅ 81 条庄子签，6 大分类
- ✅ 翻牌动画效果
- ✅ 换一签（免费 3 次/日，订阅无限）
- ✅ 分享卡片为图片
- ✅ 签到历史记录
- ✅ 按分类浏览签库
- ✅ 本地推送（早 7:00）
- ✅ StoreKit 订阅 $2.99/月
- ✅ 庄子故事卡
- ✅ 极简东方美学 UI

## 发布前准备

1. **注册 Apple Developer** — $99/年，[developer.apple.com](https://developer.apple.com)
2. **修改 Bundle ID** — Xcode → Target → General → Bundle Identifier
3. **设置 App Icon** — Assets.xcassets → AppIcon
4. **StoreKit 配置** — 在 App Store Connect 创建订阅产品 ID: `com.zhuangzidaily.monthly`
5. **提交审核** — Xcode → Product → Archive → Distribute App

## 推广建议

- 小红书每天发一张签卡截图
- 引导语：「今日签：______」
- 鼓励用户分享到朋友圈
