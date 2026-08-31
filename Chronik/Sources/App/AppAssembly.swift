import Foundation
import Swinject

final class AppAssembly: Assembly {
    func assemble(container: Container) {
        container.register(ChronikRootView<EntriesViewModelImpl>.self) { resolver in
            let navigator = resolver.resolve(NavigatorImpl<EntryScreen>.self)!
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
