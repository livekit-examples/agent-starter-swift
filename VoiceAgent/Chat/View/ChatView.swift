import SwiftUI

/// A multiplatform view that shows the message feed.
struct ChatView: View {
    @Environment(ChatViewModel.self) private var viewModel

    var body: some View {
        ScrollViewReader { scrollView in
            List {
                ForEach(viewModel.messages.values.reversed(), content: message)
            }
            .onChange(of: viewModel.messages.count) {
                withAnimation(.smooth) {
                    scrollView.scrollTo(viewModel.messages.keys.last)
                }
            }
        }
        .upsideDown()
        .listStyle(.plain)
        .scrollIndicators(.never)
        .scrollContentBackground(.hidden)
        .animation(.default, value: viewModel.messages)
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
        .upsideDown()
        .listRowBackground(EmptyView())
        .listRowSeparator(.hidden)
        .id(message.id) // for the ScrollViewReader to work
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
