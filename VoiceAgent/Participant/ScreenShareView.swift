import LiveKitComponents

/// A view that shows the screen share preview.
struct ScreenShareView: View {
    @Environment(AppViewModel.self) private var viewModel
    @Environment(\.namespace) private var namespace

    var body: some View {
        if let screenShareTrack = viewModel.screenShareTrack {
            SwiftUIVideoView(screenShareTrack)
                .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusPerPlatform))
                .aspectRatio(screenShareTrack.aspectRatio, contentMode: .fit)
                .shadow(radius: 20, y: 10)
                .transition(.scale.combined(with: .opacity))
                .matchedGeometryEffect(id: "screen", in: namespace!)
        }
    }
}
