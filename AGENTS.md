# AGENTS.md

## Project overview

**Chronik** is an iOS accommodation browsing app (Airbnb-like) built as a
reference/template project. Users browse a list of available stays (with price
filtering) and open a detail screen for a selected stay.

- Swift 5.9+, SwiftUI, iOS 17.0+ deployment target, Xcode 15+
- Backend: Supabase (Postgres), accessed through the `supabase-swift` SDK
- Project generated with [XcodeGen](https://github.com/yonaskolb/XcodeGen) from `project.yml`; the `.xcodeproj` is checked in

## Build & test

- Build/run: open `Chronik.xcodeproj` in Xcode 15+ and run the `Chronik` scheme on an iOS 17+ simulator.
- Tests: `ChronikTests` unit-test target (XCTest). Run via `Cmd+U` on that scheme.
- Regenerate the project after editing `project.yml`: `xcodegen generate` (requires `brew install xcodegen`).
- SPM packages are declared in `project.yml` (`supabase-swift`) plus `Range-Slider` (added directly in the `.xcodeproj`, so it will be dropped if you regenerate without adding it to `project.yml`).

## Architecture

MVVM with a protocol-based service layer and code-driven navigation. Data flows
one way: **Views → ViewModels → Services → Supabase**, and back through
pre-formatted state objects.

### Layers (`Chronik/Sources/`)

- `App/` — `@main` entry point. Renders the root navigation view.
- `Views/` — SwiftUI views only (no business logic).
  - `Generic/` — reusable state-driven views (`LoadableView`, `LoadableCollectionView`, `DefaultLoadingView/ErrorView/EmptyView`) and `NavigatorImpl`.
  - `Theme/` — `Theme` static accessor exposing `pallete` (semantic colors from `ColorAssets.xcassets`) and `dimensions` (padding/radius scale).
  - `Accommodations/`, `AccommodationDetail/` — feature screens. Each view is generic over its view-model protocol and is initialized with a concrete VM in `AccomodationsNavigationView` (the composition root).
- `ViewModels/` — presentation logic, `@Observable` classes conforming to view-model protocols. Depend on service protocols and `Navigator`, never on SwiftUI.
  - `Generic/` — `Loadable`/`LoadableCollection` enums and base view-model classes, `Navigator` protocol.
  - Feature folders — define a `*State` struct (pre-formatted `String` fields, e.g. `price` as `"€85 / night"`, ready for display) and the VM that maps domain models to state.
- `Models/` — plain public domain structs (`Accommodation`, `AccommodationDetail`, `AccommodationImage`). This is the API boundary between services and view models.
- `Services/` — data access.
  - Each service is a **public protocol + internal `*Impl` class** (e.g. `AccommodationsService` / `AccommodationsServiceImpl`).
  - **Supabase is confined to service implementations only** — it must never leak into view models, views, or models.
  - `DTOs/` — `Codable` structs with snake_case `CodingKeys` matching Supabase column names; services map DTOs → domain models.
- `Extensions/` — small pure helpers (e.g. `Decimal.toDouble()`).

### Navigation

- View models trigger navigation by calling `navigator.navigateTo(Screen.route)` where `Screen` is a `Hashable` enum (e.g. `AccommodationScreen.accommodationDetail(accommodationId:)`).
- `NavigatorImpl<Screen>` wraps a SwiftUI `NavigationPath` (`@Published`) and is bound in the `NavigationStack`.
- Routing (mapping screen enum → destination view) lives in the `navigationDestination(for:)` switch in `AccomodationsNavigationView`.

### State handling

- Async data is exposed as `Loadable<State>` / `LoadableCollection<State>` (`loading` / `success` / `error`).
- `LoadableView` / `LoadableCollectionView` switch on state and render the default loading/error/empty views, wiring `retryAction` back to the view model.

### Testing

- XCTest unit tests in `Chronik/Tests/`, one folder per feature.
- Hand-written stubs in `Tests/Fakes/` conform to the service/navigator protocols (e.g. `AccommodationsServiceStub`, `NavigatorStub`) so view models are tested without networking.
- Test view models directly against their protocols/state; follow the existing `makeSut(...)` pattern with injectable fakes.

## Conventions

- Follow the protocol + `*Impl` split for any new service; keep DTO decoding (snake_case keys) inside the service layer.
- View models produce pre-formatted display strings in `*State` structs; views render state, they do not format.
- Use `@Observable` for view models, `@StateObject` for the navigator, and generic views over view-model protocols.
- Use `Theme.pallete` / `Theme.dimensions` for all colors, padding, and corner radii — no hardcoded values.
- New screens get a `Hashable` route case, a feature VM folder, a feature view folder, and (when behavior is non-trivial) tests with fakes.
- Existing code intentionally contains the `Accomodation` (missing "m") typo in some names (e.g. `AccomodationsService`, `AccomodationsNavigationView`, `AccomodationDetailService`). Preserve existing names when referencing them; do not rename across the codebase without checking both spellings.
- Public domain models and service protocols carry `public` access so the test target can import them; implementations, DTOs, and views stay `internal`.

## Known limitations / future work (from NOTES.md)

- No repository layer yet — view models talk to services directly.
- Single app target; ideally each feature becomes its own target with a defined Swift API (protocols + entities).
- No dependency-injection container yet — wiring is manual in `AccomodationsNavigationView`.
- The `AccommodationDetail` screen currently renders only the header (title, location, price, rating); image gallery, amenities, host, and reviews are still to come.

## Agent skills

### Issue tracker

Issues live as GitHub issues via the `gh` CLI. See `docs/agents/issue-tracker.md`.

### Triage labels

Five canonical roles: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context — one root `CONTEXT.md`, ADRs in `docs/adr/`. See `docs/agents/domain.md`.
