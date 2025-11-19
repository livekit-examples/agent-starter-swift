import SwiftUI

extension EnvironmentValues {
    @Entry var voiceEnabled: Bool = true
    @Entry var videoEnabled: Bool = true
    @Entry var textEnabled: Bool = true
    @Entry var namespace: Namespace.ID? // don't initialize outside View
}
