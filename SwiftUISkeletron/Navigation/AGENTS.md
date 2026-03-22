# Navigation — Agent Guide

## Router<Route, Sheet>

Generic navigation container at `Router.swift`. Each module creates a typealias:

```swift
typealias HomeRouter = Router<HomeRoute, HomeSheet>
```

### API

| Method | Purpose |
|---|---|
| `navigate(to: Route)` | Push onto NavigationPath |
| `pop()` | Pop one screen |
| `popToRoot()` | Reset to root |
| `present(_ sheet: Sheet)` | Show as sheet |
| `presentFullScreen(_ cover: Sheet)` | Show as full-screen cover |
| `showAlert(_ alert: AlertState)` | Display alert |
| `dismiss()` | Dismiss sheet/cover |
| `dismissAlert()` | Dismiss alert |

### Constraints

- `Route` must be `Hashable`
- `Sheet` must be `Identifiable`
- If no sheets needed, use `Never` (requires `extension Never: Identifiable`)

## AlertState

Defined in `AlertState.swift`. Supports primary + optional secondary buttons with roles:

```swift
router.showAlert(AlertState(
    title: "Title",
    message: "Message",
    primaryButton: .default("OK"),
    secondaryButton: .cancel()
))
```

Button types: `.default(_:action:)`, `.cancel(_:)`, `.destructive(_:action:)`

## View Wiring

```swift
NavigationStack(path: $router.path) {
    // root content
    .navigationDestination(for: XRoute.self) { route in ... }
    .routerAlert($router.alert)
    .sheet(item: $router.sheet) { sheet in ... }
    .fullScreenCover(item: $router.fullScreenCover) { cover in ... }
}
```

The `.routerAlert(_:onAction:)` modifier handles alert presentation and optional action callbacks.
