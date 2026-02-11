import SwiftUI

extension View {
    @ViewBuilder
    func alwaysShowScrollIndicators() -> some View {
        if #available(macOS 13.0, *) {
            self.scrollIndicators(.visible)
        } else {
            self
        }
    }
}
