# Entries Feature as Separate Target — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Extract the Entries feature and Generic shared code into separate framework targets in the Xcode project.

**Architecture:** Two new framework targets (`Generic`, `Entries`) are defined in `project.yml`. The `Chronik` app depends on both. Access control is updated so framework types are `public`.

**Tech Stack:** Swift 5.9, SwiftUI, XcodeGen, Swinject

## Global Constraints

- Swift 5.9+, iOS 17.0+ deployment target
- XcodeGen 2.38+ for project generation
- No files are moved — sources stay in current directories
- Follow existing patterns in `project.yml`

---

## Task 1: Update `project.yml` — Add Generic and Entries framework targets

**Files:**
- Modify: `project.yml`

**Interfaces:**
- Produces: `Generic` and `Entries` framework targets in `project.yml`

- [ ] **Step 1: Add Generic framework target**

Add after the `ChronikTests` target in `project.yml`:

```yaml
  Generic:
    type: framework
    platform: iOS
    sources:
      - path: Chronik/Sources/Generic
    settings:
      base:
        SWIFT_VERSION: "5.9"
        GENERATE_INFOPLIST_FILE: true
        PRODUCT_BUNDLE_IDENTIFIER: com.example.Generic
        DEFINES_MODULE: YES
```

- [ ] **Step 2: Add Entries framework target**

Add after the `Generic` target in `project.yml`:

```yaml
  Entries:
    type: framework
    platform: iOS
    sources:
      - path: Chronik/Sources/Features/Entries
      - path: Chronik/Sources/Features/Entries/DI
    dependencies:
      - target: Generic
      - package: Swinject
    settings:
      base:
        SWIFT_VERSION: "5.9"
        GENERATE_INFOPLIST_FILE: true
        PRODUCT_BUNDLE_IDENTIFIER: com.example.Entries
        DEFINES_MODULE: YES
```

- [ ] **Step 3: Update Chronik app target sources and dependencies**

Replace the `Chronik` target's `sources` and `dependencies` with:

```yaml
  Chronik:
    type: application
    platform: iOS
    sources:
      - path: Chronik/Sources/App
      - path: Chronik/Resources
    resources:
      - path: Chronik/Resources
    dependencies:
      - target: Generic
      - target: Entries
      - package: Swinject
    settings:
      base:
        SWIFT_VERSION: "5.9"
        INFOPLIST_KEY_UIApplicationSceneManifest_Generation: true
        INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents: true
        INFOPLIST_KEY_UILaunchScreen_Generation: true
        INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone: "UIInterfaceOrientationPortrait"
        GENERATE_INFOPLIST_FILE: true
        CURRENT_PROJECT_VERSION: 1
        MARKETING_VERSION: "1.0"
        PRODUCT_BUNDLE_IDENTIFIER: com.example.Chronik
```

- [ ] **Step 4: Update ChronikTests dependencies**

Replace the `ChronikTests` dependencies with:

```yaml
  ChronikTests:
    type: bundle.unit-test
    platform: iOS
    sources:
      - path: Chronik/Tests
    settings:
      base:
        SWIFT_VERSION: "5.9"
        GENERATE_INFOPLIST_FILE: true
    dependencies:
      - target: Chronik
      - target: Generic
      - target: Entries
```

- [ ] **Step 5: Verify final project.yml**

Run: `cat project.yml`
Expected: All four targets present (Chronik, ChronikTests, Generic, Entries) with correct dependencies.

- [ ] **Step 6: Commit**

```bash
git add project.yml
git commit -m "feat: add Generic and Entries framework targets to project.yml"
```

---

## Task 2: Add `public` access control to Entries types

**Files:**
- Modify: `Chronik/Sources/Features/Entries/Presentation/EntryScreen.swift`
- Modify: `Chronik/Sources/Features/Entries/Presentation/EntriesViewModel.swift`
- Modify: `Chronik/Sources/Features/Entries/Presentation/EntryFormViewModel.swift`
- Modify: `Chronik/Sources/Features/Entries/DI/EntriesAssembly.swift`

**Interfaces:**
- Produces: `public` access on all types that the Chronik app needs from the Entries framework

