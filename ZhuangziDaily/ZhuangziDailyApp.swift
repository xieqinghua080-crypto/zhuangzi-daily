import SwiftUI

// MARK: - 主 App 入口
@main
struct ZhuangziDailyApp: App {

    @StateObject private var storeKit = StoreKitService.shared
    @StateObject private var signService = SignService.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(storeKit)
                .environmentObject(signService)
                .onAppear {
                    // 加载商品信息
                    Task {
                        await storeKit.loadProducts()
                        await NotificationService.shared.requestPermission()
                    }
                }
        }
    }
}
