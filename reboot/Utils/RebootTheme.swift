import SwiftUI
import UIKit

enum RebootTheme {
    static let canvas = Color(lightHex: "F5F7FF", darkHex: "0E1324")
    static let canvasAlt = Color(lightHex: "EEF2FF", darkHex: "151C34")
    static let paper = Color(lightHex: "FFFFFF", darkHex: "1B2340")
    static let ink = Color(lightHex: "111827", darkHex: "F3F6FF")
    static let muted = Color(lightHex: "6B7280", darkHex: "A7B0C5")
    static let line = Color(lightHex: "D9E0FF", darkHex: "33405F")
    static let primary = Color(lightHex: "6366F1", darkHex: "818CF8")
    static let primaryDeep = Color(lightHex: "4338CA", darkHex: "A5B4FC")
    static let primarySoft = Color(lightHex: "E0E7FF", darkHex: "252F57")
    static let danger = Color(lightHex: "EF4444", darkHex: "F87171")
    static let dangerSoft = Color(lightHex: "FEE2E2", darkHex: "4A1E28")
    static let warning = Color(lightHex: "F59E0B", darkHex: "FBBF24")
    static let warningSoft = Color(lightHex: "FEF3C7", darkHex: "4A3914")
    static let success = Color(lightHex: "10B981", darkHex: "34D399")
    static let successSoft = Color(lightHex: "D1FAE5", darkHex: "163A31")
    static let night = Color(lightHex: "171A3A", darkHex: "0A0E1E")
    static let inputBackground = Color(lightHex: "F5F7FF", darkHex: "12182D")
}

extension Color {
    init(lightHex: String, darkHex: String) {
        self.init(uiColor: UIColor { traitCollection in
            UIColor(hex: traitCollection.userInterfaceStyle == .dark ? darkHex : lightHex)
        })
    }

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}

private struct RebootTextInputModifier: ViewModifier {
    let contentPadding: CGFloat
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .scrollContentBackground(.hidden)
            .foregroundColor(RebootTheme.ink)
            .tint(RebootTheme.primary)
            .padding(contentPadding)
            .background(RebootTheme.inputBackground)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(RebootTheme.line, lineWidth: 1)
            )
    }
}

extension View {
    func rebootCard() -> some View {
        self
            .background(RebootTheme.paper)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(RebootTheme.line, lineWidth: 1)
            )
    }

    func rebootTextInput(contentPadding: CGFloat = 12, cornerRadius: CGFloat = 18) -> some View {
        modifier(RebootTextInputModifier(contentPadding: contentPadding, cornerRadius: cornerRadius))
    }

    func rebootTapTarget() -> some View {
        contentShape(Rectangle())
    }

    func rebootTapTarget(cornerRadius: CGFloat) -> some View {
        contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }

    func rebootTapCapsule() -> some View {
        contentShape(Capsule())
    }
}
