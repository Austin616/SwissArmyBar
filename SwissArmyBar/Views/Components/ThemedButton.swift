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
            Capsule()
                .fill(palette.accent)
        case .secondary:
            Capsule()
                .fill(palette.panelFill.opacity(0.5))
                .overlay(
                    Capsule()
                        .stroke(palette.panelStroke, lineWidth: 1)
                )
        case .ghost:
            Capsule()
                .fill(Color.clear)
        }
    }

    private var fontSize: CGFloat {
        size == .small ? 11 : 13
    }

    private var horizontalPadding: CGFloat {
        size == .small ? 10 : 16
    }

    private var verticalPadding: CGFloat {
        size == .small ? 5 : 7
    }

    private var minHeight: CGFloat {
        size == .small ? 24 : 28
    }
}
