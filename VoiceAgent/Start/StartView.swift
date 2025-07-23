import SwiftUI

/// The initial view that is shown when the app is not connected to the server.
struct StartView: View {
    @Environment(AppViewModel.self) private var viewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @Namespace private var button

    var body: some View {
        VStack(spacing: 8 * .grid) {
            bars()
            connectButton()
        }
        .padding(.horizontal, horizontalSizeClass == .regular ? 32 * .grid : 16 * .grid)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .bottom, content: tip)
        #if os(visionOS)
            .glassBackgroundEffect()
            .frame(maxWidth: 175 * .grid)
        #endif
    }

    @ViewBuilder
    private func bars() -> some View {
        HStack(spacing: .grid) {
            ForEach(0 ..< 5, id: \.self) { index in
                Rectangle()
                    .fill(.fg0)
                    .frame(width: 2 * .grid, height: barHeight(index))
            }
        }
    }

    private func barHeight(_ index: Int) -> CGFloat {
        let heights: [CGFloat] = [2, 8, 12, 8, 2].map { $0 * .grid }
        return heights[index]
    }

    @ViewBuilder
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

    @ViewBuilder
    private func connectButton() -> some View {
        AsyncButton(action: viewModel.connect) {
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
}

#Preview {
    StartView()
        .environment(AppViewModel())
}
