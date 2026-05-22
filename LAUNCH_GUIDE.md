# 🚀 上线操作指南

## 0. 前提条件（你在 App Store Connect 操作）

浏览器打开 [appstoreconnect.apple.com](https://appstoreconnect.apple.com) → 登录你的开发者账号

## 1. 创建 App

1. App Store Connect → App → 点 "+" → "新 App"
2. 平台：**iOS**
3. 名称：**庄子的每日签**（英文可填 Zhuangzi's Daily）
4. 语言：**简体中文**
5. Bundle ID：新建或选 `com.zhuangzidaily.ZhuangziDaily`
6. SKU：随便填，比如 `ZHUANGZI_DAILY_001`
7. 用户访问权限：**没有具体限制**

## 2. 创建订阅商品

1. App Store Connect → 功能 → 订阅 → "+"
2. 参考名称：**庄子的每日签 - 月度会员**
3. 产品 ID：**com.zhuangzidaily.monthly**
4. 订阅时长：1个月
5. 定价：**$2.99 USD**
6. 本地化（简体中文）：名称 = "月度会员"，说明 = "无限换签 + 查看全部历史记录"

**保存后要等几分钟生效，然后才能在 Xcode 里测试订阅**

## 3. Xcode 操作——提交构建

### 3.1 真机准备
1. 把 iPhone 连到 Mac
2. Xcode → 选择你的 iPhone（从模拟器切换成真机）
3. 点击 ▶ 运行——跑一次确保真机启动正常

### 3.2 Archive 打包
1. Xcode → Product → Archive
2. 等打包完成，弹出 Organizer 窗口
3. 点 **Distribute App** → **App Store Connect**

### 3.3 上传
1. 选 Upload → 下一步
2. 确认签名信息
3. 等上传完成

## 4. App Store Connect 填信息

回到 App Store Connect → 你的 App → 准备提交：

### 必填信息
| 字段 | 内容 |
|------|------|
| 副标题 | 每天一张签，给你一点庄子式的清醒 |
| 描述 | 见 `STORE_LISTING.md` |
| 关键词 | 庄子,每日签,运势,哲学,道家,庄子语录 |
| 支持网址 | 你的网站，或者留空 |
| 隐私政策 | 见 `PRIVACY.md` — 粘贴内容到文本框 |

### 截图
需要的截图尺寸（至少选一组）：
- **6.7" iPhone**: 1290 × 2796 px（建议主图）
- **6.5" iPhone**: 1242 × 2688 px
- **5.5" iPhone**: 1242 × 2208 px

**怎么截：**
1. Xcode 选对应尺寸的模拟器（如 iPhone 15 Pro Max）
2. 跑 App → Cmd+S 截图
3. 拖到 App Store Connect 上传
4. 建议：今日签、签库、设置页 各一张

### 提交审核
所有信息填完 → 点右上角 **"提交以供审核"**

## 5. 审核通过后
- 可以自己设定"价格与销售范围"决定上架时间
- 设置 Release 为"手动发布"更可控

---

**有问题随时找我！在哪个步骤卡住了就喊一声。**
