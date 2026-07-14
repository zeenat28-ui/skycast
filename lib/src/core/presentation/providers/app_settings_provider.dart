import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../di/providers.dart';
import '../../services/storage_service.dart';

class AppSettingsState {
  const AppSettingsState({
    this.themeMode = ThemeMode.system,
    this.onboardingCompleted = false,
    this.temperatureUnit = '°C',
    this.windUnit = 'km/h',
    this.favorites = const <String>[],
    this.recentSearches = const <String>[],
  });

  final ThemeMode themeMode;
  final bool onboardingCompleted;
  final String temperatureUnit;
  final String windUnit;
  final List<String> favorites;
  final List<String> recentSearches;

  AppSettingsState copyWith({
    ThemeMode? themeMode,
    bool? onboardingCompleted,
    String? temperatureUnit,
    String? windUnit,
    List<String>? favorites,
    List<String>? recentSearches,
  }) {
    return AppSettingsState(
      themeMode: themeMode ?? this.themeMode,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      temperatureUnit: temperatureUnit ?? this.temperatureUnit,
      windUnit: windUnit ?? this.windUnit,
      favorites: favorites ?? this.favorites,
      recentSearches: recentSearches ?? this.recentSearches,
    );
  }
}

class AppSettingsNotifier extends StateNotifier<AppSettingsState> {
  AppSettingsNotifier(this._storageService) : super(const AppSettingsState()) {
    _load();
  }

  final StorageService _storageService;

  static const _themeModeKey = 'theme_mode';
  static const _onboardingCompletedKey = 'onboarding_completed';
  static const _temperatureUnitKey = 'temp_unit';
  static const _windUnitKey = 'wind_unit';
  static const _favoritesKey = 'favorites';
  static const _recentSearchesKey = 'recent_searches';

  Future<void> _load() async {
    try {
      final themeIndex = await _storageService.getInt(_themeModeKey) ?? 0;
      final onboardingCompleted =
          await _storageService.getBool(_onboardingCompletedKey) ?? false;
      final temperatureUnit =
          await _storageService.getString(_temperatureUnitKey) ?? '°C';
      final windUnit = await _storageService.getString(_windUnitKey) ?? 'km/h';
      final favorites =
          await _storageService.getStringList(_favoritesKey) ?? const <String>[];
      final recentSearches =
          await _storageService.getStringList(_recentSearchesKey) ??
          const <String>[];

      state = state.copyWith(
        themeMode:
            ThemeMode.values[themeIndex.clamp(0, ThemeMode.values.length - 1)],
        onboardingCompleted: onboardingCompleted,
        temperatureUnit: temperatureUnit,
        windUnit: windUnit,
        favorites: favorites,
        recentSearches: recentSearches,
      );
    } catch (_) {
      state = const AppSettingsState();
    }
  }

  Future<void> completeOnboarding() async {
    try {
      await _storageService.saveBool(_onboardingCompletedKey, true);
    } catch (_) {}
    state = state.copyWith(onboardingCompleted: true);
  }

  Future<void> setThemeMode(ThemeMode value) async {
    try {
      await _storageService.saveInt(_themeModeKey, value.index);
    } catch (_) {}
    state = state.copyWith(themeMode: value);
  }

  Future<void> setTemperatureUnit(String unit) async {
    try {
      await _storageService.saveString(_temperatureUnitKey, unit);
    } catch (_) {}
    state = state.copyWith(temperatureUnit: unit);
  }

  Future<void> setWindUnit(String unit) async {
    try {
      await _storageService.saveString(_windUnitKey, unit);
    } catch (_) {}
    state = state.copyWith(windUnit: unit);
  }

  Future<void> toggleFavorite(String city) async {
    final favorites = List<String>.from(state.favorites);
    if (favorites.contains(city)) {
      favorites.remove(city);
    } else {
      favorites.add(city);
    }

    try {
      await _storageService.saveStringList(_favoritesKey, favorites);
    } catch (_) {}
    state = state.copyWith(favorites: favorites);
  }

  Future<void> removeFavorite(String city) async {
    final favorites = List<String>.from(state.favorites)
      ..remove(city);

    try {
      await _storageService.saveStringList(_favoritesKey, favorites);
    } catch (_) {}
    state = state.copyWith(favorites: favorites);
  }

  Future<void> addRecentSearch(String city) async {
    final recentSearches = List<String>.from(state.recentSearches);
    recentSearches.remove(city);
    recentSearches.insert(0, city);
    if (recentSearches.length > 6) {
      recentSearches.removeLast();
    }

    try {
      await _storageService.saveStringList(_recentSearchesKey, recentSearches);
    } catch (_) {}
    state = state.copyWith(recentSearches: recentSearches);
  }

  Future<void> clearRecentSearches() async {
    try {
      await _storageService.saveStringList(_recentSearchesKey, const <String>[]);
    } catch (_) {}
    state = state.copyWith(recentSearches: const <String>[]);
  }
}

final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettingsState>(
      (ref) => AppSettingsNotifier(ref.read(storageServiceProvider)),
    );
