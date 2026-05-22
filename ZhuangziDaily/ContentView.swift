import SwiftUI

// MARK: - 根视图（Tab 导航）
struct ContentView: View {

    @EnvironmentObject var signService: SignService
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // 今日签
            TodaySignView()
                .tabItem {
                    Image(systemName: "leaf")
                    Text("今日签")
                }
                .tag(0)

            // 历史记录
            HistoryView()
                .tabItem {
                    Image(systemName: "book")
                    Text("签库")
                }
                .tag(1)

            // 设置/订阅
            SettingsView()
                .tabItem {
                    Image(systemName: "person")
                    Text("设置")
                }
                .tag(2)
        }
        .tint(.primary)
    }
}
