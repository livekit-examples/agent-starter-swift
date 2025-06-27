import SwiftUI

#if os(macOS)
/// A platform-specific view that shows a list of available audio devices.
struct AudioDeviceSelector: View {
    @Environment(AppViewModel.self) private var viewModel

    var body: some View {
        Menu {
            ForEach(viewModel.audioDevices, id: \.deviceId) { device in
                Button {
                    viewModel.select(audioDevice: device)
                } label: {
                    HStack {
                        Text(device.name)
                        if device.deviceId == viewModel.selectedAudioDeviceID {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "chevron.down")
                .frame(height: 11 * .grid)
                .font(.system(size: 12, weight: .semibold))
        }
    }
}
#endif
