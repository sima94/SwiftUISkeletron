# CLAUDE.md — SwiftUISkeletron

## Quick Reference

```
make build           # Build Prod scheme (iPhone 17 Pro simulator)
make test            # Run all tests (SwiftUISkeletronTests)
make test-ui         # Run UI tests, auto-extract failure screenshots
make test-ui-record  # Run UI tests with video recording
make clean           # Remove DerivedData
make resolve         # Verify local packages (no-op, all local)
make format          # SwiftFormat (requires: brew install swiftformat)
make lint            # SwiftLint (requires: brew install swiftlint)
```

**ALWAYS use `make` commands. Do NOT call `xcodebuild`, `swift build`, or `tuist` directly.**

## Architecture

MVVM + Repository pattern with custom DI.

| Layer | Purpose | Key Type |
|---|---|---|
| View | SwiftUI screens | `struct XView: View` |
| ViewModel | Business logic, state | `@Observable @MainActor final class` |
| ViewModel Protocol | Abstraction for previews/tests | `protocol XViewModelProtocol` |
| Repository | Orchestrates Network + Store | `final class XRepository` |
| Network Service | API calls via NetworkRelay | `final class XNetworkService` |
| Store Service | CoreData persistence | `StoreService<Model: Storable>` |
| DI | Infuse framework | `@Dependency(XKey.self)` |
| Navigation | Generic Router per module | `Router<Route, Sheet>` |

## Project Structure

| Directory | Purpose |
|---|---|
| `SwiftUISkeletron/AppFactory/` | App initialization, environment config |
| `SwiftUISkeletron/Authentication/` | LoginManager, UserSession, OAuthToken |
| `SwiftUISkeletron/CoreData/` | CoreData stack, generic StoreService, Storable protocol |
| `SwiftUISkeletron/DataLayer/` | Repository pattern: Network + Store + Repository per domain |
| `SwiftUISkeletron/Dependencies/` | DependencyKey definitions (URLSession, Endpoint, NetworkService) |
| `SwiftUISkeletron/Extensions/` | Swift extensions (Data, ProcessInfo, Bundle) |
| `SwiftUISkeletron/FormValidator/` | Form validation with @FormField property wrapper |
| `SwiftUISkeletron/Modules/` | Feature modules (AppTabView, Authentication, Home, Profile, Search) |
| `SwiftUISkeletron/Navigation/` | Generic Router<Route, Sheet>, AlertState |
| `SwiftUISkeletron/PropertyWrappers/` | @Keychain, @UserDefault property wrappers |
| `SwiftUISkeletron/ViewModifiers/` | Reusable view modifiers (LoadingOverlay) |
| `SwiftUISkeletron/DesignSystem/` | Design tokens: Spacing, AppColor, Radius |
| `Infuse/` | Custom DI framework (local SPM package) |
| `NetworkRelay/` | Custom networking library (local SPM package) |

## Conventions

### ViewModels
- Always `@Observable @MainActor final class`
- Dependencies via `@ObservationIgnored @Dependency(XKey.self) var service`
- Expose protocol: `protocol XViewModelProtocol` — Views consume the protocol

### Views
- `@State var viewModel: XViewModelProtocol` (protocol-typed)
- `@State private var router = XRouter()`
- NavigationStack bound to `$router.path`
- Routes handled in `.navigationDestination(for: XRoute.self)`
- Sheets handled in `.sheet(item: $router.sheet)`
- Alerts via `.routerAlert($router.alert)`

### Navigation (Router Pattern)
- Each module defines: `enum XRoute: Hashable`, `enum XSheet: Identifiable` (or `Never`)
- `typealias XRouter = Router<XRoute, XSheet>`
- Router provides: `navigate(to:)`, `pop()`, `popToRoot()`, `present(_:)`, `showAlert(_:)`

### Event Stream (Child-to-Parent Communication)
- ViewModel defines `enum Event` and exposes `let events: AsyncStream<Event>`
- Parent View handles events: `.task { await handleXEvents(vm) }`
- Pattern: `for await event in viewModel.events { switch event { ... } }`

### Dependency Injection (Infuse)
- `struct XKey: DependencyKey` with `liveValue` and `testValue`
- DependencyKey + Mock live in same file as implementation
- Resolve: `@Dependency(XKey.self) var service`
- Flow scoping: `DependencyValues.shared.endFlow(.flowName)` to clean up

