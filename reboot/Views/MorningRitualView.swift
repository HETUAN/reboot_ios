import SwiftUI

struct MorningRitualView: View {
    @EnvironmentObject private var store: RebootStore
    @Environment(\.dismiss) private var dismiss

    @State private var step = 0
    @State private var reverseVision = ""
    @State private var miniVision = ""
    @State private var identity = ""

    private let steps: [(String, String, String, Color)] = [
        (
            "反向愿景",
            "继续现在的状态，5 年后的我会怎样？",
            "如果我继续懒惰、继续拖延、继续现在的坏习惯，5 年后我的人生会惨成什么样？",
            RebootTheme.danger
        ),
        (
            "极简愿景",
            "2026 年理想的一天是什么样？",
            "如果 2026 年一切顺利，我理想的一天是几点起床？在哪里？在做什么？赚多少钱？",
            RebootTheme.primary
        ),
        (
            "身份确认",
            "为了配得上上面的生活，我今天必须是一个什么样的人？",
            "例如：专注的人、不刷手机的人、敢于行动的人、守时的人。",
            RebootTheme.success
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                Button(step == 0 ? "返回" : "上一步") {
                    if step == 0 {
                        dismiss()
                    } else {
                        step -= 1
                    }
                }
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(RebootTheme.ink)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(RebootTheme.paper)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(RebootTheme.line, lineWidth: 1))
                .rebootTapCapsule()

                Text("早晨仪式")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(RebootTheme.ink)

                Spacer()
            }
            .padding(20)

            ScrollView {
                VStack(spacing: 18) {
                    HStack(spacing: 10) {
                        ForEach(steps.indices, id: \.self) { index in
                            Capsule()
                                .fill(index <= step ? steps[step].3 : RebootTheme.line)
                                .frame(height: 8)
                        }
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("第 \(step + 1) 步 / 3")
                            .font(.system(size: 12, weight: .black))
                            .foregroundStyle(steps[step].3)
                        Text(steps[step].0)
                            .font(.system(size: 30, weight: .black, design: .rounded))
                            .foregroundStyle(RebootTheme.ink)
                        Text(steps[step].1)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(RebootTheme.ink)

                        TextEditor(text: binding(for: step))
                            .frame(minHeight: 240)
                            .rebootTextInput(contentPadding: 14, cornerRadius: 20)
                            .overlay(alignment: .topLeading) {
                                if binding(for: step).wrappedValue.isEmpty {
                                    Text(steps[step].2)
                                        .font(.system(size: 15))
                                        .foregroundStyle(RebootTheme.muted)
                                        .padding(.horizontal, 18)
                                        .padding(.vertical, 22)
                                        .allowsHitTesting(false)
                                }
                            }
                    }
                    .padding(22)
                    .background(RebootTheme.paper)
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(steps[step].3, lineWidth: 2)
                    )
                }
                .padding(20)
                .padding(.bottom, 140)
            }

            VStack {
                Button(step == 2 ? "完成早晨仪式" : "继续下一步") {
                    if step < 2 {
                        step += 1
                    } else {
                        store.saveMorning(reverseVision: reverseVision, miniVision: miniVision, identity: identity)
                        dismiss()
                    }
                }
                .font(.system(size: 17, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(steps[step].3)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .rebootTapTarget(cornerRadius: 20)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 20)
            .background(RebootTheme.canvas)
            .overlay(alignment: .top) { Divider().overlay(RebootTheme.line) }
        }
        .background(RebootTheme.canvas.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .onAppear {
            let record = store.record(for: .now)
            reverseVision = record.morning.reverseVision
            miniVision = record.morning.miniVision
            identity = record.morning.identity
        }
    }

    private func binding(for step: Int) -> Binding<String> {
        switch step {
        case 0: return $reverseVision
        case 1: return $miniVision
        default: return $identity
        }
    }
}
