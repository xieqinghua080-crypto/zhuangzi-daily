import SwiftUI
import UserNotifications

// MARK: - 设置视图
struct SettingsView: View {

    @EnvironmentObject var storeKit: StoreKitService
    @State private var notificationEnabled = false

    var body: some View {
        NavigationStack {
            List {

                // MARK: 订阅
                Section("订阅") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: storeKit.isSubscribed ? "checkmark.seal.fill" : "seal")
                                .foregroundColor(storeKit.isSubscribed ? .blue : .secondary)
                                .font(.title2)

                            VStack(alignment: .leading) {
                                Text(storeKit.isSubscribed ? "已订阅" : "庄子的每日签 会员")
                                    .font(.headline)
                                Text(storeKit.isSubscribed ? "感谢支持！继续享受无限换签和完整历史。" : "$2.99/月 · 无限换签 · 全部历史")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    if !storeKit.isSubscribed {
                        Button {
                            Task {
                                let success = await storeKit.purchase()
                                if success {
                                    // 订阅成功
                                }
                            }
                        } label: {
                            HStack {
                                if storeKit.isLoading {
                                    ProgressView()
                                }
                                Text("订阅 $2.99/月")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .disabled(storeKit.isLoading)

                        Button("恢复购买") {
                            Task {
                                _ = await storeKit.restorePurchases()
                            }
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                }

                // MARK: 推送设置
                Section("推送") {
                    Toggle(isOn: $notificationEnabled) {
                        VStack(alignment: .leading) {
                            Text("每日推送")
                                .font(.subheadline)
                            Text("每天早上 7:00 推送今日签")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .onChange(of: notificationEnabled) { newValue in
                        Task {
                            if newValue {
                                let granted = await NotificationService.shared.requestPermission()
                                if granted {
                                    if let sign = SignService.shared.todaySign {
                                        let text = String(sign.quote.prefix(20))
                                        NotificationService.shared.scheduleDailyNotification(
                                            signText: text + "…",
                                            categoryName: sign.category.rawValue
                                        )
                                    }
                                } else {
                                    await MainActor.run {
                                        notificationEnabled = false
                                    }
                                }
                            } else {
                                NotificationService.shared.cancelNotification()
                            }
                        }
                    }
                    .onAppear {
                        Task {
                            let has = await NotificationService.shared.hasScheduledNotification()
                            await MainActor.run {
                                notificationEnabled = has
                            }
                        }
                    }
                }

                // MARK: 关于
                Section("关于") {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("作者")
                        Spacer()
                        Text("庄子的每日签团队")
                            .foregroundColor(.secondary)
                    }

                    NavigationLink(destination: AboutView()) {
                        Text("关于庄子与每日签")
                    }
                }
            }
            .navigationTitle("设置")
        }
    }
}

// MARK: - 关于页面
struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("🌀")
                    .font(.system(size: 60))
                    .padding(.top, 30)

                Text("庄子的每日签")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("每天一张签，给你一点庄子式的清醒")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Divider()
                    .padding(.horizontal, 40)

                VStack(alignment: .leading, spacing: 12) {
                    Text("关于庄子")
                        .font(.headline)

                    Text("庄子（约公元前369-286年），名周，战国时期宋国蒙人。道家学派代表人物，与老子并称「老庄」。")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineSpacing(6)

                    Text("庄子的思想以逍遥、齐物、养生、处世为核心，主张顺应自然、超越功利、追求精神的绝对自由。他的文章汪洋恣肆，寓言丰富，是中国哲学与文学的瑰宝。")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineSpacing(6)
                }
                .padding(.horizontal, 20)

                VStack(alignment: .leading, spacing: 12) {
                    Text("关于本 App")
                        .font(.headline)

                    Text("本 App 精选《庄子》中的 81 条金句，分为逍遥游、齐物论、养生主、人间世、大宗师、应帝王六大类。每条签配有白话翻译、今日宜忌、迷你故事和人生寄语。")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineSpacing(6)

                    Text("愿每天一张签，给你的生活带来一点庄子的智慧与超脱。")
                        .font(.subheadline)
                        .italic()
                        .foregroundColor(.primary)
                        .lineSpacing(6)
                        .padding(.top, 4)
                }
                .padding(.horizontal, 20)

                Spacer()
            }
        }
        .navigationTitle("关于")
        .navigationBarTitleDisplayMode(.inline)
    }
}
