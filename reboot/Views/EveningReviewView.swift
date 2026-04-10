import SwiftUI

struct EveningReviewView: View {
    @EnvironmentObject private var store: RebootStore
    @Environment(\.dismiss) private var dismiss

    @State private var energy = 5
    @State private var tomorrowGoal = ""

    private var todayRecord: DailyRecord {
        store.record(for: .now)
    }

    private var isPassed: Bool {
        store.isDayPassed(todayRecord)
    }

    private var trend: [(String, DailyRecord)] {
        let calendar = Calendar(identifier: .gregorian)
        guard let startDate = calendar.date(byAdding: .day, value: -6, to: .now) else { return [] }
        return store.historyEntries(from: startDate, to: .now)
    }

    var body: some View {
        VStack(spacing: 0) {
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

                Text("晚间复盘")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(RebootTheme.ink)
                Spacer()
            }
            .padding(20)

            ScrollView {
                VStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(isPassed ? "🏆 今天通关了" : "🎮 今天还没通关")
                            .font(.system(size: 21, weight: .black, design: .rounded))
                        Text("规则：早晨完成 + 2 次白天检查。当前进度是 早晨 \(todayRecord.morning.completed ? "✅" : "❌") / 白天 \(store.completedChecks(in: todayRecord.daytime))/2。")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(RebootTheme.muted)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(18)
                    .background(isPassed ? RebootTheme.successSoft : RebootTheme.primarySoft)
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(isPassed ? RebootTheme.success : RebootTheme.primary, lineWidth: 1)
                    )

                    VStack(alignment: .leading, spacing: 10) {
                        Text("今日能量值")
                            .font(.system(size: 16, weight: .black, design: .rounded))
                        Text("给今天一个分数，帮助你看到一周内的能量曲线。")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(RebootTheme.muted)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 5), spacing: 8) {
                            ForEach(1...10, id: \.self) { value in
                                Button {
                                    energy = value
                                } label: {
                                    Text("\(value)")
                                        .font(.system(size: 15, weight: .black))
                                        .foregroundStyle(energy == value ? .white : RebootTheme.ink)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 52)
                                        .background(energy == value ? RebootTheme.warning : RebootTheme.canvasAlt)
                                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                        .rebootTapTarget(cornerRadius: 16)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(16)
                    .rebootCard()

                    VStack(alignment: .leading, spacing: 10) {
                        Text("明天唯一要事")
                            .font(.system(size: 16, weight: .black, design: .rounded))
                        Text("明天只有哪一件事做完了，我就会觉得很爽？")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(RebootTheme.muted)

                        TextEditor(text: $tomorrowGoal)
                            .frame(minHeight: 88)
                            .rebootTextInput()
                            .overlay(alignment: .topLeading) {
                                if tomorrowGoal.isEmpty {
                                    Text("写下明天最值得先拿下的一件事")
                                        .font(.system(size: 14))
                                        .foregroundStyle(RebootTheme.muted)
                                        .padding(.horizontal, 18)
                                        .padding(.vertical, 20)
                                }
                            }
                    }
                    .padding(16)
                    .rebootCard()

                    VStack(alignment: .leading, spacing: 10) {
                        Text("7 日能量曲线")
                            .font(.system(size: 16, weight: .black, design: .rounded))
                        Text("每次晚间复盘后，这条趋势会更真实。")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(RebootTheme.muted)

                        HStack(alignment: .bottom, spacing: 8) {
                            ForEach(trend, id: \.0) { item in
                                let height = CGFloat(max(item.1.evening.completed ? item.1.evening.energy : 0, 1)) * 7.2
                                VStack(spacing: 4) {
                                    ZStack(alignment: .bottom) {
                                        Capsule().fill(RebootTheme.canvasAlt)
                                        Capsule()
                                            .fill(item.1.isPassed ? RebootTheme.success : RebootTheme.warning)
                                            .frame(height: height)
                                    }
                                    .frame(height: 78)

                                    Text(item.1.evening.completed ? "\(item.1.evening.energy)" : "-")
                                        .font(.system(size: 11, weight: .bold))
                                    Text(DateHelpers.displayFormatter.string(from: DateHelpers.date(from: item.0) ?? .now))
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundStyle(RebootTheme.muted)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(16)
                    .rebootCard()
                }
                .padding(20)
                .padding(.bottom, 132)
            }

            VStack {
                Button("完成复盘") {
                    store.saveEveningReview(energy: energy, tomorrowGoal: tomorrowGoal)
                    dismiss()
                }
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(isPassed ? RebootTheme.success : RebootTheme.primary)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .rebootTapTarget(cornerRadius: 20)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 16)
            .background(RebootTheme.canvas)
            .overlay(alignment: .top) { Divider().overlay(RebootTheme.line) }
        }
        .background(RebootTheme.canvas.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .onAppear {
            energy = todayRecord.evening.energy
            tomorrowGoal = todayRecord.evening.tomorrowGoal
        }
    }
}
