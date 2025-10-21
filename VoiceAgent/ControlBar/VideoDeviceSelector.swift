import AVFoundation
import LiveKitComponents
import SwiftUI

#if os(macOS)
/// A platform-specific view that shows a list of available video devices.
struct VideoDeviceSelector: View {
    @EnvironmentObject private var localMedia: LocalMedia

    var body: some View {
        Menu {
            ForEach(localMedia.videoDevices, id: \.uniqueID) { device in
                AsyncButton {
                    await localMedia.select(videoDevice: device)
                } label: {
                    HStack {
                        Text(device.localizedName)
                        if device.uniqueID == localMedia.selectedVideoDeviceID {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "chevron.down")
                .frame(height: 11 * .grid)
                .font(.system(size: 12, weight: .semibold))
                .contentShape(Rectangle())
        }
    }
}
#endif
