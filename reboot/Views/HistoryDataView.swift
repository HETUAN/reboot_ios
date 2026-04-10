import SwiftUI

private struct HistoryEntrySelection: Identifiable {
    let id: String
    let key: String
    let record: DailyRecord
}

private struct ShareExportFile: Identifiable {
    let id = UUID()
    let url: URL
}

struct HistoryDataView: View {
    @EnvironmentObject private var store: RebootStore
    @Environment(\.dismiss) private var dismiss

    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var selectedEntry: HistoryEntrySelection?
    @State private var shareFile: ShareExportFile?
    @State private var alertMessage = ""
    @State private var showAlert = false
    @State private var togglingNotifications = false

    private var entries: [(String, DailyRecord)] {
        store.historyEntries(from: startDate, to: endDate)
    }

    private var summary: HistorySummary {
        store.historySummary(from: startDate, to: endDate)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                HStack(spacing: 14) {
                    Button("返回") { dismiss() }
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(RebootTheme.ink)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(RebootTheme.paper)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(RebootTheme.line, lineWidth: 1))
                        .rebootTapCapsule()

                    Text("历史数据查看")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                    Spacer()
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("按时间范围回看记录")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                    Text("你可以自己选开始和结束日期，趋势、明细和导出都会跟着切换。")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color(hex: "DDE2FF"))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(22)
                .background(RebootTheme.primaryDeep)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .foregroundStyle(.white)

