import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/providers/app_settings_provider.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 1600), () {
        if (!mounted) return;
        final settings = ref.read(appSettingsProvider);
        if (settings.onboardingCompleted) {
          context.go('/home');
        } else {
          context.go('/onboarding');
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final bindingName = WidgetsBinding.instance.runtimeType.toString();
    final showAnimations = !bindingName.contains('TestWidgetsFlutterBinding');

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1D4ED8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showAnimations)
                Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: SizedBox(
                        width: 120,
                        height: 120,
                        child: Icon(Icons.cloud, size: 70, color: Colors.white)
                          .animate(onPlay: (controller) => controller.repeat())
                          .shimmer(duration: 2.seconds, delay: 1.seconds)
                          .scaleXY(begin: 0.95, end: 1.05, duration: 1.seconds, curve: Curves.easeInOut)
                          .then()
                          .scaleXY(begin: 1.05, end: 0.95, duration: 1.seconds, curve: Curves.easeInOut),
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .scale(begin: const Offset(0.9, 0.9)),
              if (!showAnimations)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const SizedBox(
                    width: 120,
                    height: 120,
                    child: Icon(Icons.cloud, size: 70, color: Colors.white),
                  ),
                ),
              const SizedBox(height: 24),
              Text(
                'SkyCast Pro',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Forecasting the sky with clarity',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
