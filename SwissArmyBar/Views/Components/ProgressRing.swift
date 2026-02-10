import SwiftUI

struct ProgressRing: View {
    let progress: Double
    let accent: Color
    let track: Color

    var body: some View {
        ZStack {
            Circle()
                .stroke(track.opacity(0.5), lineWidth: 10)
            Circle()
                .trim(from: 0, to: progress.clamped(to: 0...1))
                .stroke(accent, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
    }
}
