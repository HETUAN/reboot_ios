import Foundation
import Combine
import SwiftUI

@MainActor
final class RebootStore: ObservableObject {
    @Published var userName = "重启者"
    @Published var notificationsEnabled = true
    @Published var dailyData: [String: DailyRecord] = [:]

    private let storageKey = "reboot-ios-storage"

    init() {
        load()
    }

    func record(for date: Date) -> DailyRecord {
        dailyData[DateHelpers.key(for: date)] ?? DailyRecord()
    }

    func saveMorning(date: Date = .now, reverseVision: String, miniVision: String, identity: String) {
        let key = DateHelpers.key(for: date)
        var record = dailyData[key] ?? DailyRecord()
        record.morning = MorningRecord(completed: true, reverseVision: reverseVision, miniVision: miniVision, identity: identity)
        record.isPassed = isDayPassed(record)
        dailyData[key] = record
        persist()
    }

    func saveDaytimeCheck(date: Date = .now, kind: DaytimeCheckKind, avoidanceType: AvoidanceType?, proudLevel: ProudLevel?, note: String) {
        let key = DateHelpers.key(for: date)
        var record = dailyData[key] ?? DailyRecord()
        switch kind {
        case .check1:
            record.daytime.check1 = true
        case .check2:
            record.daytime.check2 = true
        case .check3:
            record.daytime.check3 = true
        }

        record.daytime.reflections[kind] = DaytimeReflection(
            avoidanceType: avoidanceType,
            proudLevel: proudLevel,
            note: note,
            completedAt: .now
        )
        record.isPassed = isDayPassed(record)
        dailyData[key] = record
        persist()
    }

    func saveEveningReview(date: Date = .now, energy: Int, tomorrowGoal: String) {
        let key = DateHelpers.key(for: date)
        var record = dailyData[key] ?? DailyRecord()
        record.evening = EveningRecord(completed: true, energy: energy, tomorrowGoal: tomorrowGoal)
        record.isPassed = isDayPassed(record)
        dailyData[key] = record
        persist()
    }

    func setNotificationsEnabled(_ enabled: Bool) {
        notificationsEnabled = enabled
        persist()
    }

    func todayProgress(for date: Date = .now) -> Double {
        let record = record(for: date)
        let progressUnits = [
            record.morning.completed,
            completedChecks(in: record.daytime) >= 1,
            completedChecks(in: record.daytime) >= 2,
            record.evening.completed,
        ].filter { $0 }.count
        return Double(progressUnits) / 4.0
    }

    func completedChecks(in daytime: DaytimeRecord) -> Int {
        [daytime.check1, daytime.check2, daytime.check3].filter { $0 }.count
    }

    func isDayPassed(_ record: DailyRecord) -> Bool {
        record.morning.completed && completedChecks(in: record.daytime) >= 2
    }

    func currentStreak(anchor: Date = .now) -> Int {
        var streak = 0
        let calendar = Calendar(identifier: .gregorian)

        for offset in 0..<365 {
            guard let date = calendar.date(byAdding: .day, value: -offset, to: anchor) else { break }
            let key = DateHelpers.key(for: date)
            if dailyData[key]?.isPassed == true {
                streak += 1
                continue
            }

            if offset == 0 && dailyData[key] == nil {
                continue
            }

            break
        }

        return streak
    }

    func historyEntries(from startDate: Date, to endDate: Date) -> [(String, DailyRecord)] {
        let startKey = DateHelpers.key(for: min(startDate, endDate))
        let endKey = DateHelpers.key(for: max(startDate, endDate))

        return dailyData
            .filter { $0.key >= startKey && $0.key <= endKey }
            .sorted { $0.key < $1.key }
    }

    func historySummary(from startDate: Date, to endDate: Date) -> HistorySummary {
        let entries = historyEntries(from: startDate, to: endDate)
        let passDays = entries.filter { $0.1.isPassed }.count
        let energyValues = entries.compactMap { $0.1.evening.completed ? $0.1.evening.energy : nil }
        let average = energyValues.isEmpty ? 0 : Double(energyValues.reduce(0, +)) / Double(energyValues.count)
        return HistorySummary(totalDays: entries.count, passDays: passDays, averageEnergy: average, streak: currentStreak())
    }

    var earliestStoredDate: Date {
        dailyData.keys.compactMap(DateHelpers.date(from:)).sorted().first ?? .now
    }

    var latestStoredDate: Date {
        dailyData.keys.compactMap(DateHelpers.date(from:)).sorted().last ?? .now
    }

    private func persist() {
        let state = PersistedState(userName: userName, notificationsEnabled: notificationsEnabled, dailyData: dailyData)
        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: storageKey)
            KeychainStorage.save(data)
        }
    }

    private func load() {
        if let state = decodeState(from: UserDefaults.standard.data(forKey: storageKey)) {
            userName = state.userName
            notificationsEnabled = state.notificationsEnabled
            dailyData = state.dailyData
            if let data = try? JSONEncoder().encode(state) {
                KeychainStorage.save(data)
            }
            return
        }

        guard
            let state = decodeState(from: KeychainStorage.load())
        else {
            return
        }

        userName = state.userName
        notificationsEnabled = state.notificationsEnabled
        dailyData = state.dailyData
        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func decodeState(from data: Data?) -> PersistedState? {
        guard let data else { return nil }
        return try? JSONDecoder().decode(PersistedState.self, from: data)
    }
}
