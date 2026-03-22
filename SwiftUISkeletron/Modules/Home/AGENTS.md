# Home Module — Agent Guide

Reference example of a fully-featured module with navigation, sheets, events, and repository pattern.

## File Layout

| File | Purpose |
|---|---|
| `HomeRouter.swift` | HomeRoute, HomeSheet, HomeRouter typealias |
| `HomeList/HomeListView.swift` | List screen with NavigationStack, pull-to-refresh |
| `HomeList/HomeListViewModel.swift` | Fetches data via HomeRepository, observes store |
| `HomeList/HomeListViewModelProtocol.swift` | Protocol abstraction |
| `HomeDetails/HomeDetailsView.swift` | Detail screen |
| `HomeDetails/HomeDetailsViewModel.swift` | Fetches detail, emits events (showSheet) |
| `HomeDetails/HomeDetailsViewModelProtocol.swift` | Protocol abstraction |

## Navigation Flow

```
HomeListView (root)
  ├─ push → HomeDetailsView (via HomeRoute.details)
  └─ sheet → HomeDetailsSheetView (via HomeSheet.detailsSheet)
```

## Event Handling

`HomeDetailsViewModel` emits `.showSheet` → `HomeListView.handleHomeDetailsEvents()` presents the sheet via router.

## Data Flow

`HomeListViewModel` → `HomeRepository` → Network (fetch) + Store (persist/observe)

- `startObserving()` — subscribes to Store's AsyncStream for reactive updates
- `fetchData()` — calls `repository.refresh()` which fetches from API and saves to CoreData

## Known Stubs

`HomeNetworkService.fetchHomeListData()` and `fetchHomeDetailData()` currently return hardcoded data. Replace with actual API calls by uncommenting the `networkService.fetchRequest(...)` line.