- [ ] **Step 1: Make `EntryScreen` public**

In `Chronik/Sources/Features/Entries/Presentation/EntryScreen.swift`, change:

```swift
enum EntryScreen: Hashable {
```

to:

```swift
public enum EntryScreen: Hashable {
```

- [ ] **Step 2: Make EntriesViewModel types public**

In `Chronik/Sources/Features/Entries/Presentation/EntriesViewModel.swift`, change:

```swift
struct EntryRow: Identifiable, Equatable {
```

to:

```swift
public struct EntryRow: Identifiable, Equatable {
```

And change:

```swift
struct DaySection: Identifiable, Equatable {
```

to:

```swift
public struct DaySection: Identifiable, Equatable {
```

And change:

```swift
@MainActor
protocol EntriesViewModel: LoadableCollectionViewModel where State == DaySection {
```

to:

```swift
@MainActor
public protocol EntriesViewModel: LoadableCollectionViewModel where State == DaySection {
```

And change:

```swift
@MainActor
@Observable
final class EntriesViewModelImpl: LoadableCollectionViewModelImpl<DaySection>, EntriesViewModel {
```

to:

```swift
@MainActor
@Observable
public final class EntriesViewModelImpl: LoadableCollectionViewModelImpl<DaySection>, EntriesViewModel {
```

- [ ] **Step 3: Make EntryFormViewModel types public**

In `Chronik/Sources/Features/Entries/Presentation/EntryFormViewModel.swift`, change:

```swift
struct EntryFormState {
```

to:

```swift
public struct EntryFormState {
```

And change:

```swift
@MainActor
protocol EntryFormViewModel {
```

to:

```swift
@MainActor
public protocol EntryFormViewModel {
```

And change:

```swift
@MainActor
@Observable
final class EntryFormViewModelImpl: EntryFormViewModel {
```

to:

```swift
@MainActor
@Observable
public final class EntryFormViewModelImpl: EntryFormViewModel {
```

- [ ] **Step 4: Make EntriesAssembly public**

In `Chronik/Sources/Features/Entries/DI/EntriesAssembly.swift`, change:

```swift
final class EntriesAssembly: Assembly {
```

to:

```swift
public final class EntriesAssembly: Assembly {
```

- [ ] **Step 5: Commit**

```bash
git add Chronik/Sources/Features/Entries/
git commit -m "feat: add public access control to Entries framework types"
```

---

## Task 3: Regenerate project and verify build

**Files:**
- Regenerated: `Chronik.xcodeproj`

**Interfaces:**
- Produces: Working Xcode project with all targets

- [ ] **Step 1: Regenerate the Xcode project**

Run: `xcodegen generate`
Expected: "Generating Chronik.xcodeproj" with no errors.

- [ ] **Step 2: Verify Generic target compiles**

Run: `xcodebuild build -project Chronik.xcodeproj -scheme Generic -destination 'platform=iOS Simulator,name=iPhone 16'`
Expected: BUILD SUCCEEDED

- [ ] **Step 3: Verify Entries target compiles**

Run: `xcodebuild build -project Chronik.xcodeproj -scheme Entries -destination 'platform=iOS Simulator,name=iPhone 16'`
Expected: BUILD SUCCEEDED

- [ ] **Step 4: Verify Chronik app compiles**

Run: `xcodebuild build -project Chronik.xcodeproj -scheme Chronik -destination 'platform=iOS Simulator,name=iPhone 16'`
Expected: BUILD SUCCEEDED

- [ ] **Step 5: Verify tests compile**

Run: `xcodebuild build-for-testing -project Chronik.xcodeproj -scheme ChronikTests -destination 'platform=iOS Simulator,name=iPhone 16'`
Expected: BUILD SUCCEEDED

- [ ] **Step 6: Run tests**

Run: `xcodebuild test -project Chronik.xcodeproj -scheme ChronikTests -destination 'platform=iOS Simulator,name=iPhone 16'`
Expected: All tests pass

- [ ] **Step 7: Commit regenerated project**

```bash
git add Chronik.xcodeproj
git commit -m "chore: regenerate project with new framework targets"
```
