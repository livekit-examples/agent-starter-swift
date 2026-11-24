import LiveKitComponents
import SwiftUI

/// The initial view that is shown when the app is not connected to the server.
struct StartView: View {
    @EnvironmentObject private var session: Session

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Namespace private var button

    @State private var audioOptionsPresented = false

    var body: some View {
        VStack(spacing: 8 * .grid) {
            bars()
            connectButton()
            audioOptionsButton()
        }
        .padding(.horizontal, horizontalSizeClass == .regular ? 32 * .grid : 16 * .grid)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .bottom, content: tip)
        #if os(visionOS)
            .glassBackgroundEffect()
            .frame(maxWidth: 175 * .grid)
        #endif
    }

    private func bars() -> some View {
        HStack(spacing: .grid) {
            let bars = [2, 8, 12, 8, 2].map { $0 * .grid }
            ForEach(0 ..< 5, id: \.self) { index in
                Rectangle()
                    .fill(.fg0)
                    .frame(width: 2 * .grid, height: bars[index])
            }
        }
    }

    private func tip() -> some View {
        VStack(spacing: 2 * .grid) {
            #if targetEnvironment(simulator)
                Text("connect.simulator")
                    .foregroundStyle(.fgModerate)
            #endif
            Text("connect.tip")
                .foregroundStyle(.fg3)
        }
        .font(.system(size: 12))
        .multilineTextAlignment(.center)
        .safeAreaPadding(.horizontal, horizontalSizeClass == .regular ? 32 * .grid : 16 * .grid)
        .safeAreaPadding(.vertical)
    }

    private func connectButton() -> some View {
        AsyncButton {
            await session.start()
        } label: {
            HStack {
                Spacer()
                Text("connect.start")
                    .matchedGeometryEffect(id: "connect", in: button)
                Spacer()
            }
            .frame(width: 58 * .grid, height: 11 * .grid)
        } busyLabel: {
            HStack(spacing: 4 * .grid) {
                Spacer()
                Spinner()
                    .transition(.scale.combined(with: .opacity))
                Text("connect.connecting")
                    .matchedGeometryEffect(id: "connect", in: button)
                Spacer()
            }
            .frame(width: 58 * .grid, height: 11 * .grid)
        }
        #if os(visionOS)
        .buttonStyle(.borderedProminent)
        .controlSize(.extraLarge)
        #else
        .buttonStyle(ProminentButtonStyle())
        #endif
    }

    private func audioOptionsButton() -> some View {
        Button {
            audioOptionsPresented = true
        } label: {
            HStack(spacing: .grid) {
                Image(systemName: "slider.horizontal.3")
                Text("audio.title")
            }
            .font(.system(size: 13))
            .foregroundStyle(.fg3)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .popover(isPresented: $audioOptionsPresented) {
            AudioOptionsSheet()
        }
    }
}

#Preview {
    StartView()
}
