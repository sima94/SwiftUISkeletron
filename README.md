# SwiftUISkeletron

A production-ready SwiftUI starter template for iOS apps. 100% SwiftUI, MVVM + Repository architecture, custom dependency injection, type-safe navigation, CoreData persistence, and comprehensive testing — all wired together and ready to build on.

**Swift 6.0+** · **iOS 18.2+** · **Xcode 16+** · **Zero UIKit**

## Features

- **MVVM + Repository** — Clean layer separation with protocol abstractions
- **Infuse** — Custom dependency injection framework with flow scoping
- **NetworkRelay** — Custom HTTP networking with adapters & retriers
- **FormValidator** — Local SPM package for declarative form validation
- **Generic Router** — Type-safe, per-module navigation (stack, sheets, alerts)
- **CoreData Persistence** — Generic `StoreService<Model>` with async streams
- **Authentication System** — Actor-based session, Keychain storage, token refresh
- **Design Tokens** — Spacing, Color, and Radius token system
- **Swift Testing** — Unit tests, snapshot tests, UI tests (Page Object Model)
- **Makefile CLI** — Build, test, lint, format — all via `make`
- **AI Agent Docs** — CLAUDE.md + AGENTS.md for AI-assisted development

## Architecture

MVVM + Repository pattern with custom DI and per-module routing.

```
┌─────────┐    ┌────────────┐    ┌──────────────┐    ┌─────────────────┐
│  View   │───▶│  ViewModel │───▶│  Repository  │───▶│ Network / Store │
│ SwiftUI │    │ @Observable │    │  Orchestrator│    │ API    CoreData │
└─────────┘    └────────────┘    └──────────────┘    └─────────────────┘
     │               │
     │          ┌────────────┐
     └─────────▶│   Router   │  (NavigationStack, Sheets, Alerts)
                └────────────┘
```

| Layer | Responsibility | Key Type |
|---|---|---|
| **View** | UI rendering | `struct XView: View` |
| **ViewModel** | Business logic, state | `@Observable @MainActor final class` |
| **ViewModel Protocol** | Abstraction for previews/tests | `protocol XViewModelProtocol` |
| **Repository** | Orchestrates Network + Store | `final class XRepository` |
| **Network Service** | API calls via NetworkRelay | `final class XNetworkService` |
| **Store Service** | CoreData persistence | `StoreService<Model: Storable>` |
| **DI** | Dependency resolution | `@Dependency(XKey.self)` |
| **Navigation** | Routing per module | `Router<Route, Sheet>` |

### Event Stream (Child → Parent)

ViewModels emit events via `AsyncStream` for parent coordination:

```swift
// ViewModel
enum Event { case loginSucceeded, showRegister }
let events: AsyncStream<Event>

// Parent View
.task { for await event in viewModel.events { ... } }
```

## Project Structure

```
SwiftUISkeletron/
├── AppFactory/              # App initialization, environment config, logging
├── Authentication/          # LoginManager, UserSession (actor), OAuthToken
├── CoreData/                # CoreDataStack, StoreService<Model>, Storable protocol
├── DataLayer/               # Repository pattern per domain
│   ├── Authentication/      #   Login/Register network services
│   └── Home/                #   Network + Store + Repository
│       ├── Network/         #     HomeNetworkService, models, requests
│       ├── Store/           #     HomeStoreService (CoreData)
│       └── Repository/      #     HomeRepository (orchestrator)
├── Dependencies/            # DependencyKey definitions (URLSession, Endpoint, etc.)
├── DesignSystem/            # Spacing, AppColor, Radius tokens
├── Extensions/              # Data, Bundle, ProcessInfo extensions
├── Modules/                 # Feature screens
│   ├── AppTabView/          #   Root tab container + login state observation
│   ├── Authentication/      #   Login + Register (views, viewmodels, router)
│   ├── Home/                #   HomeList + HomeDetails + HomeRouter
│   ├── Profile/             #   Profile + ProfileRouter
│   └── Search/              #   Search feature
├── Navigation/              # Router<Route, Sheet>, AlertState, routerAlert modifier
├── PropertyWrappers/        # @Keychain, @UserDefault
└── ViewModifiers/           # LoadingOverlay modifier

Infuse/                      # Local SPM package — Custom DI framework
NetworkRelay/                # Local SPM package — Custom HTTP networking
FormValidator/               # Local SPM package — Form validation

SwiftUISkeletronTests/       # Swift Testing suite
├── CoreData/                #   CoreDataStack + StoreService tests
├── Navigation/              #   Router + AlertState tests
└── Snapshots/               #   UI snapshot tests (iPhone SE + 13 Pro Max)

SwiftUISkeletronUITests/     # XCTest UI tests
├── App/                     #   SkeletronApp test harness
├── Screens/                 #   Page Object Model (Login, Home, Profile, etc.)
└── Tests/                   #   Feature tests (login, register, home, profile, tabs)
```

