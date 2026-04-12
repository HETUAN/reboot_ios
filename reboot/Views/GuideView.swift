import SwiftUI

private struct GuideSection: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
}

private struct GuideStep: Identifiable {
    let id = UUID()
    let time: String
    let title: String
    let detail: String
    let accent: Color
}

struct GuideView: View {
    @Environment(\.dismiss) private var dismiss

    private let pdfSummary: [GuideSection] = [
        GuideSection(
            title: "1. 改变不是先拼自律，而是先换身份",
            detail: "PDF 的核心观点是：大多数计划失败，是因为只改行动，没有改自我认同。真正稳定的行为来自“我就是会这样生活的人”，而不是每天强迫自己坚持。"
        ),
        GuideSection(
            title: "2. 所有行为都在服务某个目标",
            detail: "拖延、刷手机、留在旧工作里，不一定是懒，很多时候是在服务安全感、逃避评价、保护旧身份。要改变，就要先看清这些隐藏目标。"
        ),
        GuideSection(
            title: "3. 反愿景提供推力，愿景提供拉力",
            detail: "先诚实写出如果 5 年、10 年都不改变，生活会变成什么样，再写出真正想要的普通一天。一个负责让你无法继续麻木，一个负责给你方向。"
        ),
        GuideSection(
            title: "4. 高质量改变依赖反馈循环",
            detail: "作者借用控制论解释成长：设定目标、行动、感知反馈、对比目标、再次修正。能持续试错和迭代的人，才更容易拿到想要的生活。"
        ),
        GuideSection(
            title: "5. 把人生变成游戏",
            detail: "最后把方法收束成一套游戏系统：反愿景是输掉的代价，愿景是胜利条件，一年目标是主线任务，一月项目是 Boss 战，每日行动是小任务，约束是游戏规则。"
        )
    ]

    private let guideSteps: [GuideStep] = [
        GuideStep(
            time: "早晨",
            title: "先完成早晨仪式",
            detail: "写下反向愿景、理想一天和今日身份声明。这里对应 PDF 的心理挖掘：看清你不想继续的生活，再给今天换一个身份外壳。",
            accent: RebootTheme.danger
        ),
        GuideStep(
            time: "白天",
            title: "用三次中断打破自动驾驶",
            detail: "在 11:00、14:00、17:00 附近打开白天中断。记录你在逃避什么、当前行为是否值得自豪、是否在推进核心目标。",
            accent: RebootTheme.warning
        ),
        GuideStep(
            time: "晚间",
            title: "用晚间复盘综合反馈",
            detail: "给今天的能量打分，写下明天唯一要事。不要追求完美总结，只要把今天最重要的反馈变成明天的一个行动。",
            accent: RebootTheme.primary
        ),
        GuideStep(
            time: "长期",
            title: "用历史数据看趋势",
            detail: "历史页用来回看通关天数、能量波动和具体记录。它不是用来责备自己，而是用来判断系统是否需要调整。",
            accent: RebootTheme.success
        )
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                header
                summaryCard
                guideCard
                rulesCard
                quickStartCard
            }
            .padding(20)
            .padding(.bottom, 24)
        }
        .background(RebootTheme.canvas.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Button("返回") { dismiss() }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(RebootTheme.ink)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(RebootTheme.paper)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(RebootTheme.line, lineWidth: 1))
                    .rebootTapCapsule()

                Spacer()
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("使用说明与重启引导")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                Text("基于 Dan Koe《如何在一天内彻底重塑人生》整理，把一整天的深度重启流程压缩成 Reboot 2026 的日常闭环。")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color(hex: "DDE2FF"))
                    .lineSpacing(4)
            }
            .foregroundStyle(.white)
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RebootTheme.night)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("PDF 内容总结", subtitle: "不要只立计划，要重设身份、目标和反馈系统。")

            ForEach(pdfSummary) { item in
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.title)
                        .font(.system(size: 15, weight: .black, design: .rounded))
                        .foregroundStyle(RebootTheme.ink)
                    Text(item.detail)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(RebootTheme.muted)
                        .lineSpacing(3)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(RebootTheme.canvasAlt)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
        .padding(18)
        .rebootCard()
    }

    private var guideCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("如何使用这个 App", subtitle: "把一天拆成早晨定身份、白天打断惯性、晚间整合反馈。")

            ForEach(guideSteps) { step in
                HStack(alignment: .top, spacing: 12) {
                    Text(step.time)
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(.white)
                        .frame(width: 44)
                        .padding(.vertical, 8)
                        .background(step.accent)
                        .clipShape(Capsule())

                    VStack(alignment: .leading, spacing: 5) {
                        Text(step.title)
                            .font(.system(size: 15, weight: .black, design: .rounded))
                            .foregroundStyle(RebootTheme.ink)
                        Text(step.detail)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(RebootTheme.muted)
                            .lineSpacing(3)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(RebootTheme.canvas)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(RebootTheme.line, lineWidth: 1)
                )
            }
        }
        .padding(18)
        .rebootCard()
    }

    private var rulesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("通关规则", subtitle: "目标是每天完成一个最小闭环，而不是一次性改变全部人生。")

            bullet("通关条件：早晨仪式完成，并且白天至少完成 2 次检查。")
            bullet("晚间复盘不决定通关，但决定你能否把今天的反馈带到明天。")
            bullet("如果当天失败，不要补偿性用力。第二天重新从早晨仪式开始。")
            bullet("历史页只用来观察趋势，不用来审判自己。")
        }
        .padding(18)
        .background(RebootTheme.primarySoft)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(RebootTheme.primary, lineWidth: 1)
        )
    }

    private var quickStartCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("三天上手建议", subtitle: "先跑通系统，再优化内容质量。")

            numbered("第 1 天：只求完成，不追求写得漂亮。")
            numbered("第 2 天：重点观察白天最常见的逃避模式。")
            numbered("第 3 天：在晚间复盘里固定一个明天最重要行动。")
        }
        .padding(18)
        .rebootCard()
    }

    private func sectionTitle(_ title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundStyle(RebootTheme.ink)
            Text(subtitle)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(RebootTheme.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func bullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(RebootTheme.primary)
                .frame(width: 6, height: 6)
                .padding(.top, 7)
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(RebootTheme.ink)
                .lineSpacing(3)
        }
    }

    private func numbered(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 14, weight: .bold))
            .foregroundStyle(RebootTheme.ink)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(RebootTheme.canvasAlt)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

