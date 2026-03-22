# Modules — Agent Guide

## Directory Convention

Each feature module follows this structure:

```
Modules/
  ModuleName/
    ModuleNameRouter.swift        # Route enum, Sheet enum, Router typealias
    FeatureName/
      FeatureNameView.swift           # SwiftUI View
      FeatureNameViewModel.swift      # @Observable ViewModel + DependencyKey (if needed)
      FeatureNameViewModelProtocol.swift  # Protocol for testability/previews
```

## Router Pattern

Every module that uses navigation defines its own router:

```swift
// HomeRouter.swift
enum HomeRoute: Hashable {
    case details(HomeListData)
}

enum HomeSheet: Identifiable {
    case detailsSheet
    var id: Int { ... }
}

typealias HomeRouter = Router<HomeRoute, HomeSheet>
```

- If a module has no sheets, use `Never` as Sheet type (or omit sheets entirely)
- Route must conform to `Hashable`
- Sheet must conform to `Identifiable`

## ViewModel Pattern

```swift
@MainActor
@Observable
final class FeatureViewModel: FeatureViewModelProtocol {
    // State
    var isLoading = false

    // Dependencies (always @ObservationIgnored)
    @ObservationIgnored
    @Dependency(ServiceKey.self) var service

    // Actions
    func fetchData() async { ... }
}
```

## View Pattern

```swift
struct FeatureView: View {
    @State var viewModel: FeatureViewModelProtocol  // protocol-typed
    @State private var router = FeatureRouter()

    var body: some View {
        NavigationStack(path: $router.path) {
            // content
            .navigationDestination(for: FeatureRoute.self) { route in ... }
            .routerAlert($router.alert)
            .sheet(item: $router.sheet) { sheet in ... }
        }
    }
}
```

## Event Stream (Child-to-Parent Communication)

When a child ViewModel needs to signal the parent View:

1. ViewModel declares `enum Event` and exposes `let events: AsyncStream<Event>`
2. ViewModel yields events: `eventContinuation.yield(.someEvent)`
3. Parent View handles: `.task { await handleChildEvents(vm) }`

```swift
// In parent View:
private func handleChildEvents(_ viewModel: ChildViewModel) async {
    for await event in viewModel.events {
        switch event {
        case .completed: router.pop()
        case .showNext: router.navigate(to: .next)
        }
    }
}
```

## Adding a New Tab

1. Create the module (View, ViewModel, Protocol, Router)
2. In `AppTabView.swift`, add a new tab inside the `TabView`:

```swift
NewFeatureView(viewModel: NewFeatureViewModel())
    .tabItem {
        Label("Label", systemImage: "icon.name")
    }
```

3. For conditional tabs (login-gated), wrap in `if viewModel.isLoggedIn { ... }`

## Previews

Every View should include `#Preview` blocks with a mock ViewModel class defined at the bottom of the View file:

```swift
#Preview {
    FeatureView(viewModel: FeatureViewModelMock(isLoading: false, data: []))
}

class FeatureViewModelMock: FeatureViewModelProtocol { ... }
```
