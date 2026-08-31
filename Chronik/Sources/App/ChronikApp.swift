import SwiftUI
import Generic
import Entries

@main
struct ChronikApp: App {
    private let compositionRoot = AppCompositionRoot()

    var body: some Scene {
        WindowGroup {
            compositionRoot.makeRootView()
        }
    }
}