                reminderCard
                rangeCard
                metricsRow
                insightCard
                energyTrendCard
                historyDetailCard
            }
            .padding(20)
            .padding(.bottom, 24)
        }
        .background(RebootTheme.canvas.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .sheet(item: $selectedEntry) { selection in
            HistoryDetailSheet(item: (selection.key, selection.record))
        }
        .sheet(item: $shareFile) { file in
            ShareSheet(items: [file.url])
        }
        .alert("提醒设置", isPresented: $showAlert) {
            Button("知道了", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            startDate = store.earliestStoredDate
            endDate = store.latestStoredDate
        }
    }

    private var reminderCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("提醒设置")
                .font(.system(size: 18, weight: .black, design: .rounded))
            Text("历史数据页里也可以直接管理每天的提醒开关。")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(RebootTheme.muted)

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(store.notificationsEnabled ? "提醒已开启" : "提醒已关闭")
                        .font(.system(size: 16, weight: .black, design: .rounded))
                    Text(store.notificationsEnabled ? "每天 06:00 / 11:00 / 14:00 / 17:00 / 21:00 会触发提醒。" : "当前不会调度任何本地提醒。")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(RebootTheme.muted)
                }
                Spacer()
                Button(togglingNotifications ? "处理中" : (store.notificationsEnabled ? "关闭" : "开启")) {
                    Task { await toggleNotifications() }
                }
                .font(.system(size: 13, weight: .black))
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(store.notificationsEnabled ? RebootTheme.danger : RebootTheme.primaryDeep)
                .clipShape(Capsule())
                .rebootTapCapsule()
                .disabled(togglingNotifications)
            }
        }
        .padding(18)
        .rebootCard()
    }

    private var rangeCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("时间范围")
                .font(.system(size: 18, weight: .black, design: .rounded))
            Text("从已有记录里选起止日期。")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(RebootTheme.muted)

            HStack(spacing: 12) {
                rangePicker(title: "开始日期", selection: $startDate)
                rangePicker(title: "结束日期", selection: $endDate)
            }

            Button("导出 JSON 数据") {
                exportJSON()
            }
            .font(.system(size: 14, weight: .black))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(entries.isEmpty ? Color(hex: "A5B4FC") : RebootTheme.primaryDeep)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .rebootTapTarget(cornerRadius: 18)
            .disabled(entries.isEmpty)
        }
        .padding(18)
        .rebootCard()
    }

    private var metricsRow: some View {
        HStack(spacing: 12) {
            metricCard(title: "区间通关", value: "\(summary.passDays)/\(summary.totalDays)", hint: "当前连续 \(summary.streak) 天")
            metricCard(title: "平均能量", value: String(format: "%.1f", summary.averageEnergy), hint: "满分 10 分")
        }
    }

    private var insightCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("历史摘要")
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundStyle(Color(hex: "8A5A00"))
            Text(entries.isEmpty ? "当前选中的时间范围里还没有历史记录。" : "当前区间共记录 \(summary.totalDays) 天，通关 \(summary.passDays) 天。")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color(hex: "8A5A00"))

            if let weakest = entries.compactMap({ $0.1.evening.completed ? ($0.0, $0.1.evening.energy) : nil }).min(by: { $0.1 < $1.1 }) {
                Text("最低能量日是 \(DateHelpers.displayFormatter.string(from: DateHelpers.date(from: weakest.0) ?? .now))，分数 \(weakest.1)。")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color(hex: "8A5A00"))
            } else {
                Text("这个时间范围里还没有足够的晚间能量数据。")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color(hex: "8A5A00"))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(RebootTheme.warningSoft)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(RebootTheme.warning, lineWidth: 1)
        )
    }

    private var energyTrendCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("能量趋势")
                .font(.system(size: 18, weight: .black, design: .rounded))
            Text("时间拉长后，这里会更适合看波动和阶段变化。")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(RebootTheme.muted)

            if entries.isEmpty {
                Text("当前时间范围内还没有可展示的趋势数据。")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(RebootTheme.muted)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .bottom, spacing: 10) {
                        ForEach(entries, id: \.0) { item in
                            let energy = item.1.evening.completed ? item.1.evening.energy : 0
                            VStack(spacing: 4) {
                                ZStack(alignment: .bottom) {
                                    Capsule().fill(RebootTheme.canvasAlt)
                                    Capsule()
                                        .fill(item.1.isPassed ? RebootTheme.success : RebootTheme.primary)
                                        .frame(height: CGFloat(max(energy, 1)) * 8)
                                }
                                .frame(width: 44, height: 120)

                                Text(energy == 0 ? "-" : "\(energy)")
                                    .font(.system(size: 12, weight: .bold))
                                Text(DateHelpers.displayFormatter.string(from: DateHelpers.date(from: item.0) ?? .now))
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(RebootTheme.muted)
                            }
                        }
                    }
                }
            }
        }
        .padding(18)
        .rebootCard()
    }

    private var historyDetailCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("历史明细")
                .font(.system(size: 18, weight: .black, design: .rounded))
            Text("点开某一天，查看当天三段流程里实际记录了什么。")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(RebootTheme.muted)

            if entries.isEmpty {
                Text("这个时间范围内还没有任何历史明细。")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(RebootTheme.muted)
            } else {
                ForEach(entries.reversed(), id: \.0) { entry in
                    Button {
                        selectedEntry = HistoryEntrySelection(id: entry.0, key: entry.0, record: entry.1)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("\(DateHelpers.displayFormatter.string(from: DateHelpers.date(from: entry.0) ?? .now)) \(entry.1.isPassed ? "已通关" : "未通关")")
                                    .font(.system(size: 15, weight: .black, design: .rounded))
                                    .foregroundStyle(RebootTheme.ink)
                                Text("早晨 \(entry.1.morning.completed ? "✅" : "❌") / 白天 \(store.completedChecks(in: entry.1.daytime))/3 / 晚间 \(entry.1.evening.completed ? "✅" : "❌")")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(RebootTheme.muted)
                            }
                            Spacer()
                            Text("查看")
                                .font(.system(size: 14, weight: .black))
                                .foregroundStyle(RebootTheme.primary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 14)
                        .rebootTapTarget()
                    }
                    .buttonStyle(.plain)

                    if entry.0 != entries.first?.0 {
                        Divider().overlay(RebootTheme.line)
                    }
                }
            }
        }
        .padding(18)
        .rebootCard()
    }

    private func metricCard(title: String, value: String, hint: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(RebootTheme.muted)
            Text(value)
                .font(.system(size: 28, weight: .black, design: .rounded))
            Text(hint)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(RebootTheme.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .rebootCard()
    }

    private func rangePicker(title: String, selection: Binding<Date>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(RebootTheme.muted)
            DatePicker("", selection: selection, in: store.earliestStoredDate...store.latestStoredDate, displayedComponents: .date)
                .datePickerStyle(.compact)
                .labelsHidden()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(RebootTheme.canvas)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(RebootTheme.line, lineWidth: 1)
        )
    }

    private func toggleNotifications() async {
        if togglingNotifications { return }
        togglingNotifications = true
        defer { togglingNotifications = false }

        if store.notificationsEnabled {
            NotificationService.cancelReminders()
            store.setNotificationsEnabled(false)
            return
        }

        let settings = await NotificationService.notificationSettings()
        let granted = settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional
        let finalGranted = granted ? true : await NotificationService.requestAuthorization()

        guard finalGranted else {
            alertMessage = "系统没有授予通知权限，请先在系统设置里允许通知。"
            showAlert = true
            return
        }

        do {
            try await NotificationService.scheduleReminders()
            store.setNotificationsEnabled(true)
        } catch {
            alertMessage = "这次没有成功更新提醒状态，请再试一次。"
            showAlert = true
        }
    }

    private func exportJSON() {
        guard !entries.isEmpty else { return }

        let range: [String: Any] = [
            "startDate": DateHelpers.key(for: min(startDate, endDate)),
            "endDate": DateHelpers.key(for: max(startDate, endDate)),
        ]

        let summaryPayload: [String: Any] = [
            "totalDays": summary.totalDays,
            "passDays": summary.passDays,
            "averageEnergy": summary.averageEnergy,
            "currentStreak": summary.streak,
        ]

        let entryPayloads: [[String: Any]] = entries.map { key, record in
            [
                "date": key,
                "isPassed": record.isPassed,
                "checksCount": store.completedChecks(in: record.daytime),
                "morning": [
                    "completed": record.morning.completed,
                    "reverseVision": record.morning.reverseVision,
                    "miniVision": record.morning.miniVision,
                    "identity": record.morning.identity,
                ] as [String: Any],
                "daytime": [
                    "check1": reflectionJSON(kind: .check1, record: record.daytime),
                    "check2": reflectionJSON(kind: .check2, record: record.daytime),
                    "check3": reflectionJSON(kind: .check3, record: record.daytime),
                ] as [String: Any],
                "evening": [
                    "completed": record.evening.completed,
                    "energy": record.evening.completed ? record.evening.energy : NSNull(),
                    "tomorrowGoal": record.evening.tomorrowGoal,
                ] as [String: Any],
            ]
        }

        let payload: [String: Any] = [
            "product": "Reboot 2026",
            "exportedAt": ISO8601DateFormatter().string(from: .now),
            "range": range,
            "summary": summaryPayload,
            "entries": entryPayloads,
        ]

        guard
            JSONSerialization.isValidJSONObject(payload),
            let data = try? JSONSerialization.data(withJSONObject: payload, options: [.prettyPrinted, .sortedKeys])
        else {
            return
        }

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("reboot-history-\(Int(Date().timeIntervalSince1970)).json")
        try? data.write(to: url, options: .atomic)
        shareFile = ShareExportFile(url: url)
    }

    private func reflectionJSON(kind: DaytimeCheckKind, record: DaytimeRecord) -> [String: Any] {
        let reflection = record.reflections[kind] ?? DaytimeReflection()
        let completed: Bool = {
            switch kind {
            case .check1: return record.check1
            case .check2: return record.check2
            case .check3: return record.check3
            }
        }()

        return [
            "completed": completed,
            "avoidanceType": reflection.avoidanceType?.rawValue ?? "",
            "proudLevel": reflection.proudLevel?.rawValue ?? "",
            "note": reflection.note,
        ]
    }
}

