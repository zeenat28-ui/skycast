import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skycast/src/features/weather/presentation/pages/forecast_page.dart';

void main() {
  testWidgets('ForecastPage renders without crashing', (tester) async {
    await tester.pumpWidget(ProviderScope(child: MaterialApp(home: ForecastPage())));
    await tester.pumpAndSettle();

    // At minimum, the scaffold should exist
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
