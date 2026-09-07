# AGENTS.md

## Project overview

**Chronik** is a personal work log — a dated chronicle of what the user did at
work. Users record what they did as an **Entry** (date, title, optional
duration, optional notes) and browse the **Work log** grouped by **Day**.

- Swift 5.9 language mode, SwiftUI, iOS 17.0+ deployment target, **Xcode 16.3+**
  (supabase-swift needs a Swift 6.1 toolchain; the project's own sources stay on
  the 5.9 language mode)
- Persistence via **Supabase** (Postgres + RLS, anonymous auth). The app is
  remote-only — there is no offline support
- Project generated with [XcodeGen](https://github.com/yonaskolb/XcodeGen) from `project.yml`; the `.xcodeproj` is checked in

## Build & test

- **Supabase credentials are required to build.** They live in a gitignored
  xcconfig — create it once:

  ```
  cp Chronik/Config/Supabase.local.xcconfig.example Chronik/Config/Supabase.local.xcconfig
  ```

  Then fill in `SUPABASE_URL` and `SUPABASE_ANON_KEY`. **Write the URL without a
  scheme** (`your-project.supabase.co`): `//` starts a comment in xcconfig, so
  `https://…` is silently truncated to `https:`. A full URL needs the slashes
  escaped — `http:/$()/localhost:54321`. The app traps at launch with instructions
  if a value is missing or truncated.

  `Chronik/Config/Supabase.xcconfig` is tracked, blank, and optionally includes the
  local file, so a fresh clone builds without it. No environment variables are
  involved, and launching Xcode from the Dock works.
- Build/run: open `Chronik.xcodeproj` in Xcode 16.3+ and run the `Chronik` scheme on an iOS 17+ simulator.
- Tests: package schemes `Generic` and `Entries` (XCTest). Run `xcodebuild test -scheme Generic` from `Packages/Generic` (same for Entries). `ChronikTests` is an app-level stub. Packages are iOS-only — use `xcodebuild`, not `swift test`. Tests need no credentials and no network.
- Database schema lives in `supabase/migrations/`. Anonymous sign-in must be enabled in the Supabase dashboard.
- Regenerate the project after editing `project.yml`: `xcodegen generate` (requires `brew install xcodegen`).
- Local modules live under `Packages/` (`Generic`, `Entries`, `SupabaseCore`). The app consumes them via `packages: path:` in `project.yml`. Remote SPM deps used by the app must also be declared there — xcodegen drops anything added directly to the `.xcodeproj`.


## Project Structure
Chronik/Sources/App/            # @main entry point, composition root
Packages/Generic/               # reusable infrastructure (local SPM package)
  Sources/Generic/
    Extensions/                 # extensions to common data structures, helpers and syntax sugars
    Presentation/               # viewmodels abstraction, generic formatters
    Theme/                      # color theme, UI styling
    View/                       # view abstractions used by other views in features
  Tests/GenericTests/
Packages/SupabaseCore/          # Supabase client + auth session (local SPM package)
  Sources/SupabaseCore/         # SupabaseProvider, SupabaseConfiguration, assembly
Packages/Entries/               # Entries feature (local SPM package, depends on Generic + SupabaseCore)
  Sources/Entries/
    Domain/                     # Feature domain entities
    Services/                   # Data access services
    Presentation/               # Presentation logic classes, ViewModels and Formatters
    View/                       # View implementation
    DI/                         # EntriesAssembly
  Tests/EntriesTests/

## Architecture
MVVM with a protocol-based service layer and code-driven navigation. Data flows
one way: **Views → ViewModels → Services → SwiftData**, and back through
pre-formatted state objects.

### Views
Views are made with SwiftUI. 
- If view has content which needs to be loaded, use LoadableView or LoadableCollectionView, inside views body function, also use .onAppear to trigger viewModels load/fetch function to trigger loading
- Views has viewModel const property with corresponding viewmodels protocol type

### ViewModels
- Presentation layer consists of protocol named <FeatureName>ViewModel and its implementation named <FeatureName>ViewModelImpl, both holds property state. State can be Loadable<State>, LoadableCollection<State> or plain struct (if it is static content)
- protocol named <FeatureName>ViewModel inherits from LoadableCollectionViewModel or LoadableViewModel if it provides state which needs to be loaded
- protocol named <FeatureName>ViewModel is @MainActor
- implementation of viewmodel named <FeatureName>ViewModelImpl, implements protocol <FeatureName>ViewModel and inherits LoadableCollectionViewModelImpl<StateType> or LoadableViewModelImpl<StateType>, and uses @MainActor and @Observable   
- If viewmodel uses asynchronous service methods, viewmodels methods should be also asynchronous, avoid using Tasks
- every viewmodel implementaion has its own tests 
- Depend on service protocols and `Navigator`, never on SwiftUI.

### `Services/` — data access.
  - Each service is a **public protocol + internal `*Impl` class** (e.g. `EntryService` / `SupabaseEntryService`).
  - Service protocols are `Sendable`, **not** `@MainActor` — network I/O and decoding must stay off the main thread. View models are `@MainActor` and `await`.
  - **Persistence details are confined to service implementations only** — the wire DTO (`SupabaseEntryRow`) and the SwiftData `@Model` class both live inside the service layer and map to plain public structs; neither may leak into view models, views, or models.
  - Services map transport failures into a domain error type (`EntryServiceError`) so views render something a person can act on.
  - `EntryServiceImpl` (SwiftData) is retained but unregistered — it is the starting point if offline support is ever added. Do not delete it.

### Navigation
- View models trigger navigation by calling `navigator.navigateTo(Screen.route)` where `Screen` is a `Hashable` enum.
- `NavigatorImpl<Screen>` wraps a SwiftUI `NavigationPath` (`@Published`) and is bound in the `NavigationStack`.
- Routing (mapping screen enum → destination view) lives in the `navigationDestination(for:)` switch in the root navigation view.

### State handling
- Async data is exposed as `Loadable<State>` / `LoadableCollection<State>` (`loading` / `success` / `error`).
- `LoadableView` / `LoadableCollectionView` switch on state and render the default loading/error/empty views, wiring `retryAction` back to the view model.

### Testing

- Each local package has its own XCTest target (`GenericTests`, `EntriesTests`).
- Hand-written stubs live next to the tests that use them and conform to the service/navigator protocols (e.g. `NavigatorStub`) so view models are tested without persistence.
- Test view models directly against their protocols/state; follow the existing `makeSut(...)` pattern with injectable fakes.
- `ChronikTests` is reserved for app-level tests.

## Conventions

- Follow the protocol + `*Impl` split for any new service; keep the persistence model inside the service layer.
- View models produce pre-formatted display strings in `*State` structs; views render state, they do not format.
- Use `@Observable` for view models, `@StateObject` for the navigator, and generic views over view-model protocols.
- Use `Theme.pallete` / `Theme.dimensions` for all colors, padding, and corner radii — no hardcoded values.
- New features are local SPM packages under `Packages/` with a `Package.swift`, consumed by the app via `project.yml`.
- New screens get a `Hashable` route case, a feature VM folder, a feature view folder, and (when behavior is non-trivial) tests with fakes.
- Use the domain vocabulary from `CONTEXT.md` (`Entry`, `Work log`, `Day`) in code, tests, and issues.
- Public domain models and service protocols carry `public` access so the test target can import them; implementations and views stay `internal`.

## Known limitations / future work

- No repository layer yet — view models talk to services directly.
- **No offline support.** The Work log is unreadable and unwritable without a connection.
- **No pagination** — `fetchAll()` carries `.limit(500)`.
- Identity is a per-install anonymous Supabase user; a lost device is a lost Work log until it is linked to a real account.
- The Entry feature is in progress: the Work log list (grouped by Day), the add-Entry form, and the Entry detail screen are tracked as GitHub issues (see below).
- Supabase design rationale: `docs/superpowers/specs/2026-09-07-supabase-persistence-design.md`.

## Agent skills

### Issue tracker

Issues live as GitHub issues via the `gh` CLI. See `docs/agents/issue-tracker.md`.

### Triage labels

Five canonical roles: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context — one root `CONTEXT.md`, ADRs in `docs/adr/`. See `docs/agents/domain.md`.
