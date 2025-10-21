import LiveKit
import SwiftUI

extension EnvironmentValues {
    @Entry var namespace: Namespace.ID? // don't initialize outside View
    @Entry var agent: Agent?
}
