import SwiftUI

struct ConfigCard<Content: View>: View {
    let title: String
    let palette: Palette
    var minHeight: CGFloat? = nil
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundStyle(palette.textSecondary)
            content()
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(palette.cardFill)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(palette.panelStroke, lineWidth: 1)
                )
        )
    }
}
