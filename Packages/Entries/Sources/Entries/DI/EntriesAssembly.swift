import Foundation
import Swinject
import Generic
import SupabaseCore

public final class EntriesAssembly: Assembly {
    public init() {}
    
    public func assemble(container: Container) {
        container.register(StackNavigatorImpl<EntryScreen>.self) { _ in
            StackNavigatorImpl<EntryScreen>()
        }.inObjectScope(.container)

        container.register((any Navigator<EntryScreen>).self) { resolver in
            resolver.resolve(StackNavigatorImpl<EntryScreen>.self)!
        }

        container.register(EntryService.self) { resolver in
            SupabaseEntryService(
                provider: resolver.resolve((any SupabaseProvider).self)!
            )
        }.inObjectScope(.container)

        container.register(EntriesViewModelImpl.self) { resolver in
            MainActor.assumeIsolated {
                EntriesViewModelImpl(
                    service: resolver.resolve(EntryService.self)!,
                    navigator: resolver.resolve((any Navigator<EntryScreen>).self)!
                )
            }
        }.inObjectScope(.container)

        container.register(EntryFormViewModelImpl.self) { (resolver, entryID: UUID?) in
            MainActor.assumeIsolated {
                EntryFormViewModelImpl(
                    entryID: entryID,
                    service: resolver.resolve(EntryService.self)!,
                    navigator: resolver.resolve((any Navigator<EntryScreen>).self)!
                )
            }
        }
    }
}
