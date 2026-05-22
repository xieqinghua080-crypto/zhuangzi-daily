import Foundation

// MARK: - 签服务（核心逻辑）
class SignService: ObservableObject {

    static let shared = SignService()

    @Published var todaySign: Sign?
    @Published var historyRecords: [SignRecord] = []
    @Published var allSigns: [Sign] = []
    @Published var dailyDrawCount = 0
    @Published var lastDrawDate = ""

    private let maxFreeDraws = 3
    private let maxFreeHistory = 7

    private let dailySignKey = "daily_sign"
    private let historyKey = "sign_history"
    private let drawCountKey = "daily_draw_count"
    private let drawDateKey = "draw_date"

    private init() {
        loadAllSigns()
        loadHistory()
        loadTodaySign()
        loadDrawCount()
    }

    // MARK: - 加载 81 签数据

    private func loadAllSigns() {
        guard let url = Bundle.main.url(forResource: "signs", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let signs = try? JSONDecoder().decode([Sign].self, from: data) else {
            print("❌ 加载 signs.json 失败")
            return
        }
        allSigns = signs
        print("✅ 加载了 \(signs.count) 条签")
    }

    // MARK: - 每日抽签

    /// 获取今日签（日期种子确保一天一签）
    func getTodaySign() -> Sign {
        if let sign = todaySign { return sign }

        let dateStr = todayDateString()
        let seed = dateStr.hashValue
        let index = abs(seed) % allSigns.count
        let sign = allSigns[index]

        saveDailySign(signId: sign.id)

        DispatchQueue.main.async {
            self.todaySign = sign
        }

        return sign
    }

    /// 换一签（重新抽）— 注意：需要在主线程调用检查订阅状态
    func drawNewSign() -> Sign? {
        let dateStr = todayDateString()
        resetDrawCountIfNeeded()

        // 检查免费次数（订阅状态在主线程检查）
        if dailyDrawCount >= maxFreeDraws {
            return nil
        }

        let sign = allSigns.randomElement()!
        dailyDrawCount += 1
        lastDrawDate = dateStr
        saveDrawCount()

        let record = SignRecord(
            id: "\(dateStr)-\(sign.id)-\(dailyDrawCount)",
            signId: sign.id,
            date: Date(),
            isLuckyDraw: true
        )
        addRecord(record)

        DispatchQueue.main.async {
            self.todaySign = sign
            self.saveDailySign(signId: sign.id)
        }

        return sign
    }

    /// 检查是否能再换签（需要在主线程调用）
    func canDrawNewSign() -> Bool {
        let dateStr = todayDateString()
        if lastDrawDate != dateStr { return true }
        return dailyDrawCount < maxFreeDraws
    }

    // MARK: - 历史记录

    func maxHistoryDays() -> Int {
        return 7  // V1 免费用户统一 7 天
    }

    func recentHistory() -> [SignRecord] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -maxHistoryDays(), to: Date()) ?? Date()
        return historyRecords
            .filter { $0.date > cutoff }
            .sorted { $0.date > $1.date }
    }

    func recordsByCategory() -> [(SignCategory, [SignRecord])] {
        let recent = recentHistory()
        var grouped: [SignCategory: [SignRecord]] = [:]

        for record in recent {
            guard let s = sign(for: record) else { continue }
            grouped[s.category, default: []].append(record)
        }

        return SignCategory.allCases.compactMap { category in
            guard let records = grouped[category], !records.isEmpty else { return nil }
            return (category, records)
        }
    }

    func signsByCategory(_ category: SignCategory) -> [Sign] {
        return allSigns.filter { $0.category == category }
    }

    func getSign(by id: String) -> Sign? {
        return allSigns.first { $0.id == id }
    }

    /// 通过签到记录查找对应的 Sign
    func sign(for record: SignRecord) -> Sign? {
        return allSigns.first { $0.id == record.signId }
    }

    // MARK: - 私有方法

    private func todayDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    private func saveDailySign(signId: String) {
        let dateStr = todayDateString()
        let daily = DailySign(date: dateStr, signId: signId, isLuckyDraw: false)
        if let data = try? JSONEncoder().encode(daily) {
            UserDefaults.standard.set(data, forKey: dailySignKey)
        }
    }

    private func loadTodaySign() {
        guard let data = UserDefaults.standard.data(forKey: dailySignKey),
              let daily = try? JSONDecoder().decode(DailySign.self, from: data),
              daily.date == todayDateString(),
              let sign = getSign(by: daily.signId) else { return }
        todaySign = sign
    }

    private func resetDrawCountIfNeeded() {
        let dateStr = todayDateString()
        if lastDrawDate != dateStr {
            dailyDrawCount = 0
            lastDrawDate = dateStr
            saveDrawCount()
        }
    }

    private func saveDrawCount() {
        UserDefaults.standard.set(dailyDrawCount, forKey: drawCountKey)
        UserDefaults.standard.set(lastDrawDate, forKey: drawDateKey)
    }

    private func loadDrawCount() {
        dailyDrawCount = UserDefaults.standard.integer(forKey: drawCountKey)
        lastDrawDate = UserDefaults.standard.string(forKey: drawDateKey) ?? ""
    }

    private func addRecord(_ record: SignRecord) {
        historyRecords.insert(record, at: 0)
        saveHistory()
    }

    private func loadHistory() {
        guard let data = UserDefaults.standard.data(forKey: historyKey),
              let records = try? JSONDecoder().decode([SignRecord].self, from: data) else { return }
        historyRecords = records
    }

    private func saveHistory() {
        let toSave = Array(historyRecords.prefix(100))
        if let data = try? JSONEncoder().encode(toSave) {
            UserDefaults.standard.set(data, forKey: historyKey)
        }
    }
}
