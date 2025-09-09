import LiveKitComponents

/// A view that shows the local participant's camera view with flip control.
struct LocalParticipantView: View {
    @EnvironmentObject private var devices: DeviceSwitcher
    @Environment(\.namespace) private var namespace

    var body: some View {
        if let cameraTrack = devices.localCameraTrack {
            SwiftUIVideoView(cameraTrack)
                .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusPerPlatform))
                .aspectRatio(cameraTrack.aspectRatio, contentMode: .fit)
                .shadow(radius: 20, y: 10)
                .transition(.scale.combined(with: .opacity))
                .overlay(alignment: .bottomTrailing) {
                    if devices.canSwitchCamera {
                        AsyncButton(action: devices.switchCamera) {
                            Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90")
                                .padding(2 * .grid)
                                .foregroundStyle(.fg0)
                                .background(.bg1.opacity(0.8))
                                .clipShape(Circle())
                        }
                        .padding(2 * .grid)
                    }
                }
                .matchedGeometryEffect(id: "camera", in: namespace!)
        }
    }
}
