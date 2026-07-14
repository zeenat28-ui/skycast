# SkyCast Pro - Architecture Documentation

## Overview

SkyCast Pro follows **Feature-First Clean Architecture** with clear separation of concerns across presentation, application, domain, and data layers.

## Architecture Layers

### 1. Presentation Layer (`features/weather/presentation/`)

Responsible for UI rendering and user interaction.

**Components:**
- **Pages**: Full screen widgets (HomePage, ForecastPage, SearchPage, etc.)
- **Widgets**: Reusable UI components with no business logic
- **Providers**: Riverpod providers that watch data changes

**Key Principle**: Widgets must never contain business logic. All logic belongs in providers.

```dart
// Example: HomePage watches weather provider
final state = ref.watch(weatherNotifierProvider);
```

### 2. Application Layer (`features/weather/application/`)

Manages state and business logic using Riverpod StateNotifiers.

**Components:**
- **Notifiers**: StateNotifier classes handling state updates
- **State Classes**: Immutable state representations
- **Providers**: Riverpod provider definitions

**Data Flow:**
```
WeatherNotifier → WeatherState → Presentation Layer
↓
Uses WeatherRepository
```

### 3. Domain Layer (`features/weather/domain/`)

Contains pure business logic and domain models.

**Components:**
- **Models**: Immutable domain objects
- **Repositories**: Abstract repository interfaces
- **Use Cases**: Business logic (optional, use Notifiers instead)

**Key Principle**: No external dependencies. Pure Dart code.

### 4. Data Layer (`features/weather/data/`)

Handles all data source operations.

**Components:**
- **Data Sources**:
  - Remote: OpenWeatherMap API
  - Local: SharedPreferences caching
- **Repositories**: Concrete implementations of domain repositories
- **Models**: API response models (mapped to domain models)

**Flow:**
```
Remote Data Source (Dio)
        ↓
   Repository (implements caching logic)
        ↓
   Domain Repository (interface)
        ↓
   Application Layer
```

## Core Layer (`core/`)

### Configuration (`core/config/`)
App-wide settings and constants.

### Infrastructure (`core/infrastructure/`)
- **ApiClient**: Reusable HTTP client with timeout, retry, logging
- **LoggerService**: Centralized logging

### Presentation (`core/presentation/`)
- **Providers**: Global providers (connectivity, settings, theme)
- **Widgets**: Shared widgets (OfflineBanner)

### Services (`core/services/`)
- **LocationService**: Geolocation and geocoding
- **StorageService**: SharedPreferences wrapper

### Styles (`core/styles/`)
- **AppTheme**: Material 3 theme definitions

### DI (`core/di/`)
- **Providers**: All dependency injection definitions
- **Injection**: DI initialization

## Dependency Injection Pattern

All dependencies injected via Riverpod providers:

```dart
// API Client Provider
final apiClientProvider = Provider<AppApiClient>(
  (ref) => AppApiClient()
);

// Weather Repository Provider
final weatherRepositoryProvider = Provider<WeatherRepository>(
  (ref) => WeatherRepositoryImpl(
    ref.read(weatherRemoteDataSourceProvider),
    ref.read(weatherLocalDataSourceProvider),
  ),
);

// Weather State Provider
final weatherNotifierProvider = StateNotifierProvider<WeatherNotifier, WeatherState>(
  (ref) {
    final repository = ref.read(weatherRepositoryProvider);
    return WeatherNotifier(repository);
  },
);
```

## State Management with Riverpod

### Provider Types Used

1. **StateNotifierProvider**: Mutable state (weather, settings)
```dart
final weatherNotifierProvider = StateNotifierProvider<WeatherNotifier, WeatherState>(...);
```

2. **Provider**: Immutable state (api client, services)
```dart
final apiClientProvider = Provider<AppApiClient>(...);
```

3. **FutureProvider**: Async operations
```dart
// Not used currently, using StateNotifier instead
```

## Error Handling Strategy

### Network Errors
```
API Failure → Repository → Notifier → State (failure status)
                ↓
            Retry or Cached Data
```

### Local Errors
```
Permission Denied → Location Service → Notifier → Show Dialog
GPS Disabled → Show Settings Button
```

### User-Friendly Messages
All errors mapped to readable messages:
```dart
"Unable to fetch weather" → User sees friendly error with retry button
```

## Caching Strategy

### Two-Tier Caching

1. **In-Memory**: Riverpod providers (fast, lost on app restart)
2. **Persistent**: SharedPreferences (survives restart)

### Cache Flow
```
Network Request
    ↓
Success → Cache to SharedPreferences
    ↓
Failure → Load from SharedPreferences
    ↓
No Cache → Show Error
```

## Offline Support

### Implementation
1. **Connectivity Provider**: Monitors online/offline status
2. **Offline Banner**: Visual indicator when offline
3. **Cached Data**: Displayed from SharedPreferences
4. **Retry Logic**: Auto-retry when connection restored

## Testing Strategy

### Unit Tests
- Repository tests (mock data sources)
- Notifier tests (state transitions)
- Service tests (location, storage)

### Widget Tests
- Page rendering
- User interactions
- Navigation

### Critical Paths
- Weather loading and caching
- Location permission handling
- Offline to online transition

## Performance Optimizations

1. **Const Constructors**: All widgets use const where possible
2. **Lazy Loading**: Lists build items on demand
3. **Image Caching**: cached_network_image with cache manager
4. **Efficient Rebuilds**: Riverpod selectors prevent unnecessary rebuilds
5. **Memory Management**: Proper cleanup in dispose methods

## Best Practices Followed

1. **SOLID Principles**
   - Single Responsibility: Each class has one reason to change
   - Open/Closed: Open for extension, closed for modification
   - Liskov Substitution: Repositories can be swapped
   - Interface Segregation: Minimal interfaces
   - Dependency Inversion: Depend on abstractions

2. **DRY (Don't Repeat Yourself)**
   - Shared widgets in core/presentation
   - Common formatting utilities
   - Reusable API client

3. **KISS (Keep It Simple, Stupid)**
   - Simple widget composition
   - Clear naming conventions
   - Minimal abstraction layers

4. **Effective Dart**
   - Null safety throughout
   - Proper type annotations
   - Immutable models

## Folder Structure Rationale

```
features/weather/
├── data/              # API calls and caching
├── domain/            # Pure models and interfaces
├── application/       # State management with Riverpod
└── presentation/      # UI screens and widgets
```

**Why Feature-First?**
- Easy to scale with new features
- Clear ownership boundaries
- Self-contained feature modules
- Easier testing and mocking

## Adding New Features

1. Create new feature folder: `features/newfeature/`
2. Create sub-folders: `data/`, `domain/`, `application/`, `presentation/`
3. Define domain models first
4. Implement data sources
5. Implement repository
6. Create notifier and state
7. Build UI screens
8. Add tests

## Future Architecture Considerations

- **Feature Flags**: For A/B testing and gradual rollouts
- **Modularization**: Separate feature packages
- **BLoC Pattern**: Alternative to StateNotifier
- **Code Generation**: More freezed models
- **GraphQL**: Alternative to REST API

---

**Version**: 1.0.0  
**Last Updated**: July 2026
