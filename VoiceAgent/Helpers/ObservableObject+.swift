import Combine

extension ObservableObject {
    typealias BufferedObjectWillChangePublisher = Publishers.Buffer<ObjectWillChangePublisher>

    // This is necessary due to ObservableObjectPublisher not respecting the demand.
    // See: https://forums.swift.org/t/asyncpublisher-causes-crash-in-rather-simple-situation
    private var bufferedObjectWillChange: BufferedObjectWillChangePublisher {
        objectWillChange
            .buffer(size: 1, prefetch: .byRequest, whenFull: .dropOldest)
    }

    /// A publisher that emits the `objectWillChange` events.
    var changes: AsyncPublisher<BufferedObjectWillChangePublisher> {
        bufferedObjectWillChange.values
    }
}
