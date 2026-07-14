import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skycast/src/features/weather/presentation/pages/search_page.dart';

void main() {
  testWidgets('SearchPage renders and shows input', (tester) async {
    await tester.pumpWidget(ProviderScope(child: MaterialApp(home: SearchPage())));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
  });
}