## Custom Frameworks

### Infuse — Dependency Injection

Lightweight DI framework (local SPM package). Type-safe, with scoped lifetimes.

```swift
// Define a dependency
struct AuthServiceKey: DependencyKey {
    static var scope: DependencyScope { .flow(.authentication) }
    static var liveValue: any AuthServiceProtocol { AuthenticationService() }
    static var testValue: any AuthServiceProtocol { MockAuthService() }
}

// Resolve in ViewModel
@ObservationIgnored @Dependency(AuthServiceKey.self) var authService
```

**Scopes:**
- `.singleton` — Single instance, lives for the entire app
- `.flow(FlowID)` — Scoped to a user flow, cleaned up via `DependencyValues.shared.endFlow()`
- `.transient` — New instance every time

**Testing:** `DependencyContext` auto-detects `.test` in test targets and resolves `testValue`.

### NetworkRelay — HTTP Networking

Custom networking library (local SPM package) with request abstraction, adapters, and retriers.

- `HTTPRequest` / `HTTPFetchRequest` — Protocol-based request definition
- `NetworkingService` — Executes requests, applies middleware pipeline
- `RequestAdapter` — Modifies outgoing requests (e.g., inject auth headers)
- `RequestRetrier` — Retries on failure (e.g., 401 → refresh token → retry)
- `Endpoint` — Base URL configuration per environment

### FormValidator — Form Validation

Local SPM package with `@FormField` property wrapper and declarative validation rules.

```swift
@FormField(rules: [.required(), .email()])
var email: String = ""

@FormField(rules: [.required(), .password()])
var password: String = ""
```

**Built-in rules:** `required()`, `minLength()`, `maxLength()`, `email()`, `password()`, `regex()`, `accepted()`, `match(field)`, `asyncCustom()`

**Error display modes:** `.first` (stop on first error) or `.all` (collect all errors).

## Navigation System

Generic `Router<Route, Sheet>` provides type-safe, per-module navigation:

```swift
// Define routes per module
enum HomeRoute: Hashable { case details(HomeListData) }
enum HomeSheet: Identifiable { case settings }
typealias HomeRouter = Router<HomeRoute, HomeSheet>

// Use in View
@State private var router = HomeRouter()

NavigationStack(path: $router.path) { ... }
    .navigationDestination(for: HomeRoute.self) { route in ... }
    .sheet(item: $router.sheet) { sheet in ... }
    .routerAlert($router.alert) { action in ... }
```

**Router API:** `navigate(to:)`, `pop()`, `popToRoot()`, `present(_:)`, `presentFullScreen(_:)`, `showAlert(_:)`, `dismiss()`

**AlertState** — Declarative alert model with `ButtonState` (default, cancel, destructive) and `AlertAction`.

## CoreData Persistence

Generic `StoreService<Model: Storable>` wraps all CoreData operations:

```swift
// Define a storable model
protocol Storable: Sendable {
    associatedtype Entity: NSManagedObject
    init(from entity: Entity)
    func configure(_ entity: Entity)
}

// Use StoreService
let store = StoreService<HomeListData>(coreData: stack)
let stream = store.observe()       // AsyncStream<[HomeListData]>
let items = try await store.fetchAll()
try await store.save(newItems)
try await store.deleteAll()
```

**CoreDataStack** manages the `NSPersistentContainer` with view + background contexts, auto-merge policies, and in-memory store support for tests.

