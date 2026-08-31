import Swinject

final class AppCompositionRoot {
    private let assembler: Assembler

    init() {
        assembler = Assembler([
            AppAssembly(),
            EntriesAssembly()
        ])
    }

    func makeRootView() -> ChronikRootView<EntriesViewModelImpl> {
        assembler.resolver.resolve(ChronikRootView<EntriesViewModelImpl>.self)!
    }
}
