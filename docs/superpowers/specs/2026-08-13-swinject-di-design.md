# Design: Swinject dependency injection for Chronik

Date: 2026-08-13

## Context

Chronik currently wires dependencies manually in `AccomodationsNavigationView`
(the composition root). `AGENTS.md` lists "No dependency-injection container
yet" as a known limitation. This change introduces a lightweight, single-
container Swinject setup and replaces the manual wiring.

## Goals

- Add Swinject as an SPM dependency.
- Register the project's resources (services + data layer), view models, and
  views in one Swinject `Container`.
- Replace manual construction in `AccomodationsNavigationView` with container
  resolution.
- Keep the change minimal — no Assembler/Assembly abstraction.

## Non-goals

- No `Assembler`/per-layer `Assembly` classes (single container only).
- No repository layer, no new feature screens.
- No change to the test fakes or `makeSut` testing pattern.

## Dependency setup

Add to `project.yml`:

- **Swinject**: `https://github.com/Swinject/Swinject.git`, `from: 2.9.1`,
  product `Swinject` in the `Chronik` target.
- **Range-Slider** (required to survive `xcodegen generate`): branch `main`,
  product `RangeSlider`, in the `Chronik` target. Currently added directly in
  the `.xcodeproj`; adding it to `project.yml` prevents it being dropped on
  regeneration.

Then run `xcodegen generate`.

## Container

New file `Chronik/Sources/App/DIContainer.swift` — a single global container
configured once:

```swift
import Swinject

let appContainer: Container = {
    let c = Container()

    // Resources / data layer
    c.register(SupabaseClient.self) { _ in supabaseClient }.inObjectScope(.container)
    c.register(NavigatorImpl<AccommodationScreen>.self) { _ in NavigatorImpl() }.inObjectScope(.container)
    c.register(AccommodationsService.self) {
        r in AccommodationsServiceImpl(client: r.resolve(SupabaseClient.self)!)
    }.inObjectScope(.container)
    c.register(AccommodationImagesService.self) {
        r in AccommodationImagesServiceImpl(client: r.resolve(SupabaseClient.self)!)
    }.inObjectScope(.container)

    // ViewModels
    c.register(AccommodationsViewModelImpl.self) { r in
        AccommodationsViewModelImpl(
            accommodationsService: r.resolve(AccommodationsService.self)!,
            accommodationImagesService: r.resolve(AccommodationImagesService.self)!,
            navigator: r.resolve(NavigatorImpl<AccommodationScreen>.self)!
        )
    }.inObjectScope(.container)

    // Views
    c.register(AccommodationsView<AccommodationsViewModelImpl>.self) { r in
        AccommodationsView(viewModel: r.resolve(AccommodationsViewModelImpl.self)!)
    }

    return c
}()
```

### Registration rules

- **Protocols with associated types cannot be registered directly.** Register
  concrete types instead:
  - `AccommodationsViewModel` inherits `LoadableCollectionViewModel`
    (associated `State`), so register `AccommodationsViewModelImpl`.
  - `Navigator` is generic over `Screen`, so register
    `NavigatorImpl<AccommodationScreen>`.
- **Views** are registered as concrete closures (`AccommodationsView<
  AccommodationsViewModelImpl>`), resolving the view model from the container.
- **Scopes**: `SupabaseClient`, navigator, services, and the accommodations view
  model use `.container` (singletons) so the `@Observable` view model and
  `@StateObject` navigator remain stable across `body` re-evaluations.

## Wiring changes

`AccomodationsNavigationView.swift`:

- Replace `@StateObject private var navigator = NavigatorImpl<AccommodationScreen>()`
  with resolution from `appContainer`.
- Replace `accommodationsViewModel()` and manual construction in `body` with
  `appContainer.resolve(AccommodationsView<AccommodationsViewModelImpl>.self)!`.
- Delete the `accommodationsViewModel()` helper.

`ChronikApp.swift` is unchanged.

## Testing

- Existing tests use fakes directly and do not touch the container — unchanged.
- Add `Chronik/Tests/DI/DIContainerTests.swift` with one test case verifying the
  container resolves each registered type without crashing:
  `SupabaseClient`, `NavigatorImpl<AccommodationScreen>`, `AccommodationsService`,
  `AccommodationImagesService`, `AccommodationsViewModelImpl`, and
  `AccommodationsView<AccommodationsViewModelImpl>`.

## Risks / notes

- Regenerating the project without adding Range-Slider to `project.yml` would
  drop the package and break `RangeSelectionView` (`import RangeSlider`). The
  design adds it to `project.yml` to avoid this.
- Resolution uses force-unwraps (`!`) on `resolve(...)`. Misconfiguration
  crashes at container setup rather than failing silently; acceptable for a
  minimal container whose registrations are covered by `DIContainerTests`.