## Authentication

- **UserSession** — `actor`-based token management with `@Keychain` secure storage and `AsyncStream` for token changes
- **LoginState** — `@Observable @MainActor` class that observes UserSession and exposes `isLoggedIn` for UI binding
- **TokenRetrier** — `RequestRetrier` that intercepts 401 responses and triggers token refresh
- **@Keychain** — Property wrapper for secure Keychain storage of `Codable` values

## Design Tokens

Centralized design values in `DesignSystem/Tokens.swift`:

| Token | Values |
|---|---|
| **Spacing** | `xxs(4)` `xs(8)` `sm(12)` `md(16)` `lg(24)` `xl(32)` `xxl(48)` |
| **AppColor** | `primaryAction` `destructiveAction` `secondaryAction` `background` `secondaryBackground` `overlay` `errorText` |
| **Radius** | `sm(8)` `md(12)` `lg(16)` |

```swift
.padding(Spacing.md)                    // not .padding(16)
.foregroundColor(AppColor.primaryAction) // not Color.blue
.cornerRadius(Radius.md)               // not .cornerRadius(12)
```

## Modules

| Module | Screens | Description |
|---|---|---|
| **AppTabView** | Tab container | Root view, observes login state, conditionally shows Search tab |
| **Authentication** | Login, Register | Form validation, event streams to parent, DI-scoped services |
| **Home** | HomeList, HomeDetails | Repository pattern (Network + Store), infinite scroll, detail fetch |
| **Profile** | Profile | User profile, login/register entry point when logged out |
| **Search** | SearchList | Search functionality, visible only when authenticated |

## Testing

### Unit Tests (Swift Testing)

Uses the modern `import Testing` framework with `@Suite`, `@Test`, `#expect`:

- **CoreData tests** — CoreDataStack, StoreService persistence, FetchedResultsPublisher
- **Navigation tests** — Router navigation, AlertState creation
- **Snapshot tests** — LoginView, HomeListView, LoadingOverlay on iPhone SE + 13 Pro Max

### UI Tests (XCTest)

Page Object Model pattern for readable, maintainable tests:

- **Screen objects** — `LoginScreen`, `RegisterScreen`, `HomeScreen`, `ProfileScreen`, `HomeDetailsScreen`
- **Test suites** — `LoginValidationTests`, `RegisterValidationTests`, `HomeListTests`, `ProfileTests`, `TabNavigationTests`

## CLI Commands

| Command | Description |
|---|---|
| `make build` | Build Prod scheme (iPhone 17 Pro simulator) |
| `make test` | Run all tests (SwiftUISkeletronTests) |
| `make test-coverage` | Run all tests (unit + UI + packages) with code coverage report |
| `make coverage-html` | Generate unified HTML coverage report → `coverage-html/index.html` |
| `make test-ui` | Run UI tests, auto-extract failure screenshots |
| `make test-ui-record` | Run UI tests with video recording + frame extraction |
| `make clean` | Remove DerivedData |
| `make resolve` | Verify local packages (no-op, all local) |
| `make format` | SwiftFormat (requires `brew install swiftformat`) |
| `make lint` | SwiftLint (requires `brew install swiftlint`) |
| `make open` | Open project in Xcode |

## Getting Started

```bash
# Clone
git clone https://github.com/sima94/SwiftUISkeletron.git
cd SwiftUISkeletron

# Build
make build

# Run tests
make test

# Open in Xcode
make open
```

## Requirements

- **Xcode 16+**
- **iOS 18.2+**
- **Swift 6.0+**

## Code Quality

- **SwiftFormat** — Tab indentation, 120 char max width, Swift 6.0
- **SwiftLint** — Opt-in rules (`closure_spacing`, `empty_count`, `toggle_bool`, `unused_import`), force cast = error

## AI Agent Support

This project includes documentation optimized for AI coding agents:

- `CLAUDE.md` — Root-level architecture guide, conventions, and step-by-step recipes
- `AGENTS.md` files in `DataLayer/`, `Modules/`, `Navigation/`, `DesignSystem/`, `Modules/Home/`
- `.claude/skills/` — Runbooks for common tasks (add feature, add service, etc.)
