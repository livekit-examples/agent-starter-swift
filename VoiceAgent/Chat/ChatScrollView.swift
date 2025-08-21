import LiveKit
import SwiftUI

struct ChatScrollView<Content: View>: View {
    typealias MessageBuilder = (ReceivedMessage) -> Content

    @LKConversation private var conversation
    let messageBuilder: MessageBuilder

    var body: some View {
        ScrollViewReader { scrollView in
            ScrollView {
                LazyVStack {
                    ForEach(conversation.messages.values.reversed(), content: { message in
                        messageBuilder(message)
                            .upsideDown()
                            .id(message.id)
                    })
                }
            }
            .onChange(of: conversation.messages.count) {
                scrollView.scrollTo(conversation.messages.keys.last)
            }
            .upsideDown()
            .scrollIndicators(.never)
            .animation(.default, value: conversation.messages)
        }
    }
}

private struct UpsideDown: ViewModifier {
    func body(content: Content) -> some View {
        content
            .rotationEffect(.radians(Double.pi))
            .scaleEffect(x: -1, y: 1, anchor: .center)
    }
}

private extension View {
    func upsideDown() -> some View {
        modifier(UpsideDown())
    }
}
