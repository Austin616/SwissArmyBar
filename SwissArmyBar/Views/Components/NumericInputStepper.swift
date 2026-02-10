import SwiftUI

struct NumericInputStepper: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let suffix: String
    let palette: Palette

    private var formatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.minimum = NSNumber(value: range.lowerBound)
        formatter.maximum = NSNumber(value: range.upperBound)
        return formatter
    }

    var body: some View {
        HStack(spacing: 8) {
            TextField("", value: $value, formatter: formatter)
                .frame(width: 48)
                .multilineTextAlignment(.trailing)
                .textFieldStyle(.plain)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(palette.textPrimary)
                .onChange(of: value) { _, newValue in
                    value = newValue.clamped(to: range)
                }

            Text(suffix)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(palette.textSecondary)

            ArrowStepper(
                increment: { value = min(range.upperBound, value + step) },
                decrement: { value = max(range.lowerBound, value - step) },
                palette: palette
            )
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(palette.panelFill.opacity(0.55))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(palette.panelStroke, lineWidth: 1)
                )
        )
    }
}

private struct ArrowStepper: View {
    let increment: () -> Void
    let decrement: () -> Void
    let palette: Palette

    var body: some View {
        VStack(spacing: 4) {
            Button(action: increment) {
                Image(systemName: "chevron.up")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(palette.textPrimary)
                    .frame(width: 18, height: 12)
            }
            .buttonStyle(.plain)

            Button(action: decrement) {
                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(palette.textPrimary)
                    .frame(width: 18, height: 12)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(palette.panelFill.opacity(0.75))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(palette.panelStroke, lineWidth: 1)
                )
        )
    }
}
