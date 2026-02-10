import SwiftUI

struct NumericInputStepper: View {
    @Binding var value: Int
    let range: ClosedRange<Int>
    let step: Int
    let suffix: String
    let palette: Palette

    @State private var text: String

    init(value: Binding<Int>, range: ClosedRange<Int>, step: Int, suffix: String, palette: Palette) {
        _value = value
        self.range = range
        self.step = step
        self.suffix = suffix
        self.palette = palette
        _text = State(initialValue: "\(value.wrappedValue)")
    }

    var body: some View {
        HStack(spacing: 8) {
            TextField("", text: $text)
                .frame(width: 48)
                .multilineTextAlignment(.trailing)
                .textFieldStyle(.plain)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(palette.textPrimary)
                .onChange(of: text) { _, newValue in
                    let filtered = newValue.filter { $0.isNumber }
                    if filtered != newValue {
                        text = filtered
                    }
                    guard let intValue = Int(filtered) else { return }
                    value = min(max(intValue, range.lowerBound), range.upperBound)
                }
                .onChange(of: value) { _, newValue in
                    text = "\(newValue)"
                }
                .onSubmit {
                    if text.isEmpty {
                        value = range.lowerBound
                        text = "\(value)"
                    }
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
        VStack(spacing: 0) {
            Button(action: increment) {
                Image(systemName: "chevron.up")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(palette.textPrimary)
                    .frame(width: 20, height: 14)
            }
            .buttonStyle(.plain)
            Divider()
                .overlay(palette.panelStroke.opacity(0.8))
            Button(action: decrement) {
                Image(systemName: "chevron.down")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(palette.textPrimary)
                    .frame(width: 20, height: 14)
            }
            .buttonStyle(.plain)
        }
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(palette.panelFill.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(palette.panelStroke, lineWidth: 1)
                )
        )
    }
}
