import Foundation
import LiveKit

extension VideoTrack {
    /// The aspect ratio of the video track or 1 if the dimensions are not available.
    var aspectRatio: CGFloat {
        guard let dimensions else { return 1 }
        return CGFloat(dimensions.width) / CGFloat(dimensions.height)
    }
}
