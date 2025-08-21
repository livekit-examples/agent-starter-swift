import SwiftUI

#if os(macOS)
/// A platform-specific view that shows a list of available audio devices.
struct AudioDeviceSelector: View {
    @EnvironmentObject private var devices: DeviceSwitcher

    var body: some View {
        Menu {
            ForEach(devices.audioDevices, id: \.deviceId) { device in
                Button {
                    devices.select(audioDevice: device)
                } label: {
                    HStack {
                        Text(device.name)
                        if device.deviceId == devices.selectedAudioDeviceID {
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
