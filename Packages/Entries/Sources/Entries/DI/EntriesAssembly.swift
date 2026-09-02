import Foundation
import Swinject
import Generic

public final class EntriesAssembly: Assembly {
    public init() {}
    
    public func assemble(container: Container) {
        container.register(NavigatorImpl<EntryScreen>.self) { _ in
            NavigatorImpl<EntryScreen>()
        }.inObjectScope(.container)

        container.register(EntryService.self) { resolver in
            MainActor.assumeIsolated {
                EntryServiceImpl()
            }
        }.inObjectScope(.container)

        container.register(EntriesViewModelImpl.self) { resolver in
            MainActor.assumeIsolated {
                EntriesViewModelImpl(
                    service: resolver.resolve(EntryService.self)!,
                    navigator: resolver.resolve(NavigatorImpl<EntryScreen>.self)!
                )
            }
        }.inObjectScope(.container)

        container.register(EntryFormViewModel.self) { (resolver, entryID: UUID?) in
            MainActor.assumeIsolated {
                EntryFormViewModelImpl(
                    entryID: entryID,
                    service: resolver.resolve(EntryService.self)!,
                    navigator: resolver.resolve(NavigatorImpl<EntryScreen>.self)!
                )
            }
        }
    }
}
