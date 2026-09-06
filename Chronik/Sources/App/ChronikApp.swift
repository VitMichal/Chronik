import SwiftUI
import Generic
import Entries

@main
struct ChronikApp: App {

    init() {
        ApplicationScope.set(assemblies: [
            GenericAssembly(),
            AppAssembly(),
            EntriesAssembly()
        ])
    }
    
    var body: some Scene {
        WindowGroup {
            EntriesLaunchView()
        }
    }
}
