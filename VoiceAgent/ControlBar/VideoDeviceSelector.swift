import AVFoundation
import SwiftUI

#if os(macOS)
/// A platform-specific view that shows a list of available video devices.
struct VideoDeviceSelector: View {
    @EnvironmentObject private var devices: DeviceSwitcher

    var body: some View {
        Menu {
            ForEach(devices.videoDevices, id: \.uniqueID) { device in
                AsyncButton {
                    await devices.select(videoDevice: device)
                } label: {
                    HStack {
                        Text(device.localizedName)
                        if device.uniqueID == devices.selectedVideoDeviceID {
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
