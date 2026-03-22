# DataLayer — Agent Guide

## Structure

Each domain in the DataLayer follows a three-layer pattern:

```
DataLayer/
  DomainName/
    Network/
      DomainNameServiceProtocol.swift   # Protocol
      DomainNameService.swift           # Impl + DependencyKey + Mock
      Models/                           # Response/entity models
      Requests/                         # HTTPFetchRequest conformances
    Store/
      DomainNameStoreServiceProtocol.swift
      DomainNameStoreService.swift      # CoreData persistence + DependencyKey + Mock
    Repository/
      DomainNameRepositoryProtocol.swift
      DomainNameRepository.swift        # Orchestrator + DependencyKey + Mock
```

Not every domain needs all three layers. Simple API-only domains can skip Store and Repository.

## DependencyKey Convention

DependencyKey, implementation, and mock live in the **same file**:

```swift
// HomeNetworkService.swift

struct HomeNetworkServiceKey: DependencyKey {
    static var liveValue: any HomeNetworkServiceProtocol {
        @Dependency(NetworkServiceKey.self) var network
        return HomeNetworkService(networkService: network)
    }
    static var testValue: any HomeNetworkServiceProtocol {
        MockHomeNetworkService()
    }
}

final class HomeNetworkService: HomeNetworkServiceProtocol, Sendable { ... }

final class MockHomeNetworkService: HomeNetworkServiceProtocol, Sendable { ... }
```

## Repository Pattern

Repositories orchestrate Network + Store:
- `observe()` — returns `AsyncStream` from Store for reactive UI updates
- `refresh()` — fetches from Network, persists to Store
- `getDetail(id:)` — direct network fetch when no caching needed

## Network Requests

Request types conform to `HTTPFetchRequest` from NetworkRelay:

```swift
struct HomeFetchRequest: HTTPFetchRequest {
    typealias Object = [HomeListData]
    var path: String { "/api/home" }
    var method: HTTPMethod { .get }
}
```

## CoreData (Store Layer)

- Entity models conform to `Storable` protocol
- Use generic `StoreService<Model: Storable>` for CRUD
- Store exposes `observe()` → `AsyncStream` for reactive updates

## Adding a New Domain

1. Create `DataLayer/NewDomain/Network/NewDomainServiceProtocol.swift`
2. Create `DataLayer/NewDomain/Network/NewDomainService.swift` (impl + key + mock)
3. Create request types in `Network/Requests/`
4. Create models in `Network/Models/`
5. (If persistence needed) Create Store + Storable model
6. (If both Network + Store) Create Repository to orchestrate
7. Add tests in `SwiftUISkeletronTests/`
8. Run `make build && make test`
