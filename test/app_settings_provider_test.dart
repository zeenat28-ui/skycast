import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:skycast/src/core/presentation/providers/app_settings_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('appSettingsProvider persists recent searches and favorites', () async {
    SharedPreferences.setMockInitialValues({});

    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(appSettingsProvider.notifier);
    await notifier.addRecentSearch('Paris');
    var settings = container.read(appSettingsProvider);
    expect(settings.recentSearches.contains('Paris'), true);

    await notifier.toggleFavorite('Paris');
    settings = container.read(appSettingsProvider);
    expect(settings.favorites.contains('Paris'), true);

    await notifier.toggleFavorite('Paris');
    settings = container.read(appSettingsProvider);
    expect(settings.favorites.contains('Paris'), false);
  });
}
