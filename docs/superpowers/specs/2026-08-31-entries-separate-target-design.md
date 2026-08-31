# Entries Feature as Separate Target

## Goal

Extract the Entries feature into its own framework target (`Entries`) and the shared Generic code into a `Generic` framework target, so features are isolated and the app consumes them as modules.

## Targets

| Target | Type | Sources | Dependencies |
|--------|------|---------|-------------|
| `Generic` | framework | `Sources/Generic/` | (none) |
| `Entries` | framework | `Sources/Features/Entries/` | `Generic` |
| `Chronik` | application | `Sources/App/` | `Generic`, `Entries`, `Swinject` |
| `ChronikTests` | unit-test | `Tests/` | `Chronik`, `Generic`, `Entries` |

## Dependency Graph

```
Chronik (App) ──→ Generic
    │
    └──→ Entries ──→ Generic
```

## Access Control Changes

Entries types need `public` access for the Chronik app to consume them:

- `Entry` struct (already public)
- `EntryScreen` enum
- `EntryService` protocol
- `EntryFormViewModel` protocol
- `EntriesViewModel` protocol
- `EntriesViewModelImpl` class
- `EntryFormViewModelImpl` class
- `EntryRow` struct
- `DaySection` struct
- `EntryFormState` struct

Generic types already have `public` access — no changes needed.

## DI Wiring

- `EntriesAssembly` moves into `Entries` target
- `AppAssembly` stays in `Chronik` app (wires ChronikRootView)
- `AppCompositionRoot` stays in `Chronik` app (assembles both assemblies)

## File Layout

No files are moved — they stay in their current directories. Each target references its source path:

- `Generic` → `Chronik/Sources/Generic/`
- `Entries` → `Chronik/Sources/Features/Entries/`
- `Chronik` → `Chronik/Sources/App/`
