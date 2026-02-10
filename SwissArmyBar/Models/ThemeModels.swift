import SwiftUI

struct Palette {
    let backgroundTop: Color
    let backgroundBottom: Color
    let panelFill: Color
    let panelStroke: Color
    let cardFill: Color
    let textPrimary: Color
    let textSecondary: Color
    let accent: Color
    let divider: Color
    let successFill: Color
    let glow: Color

    init(isDark: Bool, customColors: CustomColors) {
        backgroundTop = customColors.backgroundTop
        backgroundBottom = customColors.backgroundBottom
        panelFill = customColors.panelFill
        cardFill = customColors.cardFill
        accent = customColors.accent
        glow = customColors.accent.opacity(isDark ? 0.32 : 0.20)

        panelStroke = isDark
            ? Color(red: 0.14, green: 0.18, blue: 0.24)
            : Color(red: 0.78, green: 0.82, blue: 0.87)
        divider = isDark
            ? Color(red: 0.12, green: 0.16, blue: 0.22)
            : Color(red: 0.80, green: 0.84, blue: 0.88)
        textPrimary = customColors.textPrimary
        textSecondary = customColors.textSecondary
        successFill = isDark
            ? Color(red: 0.10, green: 0.19, blue: 0.16)
            : Color(red: 0.88, green: 0.95, blue: 0.90)
    }
}

struct CustomColors {
    var backgroundTop: Color
    var backgroundBottom: Color
    var panelFill: Color
    var cardFill: Color
    var accent: Color
    var textPrimary: Color
    var textSecondary: Color
}

struct ThemePreset: Identifiable {
    let id = UUID()
    let name: String
    let isDark: Bool
    let backgroundTop: HSVColor
    let backgroundBottom: HSVColor
    let panelFill: HSVColor
    let cardFill: HSVColor
    let accent: HSVColor
    let textPrimary: HSVColor
    let textSecondary: HSVColor
}

struct HSVColor: Equatable, Codable {
    var h: Double
    var s: Double
    var v: Double

    var color: Color {
        let (r, g, b) = Self.rgb(from: self)
        return Color(red: r, green: g, blue: b)
    }

    var hex: String {
        let (r, g, b) = Self.rgb(from: self)
        let rInt = Int((r * 255).rounded().clamped(to: 0.0...255.0))
        let gInt = Int((g * 255).rounded().clamped(to: 0.0...255.0))
        let bInt = Int((b * 255).rounded().clamped(to: 0.0...255.0))
        return String(format: "#%02X%02X%02X", rInt, gInt, bInt)
    }

    static func fromRGB(_ r: Double, _ g: Double, _ b: Double) -> HSVColor {
        let maxValue = max(r, g, b)
        let minValue = min(r, g, b)
        let delta = maxValue - minValue

        var hue: Double = 0
        if delta > 0 {
            if maxValue == r {
                hue = ((g - b) / delta).truncatingRemainder(dividingBy: 6)
            } else if maxValue == g {
                hue = ((b - r) / delta) + 2
            } else {
                hue = ((r - g) / delta) + 4
            }
            hue /= 6
            if hue < 0 { hue += 1 }
        }

        let saturation = maxValue == 0 ? 0 : (delta / maxValue)
        return HSVColor(h: hue, s: saturation, v: maxValue)
    }

    private static func rgb(from hsv: HSVColor) -> (Double, Double, Double) {
        let h = hsv.h.clamped(to: 0...1) * 6
        let s = hsv.s.clamped(to: 0...1)
        let v = hsv.v.clamped(to: 0...1)

        let i = floor(h)
        let f = h - i
        let p = v * (1 - s)
        let q = v * (1 - s * f)
        let t = v * (1 - s * (1 - f))

        switch Int(i) % 6 {
        case 0: return (v, t, p)
        case 1: return (q, v, p)
        case 2: return (p, v, t)
        case 3: return (p, q, v)
        case 4: return (t, p, v)
        default: return (v, p, q)
        }
    }
}

extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        min(max(self, range.lowerBound), range.upperBound)
    }

    var degreesToRadians: Double {
        self * .pi / 180
    }
}
