import LiveKitComponents
import SwiftUI

/// A multiplatform view that shows the chat input text field and send button.
struct ChatInputView: View {
    @EnvironmentObject private var session: Session

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @FocusState.Binding var keyboardFocus: Bool
    @State private var messageText = ""

    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            textField()
            sendButton()
        }
        .frame(minHeight: 12 * .grid)
        .frame(maxWidth: horizontalSizeClass == .regular ? 128 * .grid : 92 * .grid)
        #if !os(visionOS)
            .background(.bg2)
        #endif
            .clipShape(RoundedRectangle(cornerRadius: 6 * .grid))
            .safeAreaPadding(.horizontal, 4 * .grid)
            .safeAreaPadding(.bottom, 4 * .grid)
    }

    @ViewBuilder
    private func textField() -> some View {
        TextField("message.placeholder", text: $messageText, axis: .vertical)
        #if os(iOS)
            .focused($keyboardFocus)
        #endif
        #if os(visionOS)
        .textFieldStyle(.roundedBorder)
        .hoverEffectDisabled()
        #else
        .textFieldStyle(.plain)
        #endif
        .lineLimit(3)
        .submitLabel(.send)
        .onSubmit {
            // Will be called on macOS/Simulator with hardware keyboard
            Task {
                await sendMessage()
            }
        }
        .onChange(of: messageText.last?.isNewline ?? false) { _, forceSubmit in
            // onSubmit won't be called by the submit key when using a software keyboard with a .vertical TextField
            if forceSubmit {
                Task {
                    await sendMessage()
                }
            }
        }
        #if !os(visionOS)
        .foregroundStyle(.fg1)
        #endif
        .padding()
    }

    @ViewBuilder
    private func sendButton() -> some View {
        AsyncButton(action: sendMessage) {
            Image(systemName: "arrow.up")
                .frame(width: 8 * .grid, height: 8 * .grid)
        }
        #if os(iOS)
        .padding([.bottom, .trailing], 3 * .grid)
        #else
        .padding([.bottom, .trailing], 2 * .grid)
        #endif
        .disabled(messageText.isEmpty)
        #if os(visionOS)
            .buttonStyle(.plain)
        #else
            .buttonStyle(RoundButtonStyle())
        #endif
    }

    private func sendMessage() async {
        guard !messageText.isEmpty else { return }
        let text = messageText
        messageText = ""
        keyboardFocus = false
        await session.send(text: text)
    }
}
