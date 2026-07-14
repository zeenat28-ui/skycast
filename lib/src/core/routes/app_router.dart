import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/weather/presentation/pages/home_page.dart';
import '../../features/weather/presentation/pages/onboarding_page.dart';
import '../../features/weather/presentation/pages/splash_page.dart';
import '../../features/weather/presentation/pages/forecast_page.dart';

import '../../features/weather/presentation/pages/search_page.dart';
import '../../features/weather/presentation/pages/settings_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: <GoRoute>[
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (BuildContext context, GoRouterState state) =>
          const SplashPage(),
    ),
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (BuildContext context, GoRouterState state) =>
          const OnboardingPage(),
    ),
    GoRoute(
      path: '/home',
      name: 'weather_home',
      builder: (BuildContext context, GoRouterState state) => const HomePage(),
    ),
    GoRoute(
      path: '/search',
      name: 'search',
      builder: (BuildContext context, GoRouterState state) => const SearchPage(),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (BuildContext context, GoRouterState state) => const SettingsPage(),
    ),
    GoRoute(
      path: '/forecast',
      name: 'forecast',
      builder: (BuildContext context, GoRouterState state) => const ForecastPage(),
    ),
  ],
  errorBuilder: (BuildContext context, GoRouterState state) {
    return ErrorPage(message: state.error?.toString() ?? 'Page not found');
  },
);

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Navigation Error')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
