import SwiftUI

struct ChatView: View {
    var body: some View {
        ChatScrollView(messageBuilder: message)
            .padding(.horizontal)
    }

    @ViewBuilder
    private func message(_ message: ReceivedMessage) -> some View {
        ZStack {
            switch message.content {
            case let .userTranscript(text):
                userTranscript(text)
            case let .agentTranscript(text):
                agentTranscript(text)
            }
        }
    }

    @ViewBuilder
    private func userTranscript(_ text: String) -> some View {
        HStack {
            Spacer(minLength: 4 * .grid)
            Text(text.trimmingCharacters(in: .whitespacesAndNewlines))
                .font(.system(size: 17))
                .padding(.horizontal, 4 * .grid)
                .padding(.vertical, 2 * .grid)
                .foregroundStyle(.fg1)
                .background(
                    RoundedRectangle(cornerRadius: .cornerRadiusLarge)
                        .fill(.bg2)
                )
        }
    }

    @ViewBuilder
    private func agentTranscript(_ text: String) -> some View {
        HStack {
            Text(text.trimmingCharacters(in: .whitespacesAndNewlines))
                .font(.system(size: 17))
                .padding(.vertical, 2 * .grid)
            Spacer(minLength: 4 * .grid)
        }
    }
}
