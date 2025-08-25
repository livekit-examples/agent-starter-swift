import SwiftUI

struct ChatScrollView<Content: View>: View {
    typealias MessageBuilder = (ReceivedMessage) -> Content

    @EnvironmentObject private var session: AgentSession
    let messageBuilder: MessageBuilder

    var body: some View {
        ScrollViewReader { scrollView in
            ScrollView {
                LazyVStack {
                    ForEach(session.messages.values.reversed(), content: { message in
                        messageBuilder(message)
                            .upsideDown()
                            .id(message.id)
                    })
                }
            }
            .onChange(of: session.messages.count) {
                scrollView.scrollTo(session.messages.keys.last)
            }
            .upsideDown()
            .padding(.horizontal)
            .scrollIndicators(.never)
            .animation(.default, value: session.messages)
        }
    }
}
