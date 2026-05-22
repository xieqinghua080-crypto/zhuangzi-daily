import Foundation

// MARK: - 庄子签数据模型
struct Sign: Identifiable, Codable, Equatable {
    let id: String
    let category: SignCategory
    let colorTheme: String
    let quote: String
    let translation: String
    let lesson: String
    let advice: Advice
    let story: String
    let message: String
}

struct Advice: Codable, Equatable {
    let yi: [String]
    let ji: [String]
}

enum SignCategory: String, Codable, CaseIterable {
    case xiaoyao = "逍遥游"
    case qiwu = "齐物论"
    case yangsheng = "养生主"
    case renjian = "人间世"
    case dazong = "大宗师"
    case yingdi = "应帝王"

    var icon: String {
        switch self {
        case .xiaoyao: return "🦅"
        case .qiwu: return "🦋"
        case .yangsheng: return "🌿"
        case .renjian: return "👥"
        case .dazong: return "🌌"
        case .yingdi: return "🏛️"
        }
    }

    var description: String {
        switch self {
        case .xiaoyao: return "自由·超越·大与小"
        case .qiwu: return "平等·相对·是非"
        case .yangsheng: return "养生·顺势·护身"
        case .renjian: return "处世·社交·自保"
        case .dazong: return "生死·自然·天道"
        case .yingdi: return "无为·管理·不争"
        }
    }
}

// MARK: - 签到记录
// 注意：Sign 本身不存储，通过 signId 查找
// 但 Codable 不能存储 SignalActor-isolated 引用，所以查询放在 Service 层
struct SignRecord: Codable, Identifiable {
    let id: String      // "\(date)-\(signId)"
    let signId: String
    let date: Date
    let isLuckyDraw: Bool  // 是否是主动换签
}

// 查找 Sign 的扩展方法（在 SignService 中托管）

// MARK: - 每日数据
struct DailySign: Codable {
    let date: String       // "2026-05-16"
    let signId: String
    let isLuckyDraw: Bool
}
