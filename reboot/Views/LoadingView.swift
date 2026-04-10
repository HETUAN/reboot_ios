import SwiftUI

struct LoadingView: View {
    @State private var appear = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "5662DF"), Color(hex: "31378A")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color.white.opacity(0.16))
                .frame(width: 280, height: 280)
                .blur(radius: 6)
                .offset(x: -80, y: -180)

            Circle()
                .fill(RebootTheme.warning.opacity(0.18))
                .frame(width: 220, height: 220)
                .blur(radius: 8)
                .offset(x: 110, y: 220)

            VStack(spacing: 0) {
                Text("REBOOT 2026")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .kerning(3)
                    .foregroundStyle(Color(hex: "E0E7FF"))

                Capsule()
                    .fill(Color.white.opacity(0.45))
                    .frame(width: 44, height: 2)
                    .padding(.top, 12)

                Text("每天 5 分钟，重启你的人生")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(hex: "EEF2FF"))
                    .padding(.top, 14)

                VStack(spacing: -2) {
                    Text("吾日三省")
                        .font(.system(size: 40, weight: .black, design: .rounded))
                        .kerning(4)
                        .foregroundStyle(.white)

                    Text("吾身")
                        .font(.system(size: 50, weight: .black, design: .rounded))
                        .kerning(10)
                        .foregroundStyle(Color(hex: "F8FAFF"))
                }
                .shadow(color: Color.black.opacity(0.18), radius: 18, y: 8)
                .padding(.top, 30)

                Text("晨起立意，日间校正，夜晚结算")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .kerning(1.4)
                    .foregroundStyle(Color(hex: "DDE2FF"))
                    .padding(.top, 26)
            }
            .padding(.vertical, 34)
            .padding(.horizontal, 24)
            .frame(maxWidth: 360)
            .background(Color.white.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
            )
            .scaleEffect(appear ? 1 : 0.96)
            .opacity(appear ? 1 : 0.4)
            .animation(.easeOut(duration: 0.7), value: appear)
        }
        .onAppear { appear = true }
    }
}
