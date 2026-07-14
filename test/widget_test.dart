import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:skycast/src/app.dart';
import 'package:skycast/src/features/weather/presentation/pages/favorites_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows the onboarding experience on first launch', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: SkyCastApp()));
    // advance time to after the splash delay (1600ms)
    await tester.pump(const Duration(milliseconds: 1700));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.text('Welcome to SkyCast Pro'), findsOneWidget);
  });

  testWidgets('shows an empty state when no favorites are saved', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: FavoritesPage())),
    );
    await tester.pumpAndSettle();

    expect(find.text('No favorites yet'), findsOneWidget);
  });
}
