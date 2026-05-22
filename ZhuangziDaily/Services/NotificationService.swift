import Foundation
import UserNotifications

// MARK: - 本地推送服务
class NotificationService {

    static let shared = NotificationService()
    private init() {}

    /// 请求推送权限
    func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            print("❌ 推送权限请求失败: \(error.localizedDescription)")
            return false
        }
    }

    /// 检查推送权限状态
    func checkPermission() async -> UNAuthorizationStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus
    }

    /// 安排每日早上7点的推送
    func scheduleDailyNotification(signText: String, categoryName: String) {
        let center = UNUserNotificationCenter.current()

        // 先取消已有推送
        center.removePendingNotificationRequests(withIdentifiers: ["dailySign"])

        let content = UNMutableNotificationContent()
        content.title = "🌀 庄子的每日签"
        content.body = "【\(categoryName)】\(signText)"
        content.sound = .default
        content.badge = 1

        // 每天早上 7:00
        var dateComponents = DateComponents()
        dateComponents.hour = 7
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "dailySign", content: content, trigger: trigger)

        center.add(request) { error in
            if let error = error {
                print("❌ 推送创建失败: \(error.localizedDescription)")
            } else {
                print("✅ 每日推送已设置 (7:00)")
            }
        }
    }

    /// 取消推送
    func cancelNotification() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: ["dailySign"])
    }

    /// 检查是否已有推送
    func hasScheduledNotification() async -> Bool {
        let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        return requests.contains { $0.identifier == "dailySign" }
    }
}
