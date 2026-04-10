import SwiftUI

struct DaytimeCheckView: View {
    @EnvironmentObject private var store: RebootStore
    @Environment(\.dismiss) private var dismiss

    @State private var activeCheck: DaytimeCheckKind?
    @State private var avoidanceType: AvoidanceType = .focus
    @State private var proudLevel: ProudLevel = .mid
    @State private var note = ""

    private var todayRecord: DailyRecord {
        store.record(for: .now)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
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

                    Text("白天中断")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                    Spacer()
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("30 秒把自动驾驶拉停")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                    Text("11:00、14:00、17:00 三次检查，把注意力拉回今天最重要的事。")
                        .font(.system(size: 14, weight: .medium))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(RebootTheme.primarySoft)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))

                ForEach(DaytimeCheckKind.allCases) { check in
                    let isCompleted = isCompleted(check)
                    let reflection = todayRecord.daytime.reflections[check] ?? DaytimeReflection()

                    Button {
                        open(check: check, reflection: reflection)
                    } label: {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text(check.timeLabel)
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(isCompleted ? RebootTheme.success : RebootTheme.primaryDeep)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(isCompleted ? Color(hex: "D7F6E7") : RebootTheme.primarySoft)
                                    .clipShape(Capsule())
                                Spacer()
                                Image(systemName: check.icon)
                                    .font(.system(size: 22, weight: .bold))
                            }

                            Text(check.question)
                                .font(.system(size: 18, weight: .black, design: .rounded))
                                .foregroundStyle(RebootTheme.ink)
                                .multilineTextAlignment(.leading)

                            Text(summary(for: check, reflection: reflection, completed: isCompleted))
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(RebootTheme.muted)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(18)
                        .background(isCompleted ? RebootTheme.successSoft : RebootTheme.paper)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(isCompleted ? RebootTheme.success : RebootTheme.line, lineWidth: 1)
                        )
                        .rebootTapTarget(cornerRadius: 20)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(20)
        }
        .background(RebootTheme.canvas.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .sheet(item: $activeCheck) { check in
            DaytimeCheckSheet(
                kind: check,
                avoidanceType: $avoidanceType,
                proudLevel: $proudLevel,
                note: $note
            ) {
                let inputAvoidance = check == .check1 ? avoidanceType : nil
                let inputProud = check == .check2 ? proudLevel : nil
                store.saveDaytimeCheck(kind: check, avoidanceType: inputAvoidance, proudLevel: inputProud, note: note)
                activeCheck = nil
            }
        }
    }

    private func isCompleted(_ kind: DaytimeCheckKind) -> Bool {
        switch kind {
        case .check1: return todayRecord.daytime.check1
        case .check2: return todayRecord.daytime.check2
        case .check3: return todayRecord.daytime.check3
        }
    }

    private func summary(for kind: DaytimeCheckKind, reflection: DaytimeReflection, completed: Bool) -> String {
        guard completed else { return "点开后 30 秒完成一次觉察记录" }
        switch kind {
        case .check1:
            return reflection.avoidanceType?.label ?? "已记录"
        case .check2:
            return reflection.proudLevel?.label ?? "已记录"
        case .check3:
            return reflection.note.isEmpty ? "已记录" : reflection.note
        }
    }

    private func open(check: DaytimeCheckKind, reflection: DaytimeReflection) {
        avoidanceType = reflection.avoidanceType ?? .focus
        proudLevel = reflection.proudLevel ?? .mid
        note = reflection.note
        activeCheck = check
    }
}

private struct DaytimeCheckSheet: View {
    let kind: DaytimeCheckKind
    @Binding var avoidanceType: AvoidanceType
    @Binding var proudLevel: ProudLevel
    @Binding var note: String
    let onSubmit: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(kind.question)
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundStyle(RebootTheme.ink)

                    if kind == .check1 {
                        Text("这次最像哪种逃避？")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(RebootTheme.muted)
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(AvoidanceType.allCases) { option in
                                Button {
                                    avoidanceType = option
                                } label: {
                                    Text(option.label)
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundStyle(avoidanceType == option ? RebootTheme.primaryDeep : RebootTheme.ink)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(avoidanceType == option ? RebootTheme.primarySoft : RebootTheme.canvas)
                                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                                .stroke(avoidanceType == option ? RebootTheme.primary : RebootTheme.line, lineWidth: 1)
                                        )
                                        .rebootTapTarget(cornerRadius: 18)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    if kind == .check2 {
                        Text("如果现在被拍成纪录片，你会？")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(RebootTheme.muted)
                        HStack(spacing: 10) {
                            ForEach(ProudLevel.allCases) { option in
                                Button {
                                    proudLevel = option
                                } label: {
                                    Text(option.label)
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundStyle(proudLevel == option ? Color(hex: "9A6708") : RebootTheme.ink)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(proudLevel == option ? RebootTheme.warningSoft : RebootTheme.paper)
                                        .clipShape(Capsule())
                                        .overlay(Capsule().stroke(proudLevel == option ? RebootTheme.warning : RebootTheme.line, lineWidth: 1))
                                        .rebootTapCapsule()
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    Text(kind == .check1 ? "一句提醒" : kind == .check2 ? "一句调整" : "一句聚焦")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(RebootTheme.muted)

                    TextEditor(text: $note)
                        .frame(height: 120)
                        .rebootTextInput()
                }
                .padding(20)
            }
            .background(RebootTheme.canvas.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成检查") {
                        onSubmit()
                    }
                    .fontWeight(.bold)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
