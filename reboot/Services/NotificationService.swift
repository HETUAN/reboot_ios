import Foundation
import UserNotifications

enum NotificationService {
    static func requestAuthorization() async -> Bool {
        do {
            let center = UNUserNotificationCenter.current()
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            return false
        }
    }

    static func notificationSettings() async -> UNNotificationSettings {
        await UNUserNotificationCenter.current().notificationSettings()
    }

    static func scheduleReminders() async throws {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        let reminders: [(String, String, Int, Int)] = [
            ("早晨仪式", "5分钟灵魂拷问，开启觉察的一天", 6, 0),
            ("白天检查 1", "你在逃避什么困难的事？", 11, 0),
            ("白天检查 2", "纪录片拍你现在的行为，会自豪吗？", 14, 0),
            ("白天检查 3", "你在做推动核心目标的事吗？", 17, 0),
            ("晚间复盘", "今日通关了吗？总结开启明天", 21, 0),
        ]

        for (title, body, hour, minute) in reminders {
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default

            var components = DateComponents()
            components.hour = hour
            components.minute = minute

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(identifier: "reboot-\(hour)-\(minute)", content: content, trigger: trigger)
            try await center.add(request)
        }
    }

    static func cancelReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
