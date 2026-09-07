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
    }
}
