import Foundation
import Swinject
import Generic
import Entries

/// The root view is generic over its navigator because SwiftUI's `@StateObject`
/// needs a concrete `ObservableObject`; everything else depends on `Navigator`.
typealias RootView = ChronikRootView<EntriesViewModelImpl, StackNavigatorImpl<EntryScreen>>

final class AppAssembly: Assembly {
    func assemble(container: Container) {
        container.register(RootView.self) { resolver in
            let navigator = resolver.resolve(StackNavigatorImpl<EntryScreen>.self)!
            let entriesViewModel = resolver.resolve(EntriesViewModelImpl.self)!
            let makeEntryFormViewModel: (UUID?) -> EntryFormViewModelImpl = { entryID in
                guard let viewModel = resolver.resolve(EntryFormViewModel.self, argument: entryID) as? EntryFormViewModelImpl else {
                    fatalError("EntryFormViewModel registration must resolve EntryFormViewModelImpl")
                }
                return viewModel
            }
            return ChronikRootView(
                navigator: navigator,
                entriesViewModel: entriesViewModel,
                makeEntryFormViewModel: makeEntryFormViewModel
            )
        }
    }
}
