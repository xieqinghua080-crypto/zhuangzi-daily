import SwiftUI

// MARK: - 今日签主视图
struct TodaySignView: View {

    @EnvironmentObject var signService: SignService
    @State private var showAnimation = false
    @State private var showLimitAlert = false
    @State private var showShareSheet = false
    @State private var capturedImage: UIImage?
    @State private var counterRotation = 0.0

    private let cardRef = "todayCard"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    // 标题
                    VStack(spacing: 4) {
                        Text("🌀 庄子的每日签")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text(formatDate(Date()))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)

                    // 签卡
                    if let sign = signService.todaySign ?? signService.getTodaySign() as Sign? {
                        CardFrontView(sign: sign)
                            .rotation3DEffect(
                                .degrees(showAnimation ? 0 : -90),
                                axis: (x: 0, y: 1, z: 0)
                            )
                            .animation(.spring(response: 0.6, dampingFraction: 0.7), value: showAnimation)
                            .onAppear {
                                withAnimation {
                                    showAnimation = true
                                }
                            }

                        // 操作按钮
                        HStack(spacing: 40) {
                            // 换签按钮
                            Button {
                                if StoreKitService.shared.isSubscribed || signService.canDrawNewSign() {
                                    if let result = signService.drawNewSign() {
                                        // 换签成功，重新触发动画
                                        showAnimation = false
                                        counterRotation += 1
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            withAnimation {
                                                showAnimation = true
                                            }
                                        }
                                    }
                                } else {
                                    showLimitAlert = true
                                }
                            } label: {
                                VStack(spacing: 4) {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                        .font(.title2)
                                    Text("换一签")
                                        .font(.caption)
                                }
                                .foregroundColor(.primary)
                            }

                            // 分享按钮
                            Button {
                                if let image = ImageGenerator.generateCardImage(sign: sign) {
                                    capturedImage = image
                                    showShareSheet = true
                                }
                            } label: {
                                VStack(spacing: 4) {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.title2)
                                    Text("分享")
                                        .font(.caption)
                                }
                                .foregroundColor(.primary)
                            }
                        }
                        .padding(.top, 8)

                        // 剩余抽签次数
                        if !StoreKitService.shared.isSubscribed {
                            let remaining = max(0, 3 - signService.dailyDrawCount)
                            Text("今日可换签 \(remaining)/3 次")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }

                        // 故事卡
                        storyCard(sign: sign)
                            .padding(.top, 8)
                    }
                }
                .padding()
            }
            .alert("每日限额", isPresented: $showLimitAlert) {
                Button("取消", role: .cancel) {}
                Button("订阅无限次") {
                    Task {
                        _ = await StoreKitService.shared.purchase()
                    }
                }
            } message: {
                Text("免费用户每天只能换签 3 次。订阅后可无限换签，查看全部历史记录。")
            }
            .sheet(isPresented: $showShareSheet) {
                if let image = capturedImage {
                    ShareSheet(image: image)
                }
            }
        }
    }

    // MARK: - 故事卡
    private func storyCard(sign: Sign) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("📖 庄子故事")
                    .font(.headline)
                Spacer()
                Text(sign.category.icon + " " + sign.category.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Text(sign.story)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineSpacing(4)

            Divider()

            Text(sign.message)
                .font(.subheadline)
                .italic()
                .foregroundColor(.primary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }

    // MARK: - 日期格式化
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年M月d日 EEEE"
        return formatter.string(from: date)
    }
}

// MARK: - ShareSheet（UIKit 桥接）
struct ShareSheet: UIViewControllerRepresentable {
    let image: UIImage

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [image], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
