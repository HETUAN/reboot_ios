import Foundation

enum AppRoute: Hashable {
    case guide
    case morning
    case daytime
    case evening
    case history
}

enum AvoidanceType: String, CaseIterable, Codable, Identifiable {
    case focus
    case fear
    case comfort
    case social
    case energy

    var id: String { rawValue }

    var label: String {
        switch self {
        case .focus: return "分心拖延"
        case .fear: return "害怕失败"
        case .comfort: return "沉迷舒适"
        case .social: return "社交逃避"
        case .energy: return "身体疲惫"
        }
    }
}

enum ProudLevel: String, CaseIterable, Codable, Identifiable {
    case low
    case mid
    case high

    var id: String { rawValue }

    var label: String {
        switch self {
        case .low: return "不太自豪"
        case .mid: return "一般"
        case .high: return "会自豪"
        }
    }
}

enum DaytimeCheckKind: Int, CaseIterable, Codable, Identifiable {
    case check1 = 1
    case check2 = 2
    case check3 = 3

    var id: Int { rawValue }

    var timeLabel: String {
        switch self {
        case .check1: return "11:00"
        case .check2: return "14:00"
        case .check3: return "17:00"
        }
    }

    var title: String {
        switch self {
        case .check1: return "11:00 检查"
        case .check2: return "14:00 检查"
        case .check3: return "17:00 检查"
        }
    }

    var question: String {
        switch self {
        case .check1: return "我在逃避什么困难的事？"
        case .check2: return "纪录片拍我现在的行为，会自豪吗？"
        case .check3: return "我在做推动核心目标的事吗？"
        }
    }

    var icon: String {
        switch self {
        case .check1: return "exclamationmark.bubble.fill"
        case .check2: return "video.fill"
        case .check3: return "scope"
        }
    }
}

struct MorningRecord: Codable, Equatable {
    var completed = false
    var reverseVision = ""
    var miniVision = ""
    var identity = ""
}

struct DaytimeReflection: Codable, Equatable {
    var avoidanceType: AvoidanceType?
    var proudLevel: ProudLevel?
    var note = ""
    var completedAt: Date?
}

struct DaytimeRecord: Codable, Equatable {
    var check1 = false
    var check2 = false
    var check3 = false
    var reflections: [DaytimeCheckKind: DaytimeReflection] = [
        .check1: DaytimeReflection(),
        .check2: DaytimeReflection(),
        .check3: DaytimeReflection(),
    ]
}

struct EveningRecord: Codable, Equatable {
    var completed = false
    var energy = 5
    var tomorrowGoal = ""
}

struct DailyRecord: Codable, Equatable {
    var morning = MorningRecord()
    var daytime = DaytimeRecord()
    var evening = EveningRecord()
    var isPassed = false
}

struct PersistedState: Codable {
    var userName: String = "重启者"
    var notificationsEnabled = true
    var dailyData: [String: DailyRecord] = [:]
}

struct HistorySummary {
    let totalDays: Int
    let passDays: Int
    let averageEnergy: Double
    let streak: Int
}
