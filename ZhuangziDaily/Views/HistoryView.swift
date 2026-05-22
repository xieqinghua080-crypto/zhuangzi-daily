import SwiftUI

// MARK: - 历史记录视图
struct HistoryView: View {

    @EnvironmentObject var signService: SignService
    @EnvironmentObject var storeKit: StoreKitService

    @State private var selectedCategory: SignCategory? = nil
    @State private var showSubscribeAlert = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 分类筛选
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        categoryChip(nil, icon: "📚", name: "全部")

                        ForEach(SignCategory.allCases, id: \.self) { cat in
                            categoryChip(cat, icon: cat.icon, name: cat.rawValue)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }

                Divider()

                // 签列表
                if selectedCategory == nil {
                    // 按分类展示
                    categoryListView
                } else {
                    // 单分类展示
                    singleCategoryView
                }
            }
            .navigationTitle("签库")
            .alert("订阅解锁", isPresented: $showSubscribeAlert) {
                Button("取消", role: .cancel) {}
                Button("订阅 $2.99/月") {
                    Task {
                        _ = await storeKit.purchase()
                    }
                }
            } message: {
                Text("免费用户只能查看最近 7 天的签到。订阅后可查看全部历史记录并无限换签。")
            }
        }
    }

    // MARK: - 分类筛选 Chip
    private func categoryChip(_ category: SignCategory?, icon: String, name: String) -> some View {
        Button {
            selectedCategory = category
        } label: {
            HStack(spacing: 4) {
                Text(icon)
                    .font(.caption)
                Text(name)
                    .font(.caption)
                    .fontWeight(selectedCategory == category ? .bold : .regular)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(selectedCategory == category ? Color(.systemGray4) : Color(.systemGray6))
            )
        }
        .foregroundColor(.primary)
    }

    // MARK: - 分类列表视图
    private var categoryListView: some View {
        ScrollView {
            VStack(spacing: 16) {
                let records = signService.recentHistory()

                if records.isEmpty {
                    emptyState
                } else {
                    // 按分类分组
                    let grouped = Dictionary(grouping: records) { record -> SignCategory in
                        return signService.sign(for: record)?.category ?? .xiaoyao
                    }

                    ForEach(SignCategory.allCases, id: \.self) { category in
                        if let catRecords = grouped[category], !catRecords.isEmpty {
                            categorySection(category: category, records: catRecords)
                        }
                    }
                }
            }
            .padding()
        }
    }

    // MARK: - 单分类视图
    private var singleCategoryView: some View {
        ScrollView {
            VStack(spacing: 12) {
                if let category = selectedCategory {
                    let signs = signService.signsByCategory(category)

                    Text(category.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)

                    ForEach(signs, id: \.id) { sign in
                        NavigationLink(destination: SignDetailView(sign: sign)) {
                            SignRowView(sign: sign)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding()
        }
    }

    // MARK: - 分类区块
    private func categorySection(category: SignCategory, records: [SignRecord]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(category.icon)
                Text(category.rawValue)
                    .font(.headline)
                Spacer()
                Text("\(records.count) 次签到")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            ForEach(records.prefix(5)) { record in
                if let sign = signService.sign(for: record) {
                    HStack {
                        Text("「\(sign.quote.prefix(20))...」")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(formatRecordDate(record.date))
                            .font(.caption2)
                            .foregroundColor(.secondary.opacity(0.5))
                    }
                    .padding(.leading, 8)
                }
            }

            if records.count > 5 && !storeKit.isSubscribed {
                Button("查看全部 \(records.count) 条 → 订阅解锁") {
                    showSubscribeAlert = true
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .primary.opacity(0.05), radius: 4)
        )
    }

    // MARK: - 空状态
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer().frame(height: 60)
            Image(systemName: "book")
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.5))
            Text("还没有签到记录")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("每天打开 App 就会自动签到")
                .font(.caption)
                .foregroundColor(.secondary.opacity(0.5))
        }
    }

    private func formatRecordDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }
}

// MARK: - 签行视图
struct SignRowView: View {
    let sign: Sign

    var body: some View {
        HStack(spacing: 12) {
            Text(sign.category.icon)
                .font(.title3)

            VStack(alignment: .leading, spacing: 4) {
                Text("「\(sign.quote.prefix(16))...」")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                Text(sign.lesson.prefix(20) + "...")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary.opacity(0.5))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6))
        )
    }
}

// MARK: - 签到详情视图
struct SignDetailView: View {
    let sign: Sign

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                CardFrontView(sign: sign)
                    .padding(.horizontal)

                VStack(alignment: .leading, spacing: 12) {
                    Text("📖 庄子故事")
                        .font(.headline)
                    Text(sign.story)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineSpacing(6)

                    Divider()

                    Text("💭 今日寄语")
                        .font(.headline)
                    Text(sign.message)
                        .font(.subheadline)
                        .italic()
                        .foregroundColor(.primary)
                        .lineSpacing(4)
                }
                .padding()
            }
            .padding(.vertical)
        }
        .navigationTitle(sign.category.rawValue)
        .navigationBarTitleDisplayMode(.inline)
    }
}
