import SwiftUI

/// A view modifier that flips the view upside down.
/// It may be used to create e.g. an inverted List.
/// - SeeAlso: ``ChatView``
struct UpsideDown: ViewModifier {
    func body(content: Content) -> some View {
        content
            .rotationEffect(.radians(Double.pi))
            .scaleEffect(x: -1, y: 1, anchor: .center)
    }
}

/// A view modifier that slightly blurs the top of the view.
struct BlurredTop: ViewModifier {
    func body(content: Content) -> some View {
        content.mask(
            LinearGradient(
                gradient: Gradient(colors: [.clear, .black, .black]),
                startPoint: .top,
                endPoint: .init(x: 0.5, y: 0.2)
            )
        )
    }
}

/// A view modifier that creates a shimmering effect.
struct Shimerring: ViewModifier {
    @State private var isShimmering = true

    func body(content: Content) -> some View {
        content
            .mask(
                LinearGradient(
                    colors: [
                        .black.opacity(0.4),
                        .black,
                        .black,
                        .black.opacity(0.4),
                    ],
                    startPoint: isShimmering ? UnitPoint(x: -1, y: 0) : UnitPoint(x: 1, y: 0),
                    endPoint: isShimmering ? UnitPoint(x: 0, y: 0) : UnitPoint(x: 2, y: 0)
                )
                .animation(.linear(duration: 2.5).repeatForever(autoreverses: false), value: isShimmering)
            )
            .onAppear {
                isShimmering = false
            }
    }
}

extension View {
    /// Flips the view upside down.
    func upsideDown() -> some View {
        modifier(UpsideDown())
    }

    /// Blurs the top of the view.
    func blurredTop() -> some View {
        modifier(BlurredTop())
    }

    /// Creates a shimmering effect.
    func shimmering() -> some View {
        modifier(Shimerring())
    }
}
