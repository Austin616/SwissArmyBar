import SwiftUI

struct TerminalGridBackground: View {
    let lineColor: Color
    let glow: Color

    var body: some View {
        GeometryReader { _ in
            let step: CGFloat = 64
            Canvas { context, size in
                var path = Path()

                stride(from: 0, through: size.width, by: step).forEach { x in
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: size.height))
                }

                stride(from: 0, through: size.height, by: step).forEach { y in
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                }

                context.stroke(path, with: .color(lineColor.opacity(0.22)), lineWidth: 0.5)
            }
            .overlay(
                LinearGradient(
                    colors: [glow, Color.clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .blendMode(.screen)
                .opacity(0.25)
            )
        }
    }
}