private struct HistoryDetailSheet: View {
    let item: (String, DailyRecord)
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("早晨仪式")
                            .font(.system(size: 17, weight: .black, design: .rounded))
                        detailLine("反向愿景", item.1.morning.reverseVision)
                        detailLine("极简愿景", item.1.morning.miniVision)
                        detailLine("身份确认", item.1.morning.identity)
                    }
                    .padding(16)
                    .rebootCard()

                    VStack(alignment: .leading, spacing: 12) {
                        Text("白天中断")
                            .font(.system(size: 17, weight: .black, design: .rounded))
                        ForEach(DaytimeCheckKind.allCases) { kind in
                            let reflection = item.1.daytime.reflections[kind] ?? DaytimeReflection()
                            VStack(alignment: .leading, spacing: 6) {
                                Text(kind.title)
                                    .font(.system(size: 14, weight: .black))
                                    .foregroundStyle(RebootTheme.primaryDeep)
                                detailLine("逃避类型", reflection.avoidanceType?.label ?? "未记录")
                                detailLine("自豪感", reflection.proudLevel?.label ?? "未记录")
                                detailLine("备注", reflection.note.isEmpty ? "未填写" : reflection.note)
                            }

                            if kind != .check3 {
                                Divider().overlay(RebootTheme.line)
                            }
                        }
                    }
                    .padding(16)
                    .rebootCard()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("晚间复盘")
                            .font(.system(size: 17, weight: .black, design: .rounded))
                        detailLine("能量值", item.1.evening.completed ? "\(item.1.evening.energy)" : "未记录")
                        detailLine("明天唯一要事", item.1.evening.tomorrowGoal.isEmpty ? "未填写" : item.1.evening.tomorrowGoal)
                    }
                    .padding(16)
                    .rebootCard()
                }
                .padding(20)
            }
            .background(RebootTheme.canvas.ignoresSafeArea())
            .navigationTitle("\(DateHelpers.displayFormatter.string(from: DateHelpers.date(from: item.0) ?? .now)) 历史明细")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("关闭") { dismiss() }
                }
            }
        }
    }

    private func detailLine(_ title: String, _ value: String) -> some View {
        Text("\(title)：\(value)")
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(RebootTheme.ink)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
