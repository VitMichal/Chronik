# Chronik

**Chronik** is an iOS personal work task tracker

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

See `AGENTS.md` for the full architecture, conventions, and build/test workflow.
