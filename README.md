# 🌤️ SkyCast Pro

A beautifully designed, premium, and hyper-fast weather application built with Flutter.

SkyCast Pro offers real-time weather tracking, 5-day forecasts, and an ultra-smooth Cache-First architecture that guarantees zero-wait loading times. The app leverages the OpenWeatherMap API and is built entirely following Clean Architecture principles for maximum scalability and maintainability.

---

## ✨ Features

- **Pro-Level Smoothness**: Implements a highly optimized cache-first architecture. The UI renders instantly on launch using locally cached data while seamlessly fetching fresh data in the background.
- **Live Weather Data**: Real-time current weather metrics including Temperature, "Feels Like", Humidity, Wind Speed, Pressure, Visibility, and UV Index.
- **5-Day Forecast**: Accurate, visually pleasing 5-day weather predictions directly integrated into the dashboard.
- **Global Search Engine**: Direct integration with OpenWeather's Geocoding API to search and view the weather for any city worldwide instantly.
- **Offline Resiliency**: Handles lost connections gracefully with beautiful UI fallbacks instead of endless loading screens or crashes.
- **Clean Architecture**: Separates concerns across Domain, Data, and Presentation layers, making the codebase testable and enterprise-ready.

---

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) (Cross-platform UI)
- **State Management**: [Riverpod](https://riverpod.dev/) (Reactive caching and state binding)
- **Network & API**: [Dio](https://pub.dev/packages/dio) & [OpenWeatherMap API](https://openweathermap.org/api)
- **Local Storage**: `shared_preferences` (For ultra-fast startup caching)
- **Device Location**: `geolocator` (For precise local weather tracking)

---

## 🚀 Getting Started

Follow these instructions to get a copy of the project up and running on your local machine for development and testing.

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / Xcode
- An active API key from [OpenWeatherMap](https://openweathermap.org/)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/skycast-pro.git
   cd skycast-pro
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Environment Variables**
   Create a `.env` file in the root directory of your project based on the `.env.example` file.
   ```bash
   cp .env.example .env
   ```
   Open the `.env` file and paste your OpenWeather API key:
   ```env
   OPENWEATHER_API_KEY=your_real_api_key_here
   ```
   *(Note: The `.env` file is excluded from Git to keep your API key secure.)*

4. **Run the App**
   Connect your physical device or start an emulator, then run:
   ```bash
   flutter run
   ```

---

## 🏗️ Architecture Overview

The app is strictly structured using **Clean Architecture**:

- **`domain/`**: Contains the core business logic, including `WeatherModel`, `ForecastModel`, and abstract `Repositories`. It has zero dependency on Flutter or external libraries.
- **`data/`**: Implements the repositories. It manages data fetching via `WeatherRemoteDataSource` (Dio) and caching via `WeatherLocalDataSource` (SharedPreferences).
- **`application/`**: Contains the Riverpod `StateNotifiers` that act as the bridge between the UI and the data layer. It handles complex logic like the *Cache-First* loading sequence.
- **`presentation/`**: Contains all UI components (Widgets, Pages). The UI strictly observes the application layer and reacts to state changes instantly.

---

## 🛡️ Testing

The project includes an extensive automated test suite covering all major architectural layers to ensure zero null-pointer exceptions and a flawless user experience.

To run the automated test suite:
```bash
flutter test
```

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.