### DataLayer (Repository Pattern)
- Structure: `DataLayer/DomainName/{Network/, Store/, Repository/}`
- Network: `XNetworkService` conforms to protocol, uses `HTTPFetchRequest` from NetworkRelay
- Store: `XStoreService` uses `StoreService<Model: Storable>` for CoreData
- Repository: orchestrates Network + Store, exposes `observe()` and `refresh()`

### Testing
- **Swift Testing framework** (NOT XCTest) — use `import Testing`, `@Suite`, `@Test`, `#expect`
- Test plan: `SwiftUISkeletron.xctestplan`
- DependencyKey provides `testValue` for automatic mock injection in tests
- **UI Tests** use XCUITest (separate scheme: "SwiftUISkeletron UITests")
- Run UI tests only at end of feature development (`make test-ui`)
- Snapshot tests use swift-snapshot-testing with two sizes: `.iPhoneSe` and `.iPhone13ProMax`

### Style
- **Tabs** for indentation (not spaces)
- `// MARK: -` sections for code organization
- SwiftyBeaver logging via global `log` constant

## Build System

- Xcode project-based (no SPM Package.swift at root, no Tuist)
- Three schemes: "SwiftUISkeletron Prod", "SwiftUISkeletron Test", "SwiftUISkeletron UITests"
- Configs: `SupportingFiles/Configs/Prod.xcconfig`, `Test.xcconfig`
- Local packages: `Infuse/`, `NetworkRelay/`, `FormValidator/`
- iOS 18.2+, Swift 6.0+

## Adding a New Feature Module

1. Create directory: `Modules/ModuleName/FeatureName/`
2. Define routes: `ModuleNameRouter.swift` — `enum ModuleNameRoute: Hashable`, `enum ModuleNameSheet: Identifiable`, `typealias ModuleNameRouter = Router<ModuleNameRoute, ModuleNameSheet>`
3. Create protocol: `FeatureNameViewModelProtocol.swift`
4. Create ViewModel: `FeatureNameViewModel.swift` — `@Observable @MainActor final class`, declare `@Dependency` properties
5. Create View: `FeatureNameView.swift` — `@State var viewModel: FeatureNameViewModelProtocol`, `@State private var router`
6. If child VM emits events: add `enum Event`, `AsyncStream<Event>`, handle in parent via `.task { await handleEvents(vm) }`
7. Wire into parent (e.g., add tab in `AppTabView.swift` or route in parent module)
8. Add `#Preview` with mock ViewModel
9. Run `make build && make test`

## Adding a New DataLayer Service

1. Create protocol: `DataLayer/DomainName/Network/DomainNameServiceProtocol.swift`
2. Create implementation + DependencyKey + Mock in: `DataLayer/DomainName/Network/DomainNameService.swift`
3. Create request types: `DataLayer/DomainName/Network/Requests/XRequest.swift` conforming to `HTTPFetchRequest`
4. Create models: `DataLayer/DomainName/Network/Models/XData.swift`
5. (Optional) Create Store: `DataLayer/DomainName/Store/DomainNameStoreService.swift` with `Storable` model
6. (Optional) Create Repository: `DataLayer/DomainName/Repository/DomainNameRepository.swift` orchestrating Network + Store
7. Register DependencyKey in the service file (same file pattern)
8. Add tests in `SwiftUISkeletronTests/`
9. Run `make build && make test`

## Troubleshooting

| Symptom | Fix |
|---|---|
| Missing Infuse or NetworkRelay | Ensure local package directories exist at project root |
| DerivedData issues / stale build | `make clean && make build` |
| Test DI failures (wrong context) | Ensure `DependencyContext` auto-detects `.test` in test targets |
| Module not found in imports | Check target membership in Xcode project |
| Merge conflicts in .pbxproj | Prefer `make clean` then rebuild; resolve manually if needed |

## Design Tokens

Use tokens from `DesignSystem/Tokens.swift` instead of raw values:
- `Spacing.md` not `.padding(16)` — `AppColor.primaryAction` not `Color.blue` — `Radius.md` not `.cornerRadius(12)`

## Documentation Maintenance

When you discover that this CLAUDE.md or any AGENTS.md is inaccurate or missing information that caused confusion or a failed attempt, update the relevant documentation. Every change should leave the document shorter or more useful, ideally both.
