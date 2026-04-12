import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var store: RebootStore
    @Binding var path: [AppRoute]

    private var todayRecord: DailyRecord {
        store.record(for: .now)
    }

    private var todayProgress: Double {
        store.todayProgress()
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                hero

                VStack(alignment: .leading, spacing: 8) {
                    Text("今日任务")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundStyle(RebootTheme.ink)
                    Text("只保留今天真正需要完成的三件事。")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(RebootTheme.muted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                taskCard(
                    title: "早晨仪式",
                    icon: "sun.max.fill",
                    accent: todayRecord.morning.completed ? RebootTheme.success : RebootTheme.danger,
                    background: todayRecord.morning.completed ? RebootTheme.successSoft : RebootTheme.dangerSoft,
                    status: todayRecord.morning.completed ? "身份已锚定" : "5分钟灵魂拷问",
                    meta: todayRecord.morning.completed ? "恐惧 -> 希望" : "先看最不想面对的未来",
                    route: .morning
                )

                taskCard(
                    title: "白天中断",
                    icon: "bolt.fill",
                    accent: store.completedChecks(in: todayRecord.daytime) >= 2 ? RebootTheme.success : RebootTheme.warning,
                    background: store.completedChecks(in: todayRecord.daytime) >= 2 ? RebootTheme.successSoft : RebootTheme.warningSoft,
                    status: "已完成 \(store.completedChecks(in: todayRecord.daytime))/3",
                    meta: store.completedChecks(in: todayRecord.daytime) >= 2 ? "节奏在线" : "拉回注意力到核心目标",
                    route: .daytime
                )

                taskCard(
                    title: "晚间复盘",
                    icon: "moon.stars.fill",
                    accent: todayRecord.evening.completed ? RebootTheme.success : RebootTheme.primary,
                    background: todayRecord.evening.completed ? RebootTheme.successSoft : RebootTheme.primarySoft,
                    status: todayRecord.evening.completed ? (todayRecord.isPassed ? "今日通关" : "已复盘，未通关") : "今晚做结算",
                    meta: "记录能量值和明日唯一要事",
                    route: .evening
                )

                Button {
                    path.append(.history)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("历史数据查看")
                                .font(.system(size: 18, weight: .black, design: .rounded))
                            Text("放在最后，只用来回看记录、管理提醒和导出数据。")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color.white.opacity(0.86))
                                .multilineTextAlignment(.leading)
                        }
                        Spacer()
                        Image(systemName: "arrow.right")
                            .font(.system(size: 20, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .padding(20)
                    .background(RebootTheme.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .rebootTapTarget(cornerRadius: 20)
                }
                .buttonStyle(.plain)
            }
            .padding(20)
            .padding(.bottom, 24)
        }
        .background(RebootTheme.canvas.ignoresSafeArea())
    }

    private var hero: some View {
        Button {
            path.append(.guide)
        } label: {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top) {
                    Text(DateHelpers.key(for: .now))
                        .font(.system(size: 11, weight: .bold))
                        .kerning(1)
                        .foregroundStyle(Color(hex: "B9C0FF"))
                    Spacer()
                    HStack(spacing: 6) {
                        Text("使用引导")
                            .font(.system(size: 11, weight: .black))
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 10, weight: .black))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.12))
                    .clipShape(Capsule())
                }

                Text("Reboot 2026")
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .foregroundStyle(.white)

                Text("你好，\(store.userName)。")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("每天 5 分钟，完成今天的重启闭环。点击这里查看方法论和使用说明。")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color(hex: "CDD2FF"))

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("今日通关进度")
                            .font(.system(size: 13, weight: .bold))
                        Spacer()
                        Text("\(Int(todayProgress * 100))%")
                            .font(.system(size: 14, weight: .black))
                    }
                    .foregroundStyle(.white)

                    GeometryReader { proxy in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.white.opacity(0.14))
                            Capsule().fill(RebootTheme.warning)
                                .frame(width: proxy.size.width * todayProgress)
                        }
                    }
                    .frame(height: 8)

                    Text("早晨完成 + 2 次白天检查 + 晚间复盘 = 今日闭环")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color(hex: "C6CCFF"))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RebootTheme.night)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .rebootTapTarget(cornerRadius: 28)
        }
        .buttonStyle(.plain)
    }

    private func taskCard(title: String, icon: String, accent: Color, background: Color, status: String, meta: String, route: AppRoute) -> some View {
        Button {
            path.append(route)
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(accent)
                        .frame(width: 56, height: 56)
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .black, design: .rounded))
                    Text(status)
                        .font(.system(size: 15, weight: .bold))
                    Text(meta)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(RebootTheme.muted)
                }
                .foregroundStyle(RebootTheme.ink)

                Spacer(minLength: 0)
            }
            .padding(18)
            .background(background)
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(RebootTheme.line, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .rebootTapTarget(cornerRadius: 20)
        }
        .buttonStyle(.plain)
    }
}
