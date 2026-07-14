import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/presentation/providers/app_settings_provider.dart';
import 'core/routes/app_router.dart';
import 'core/styles/app_theme.dart';

class SkyCastApp extends ConsumerWidget {
  const SkyCastApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final appTitle = dotenv.isInitialized
        ? (dotenv.env['APP_NAME'] ?? 'SkyCast Pro')
        : 'SkyCast Pro';

    return MaterialApp.router(
      title: appTitle,
      debugShowCheckedModeBanner: false,
      themeMode: settings.themeMode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: appRouter,
    );
  }
}
