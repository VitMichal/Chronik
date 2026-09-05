import Swinject
import Generic
import Entries

final class AppCompositionRoot {
    private let assembler: Assembler

    init() {
        assembler = Assembler([
            AppAssembly(),
            EntriesAssembly()
        ])
    }

    func makeRootView() -> RootView {
        assembler.resolver.resolve(RootView.self)!
    }
}
