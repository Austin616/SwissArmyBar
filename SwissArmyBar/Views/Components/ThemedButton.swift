import SwiftUI

enum ThemedButtonStyle {
    case primary
    case secondary
    case ghost
}

enum ThemedButtonSize {
    case regular
    case small
}

struct ThemedButton: View {
    let title: String
    let style: ThemedButtonStyle
    let size: ThemedButtonSize
    let palette: Palette
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: fontSize, weight: .semibold, design: .rounded))
                .foregroundStyle(foregroundColor)
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, verticalPadding)
                .frame(minHeight: minHeight)
                .background(backgroundShape)
        }
        .buttonStyle(.plain)
    }

    private var foregroundColor: Color {
        switch style {
        case .primary:
            return Color.white
        case .secondary:
            return palette.textPrimary
        case .ghost:
            return palette.textSecondary
        }
    }

    @ViewBuilder
    private var backgroundShape: some View {
        switch style {
        case .primary:
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(palette.accent)
        case .secondary:
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(palette.panelFill.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(palette.panelStroke, lineWidth: 1)
                )
        case .ghost:
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.clear)
        }
    }

    private var fontSize: CGFloat {
        size == .small ? 11 : 13
    }

    private var horizontalPadding: CGFloat {
        size == .small ? 10 : 14
    }

    private var verticalPadding: CGFloat {
        size == .small ? 6 : 8
    }

    private var minHeight: CGFloat {
        size == .small ? 26 : 30
    }
}
