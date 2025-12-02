#if os(iOS)
import LiveKit

nonisolated class SampleHandler: LKSampleHandler, @unchecked Sendable {
    override var enableLogging: Bool { true }
}
#endif
