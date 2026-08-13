import SwiftUI
import SwiftData

@main
struct ChronikApp: App {
    private let service: EntryService

    init() {
        let container = try! ModelContainer(for: EntryEntity.self)
        self.service = EntryServiceImpl(container: container)
    }

    var body: some Scene {
        WindowGroup {
            ChronikRootView(service: service)
        }
    }
}
