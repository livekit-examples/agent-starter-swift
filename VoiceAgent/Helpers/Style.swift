import SwiftUI

extension CGFloat {
    /// The grid spacing used as a design unit.
    static let grid: Self = 4

    #if os(visionOS)
    /// The corner radius for the platform-specific UI elements.
    static let cornerRadiusPerPlatform: Self = 11.5 * grid
    #else
    /// The corner radius for the platform-specific UI elements.
    static let cornerRadiusPerPlatform: Self = 2 * grid
    #endif

    /// The corner radius for the small UI elements.
    static let cornerRadiusSmall: Self = 2 * grid

    /// The corner radius for the large UI elements.
    static let cornerRadiusLarge: Self = 4 * grid
}

struct ProminentButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .textCase(.uppercase)
            .font(.system(size: 14, weight: .semibold, design: .monospaced))
            .foregroundStyle(.white)
            .background(.fgAccent.opacity(configuration.isPressed ? 0.75 : 1))
            .cornerRadius(8)
    }
}

struct RoundButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.white)
            .background(isEnabled ? .fgAccent.opacity(configuration.isPressed ? 0.75 : 1) : .fg4.opacity(0.4))
            .clipShape(Circle())
    }
}

struct ControlBarButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled

    var isToggled: Bool = false
    let foregroundColor: Color
    let backgroundColor: Color
    let borderColor: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .medium))
            .foregroundStyle(isEnabled ? foregroundColor.opacity(configuration.isPressed ? 0.75 : 1) : borderColor)
            .background(
                RoundedRectangle(cornerRadius: .cornerRadiusPerPlatform)
                    .fill(isToggled ? backgroundColor : .clear)
            )
    }
}

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

struct Shimmering: ViewModifier {
    @State private var isShimmering = false

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
                    startPoint: isShimmering ? UnitPoint(x: 1, y: 0) : UnitPoint(x: -1, y: 0),
                    endPoint: isShimmering ? UnitPoint(x: 2, y: 0) : UnitPoint(x: 0, y: 0)
                )
                .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: isShimmering)
            )
            .onAppear {
                isShimmering = true
            }
    }
}

extension View {
    func blurredTop() -> some View {
        modifier(BlurredTop())
    }

    func shimmering() -> some View {
        modifier(Shimmering())
    }
}
