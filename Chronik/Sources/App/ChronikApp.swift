import SwiftUI
import Generic
import Entries
import SupabaseCore

@main
struct ChronikApp: App {

    init() {
        ApplicationScope.set(assemblies: [
            GenericAssembly(),
            AppAssembly(),
            SupabaseCoreAssembly(),
            EntriesAssembly()
        ])
    }
    
    var body: some Scene {
        WindowGroup {
            EntriesLaunchView()
        }
        #if os(macOS)
        // The Work log is laid out for a phone-width column; without a default
        // the window opens far wider than the content is designed for.
        .defaultSize(width: 480, height: 820)
        #endif
    }
}
