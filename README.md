# Chronik

**Chronik** is an iOS accommodation browsing app (Airbnb-like) — a SwiftUI
template project demonstrating a layered MVVM architecture with a protocol-based
service layer, code-driven navigation, and Supabase as the backend.

## Getting started

1. Clone this repository
2. Open `Chronik.xcodeproj` in _Xcode_ 15+
3. Set up your own [Supabase](https://supabase.com/) project and configure the
   connection in `Chronik/Sources/Services/`
4. Build and run on an iOS 17+ Simulator

> **Note:** The project uses [XcodeGen](https://github.com/yonaskolb/XcodeGen) for
> project generation. The `.xcodeproj` is checked in, so you don't need XcodeGen
> to get started. If you regenerate the project, install it via
> `brew install xcodegen` and run `xcodegen generate` from the repo root.

## Project structure

```text
Chronik/
├── Sources/
│   ├── App/            # App entry point
│   ├── Views/          # SwiftUI views
│   ├── ViewModels/     # View models / presentation logic
│   ├── Models/         # Data models
│   ├── Services/       # Networking, data access
│   └── Extensions/     # Swift extensions
├── Resources/          # Assets, colors
└── Tests/              # Unit tests
```

## Dependencies

- [supabase-swift](https://github.com/supabase/supabase-swift) — Supabase client
- `Range-Slider` — added directly in the `.xcodeproj`

See `AGENTS.md` for the full architecture, conventions, and build/test workflow.
