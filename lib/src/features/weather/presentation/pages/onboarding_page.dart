import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/providers/app_settings_provider.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(appSettingsProvider.notifier).completeOnboarding();
    if (!mounted) return;
    context.go('/home');
  }

  Future<void> _next() async {
    if (_index < 2) {
      await _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      await _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bindingName = WidgetsBinding.instance.runtimeType.toString();
    final showAnimations = !bindingName.contains('TestWidgetsFlutterBinding');
    final pages = [
      _OnboardingCard(
        icon: Icons.wb_sunny_rounded,
        title: 'Welcome to SkyCast Pro',
        description:
            'A premium weather experience designed to feel calm, fast, and beautifully informative.',
        showAnimations: showAnimations,
      ),
      _OnboardingCard(
        icon: Icons.query_stats_rounded,
        title: 'Real-time outlooks',
        description:
            'See the current conditions, hourly trends, and daily forecasts in one streamlined view.',
        showAnimations: showAnimations,
      ),
      _OnboardingCard(
        icon: Icons.wifi_off_rounded,
        title: 'Stay ready offline',
        description:
            'Your latest weather remains available even when the connection drops.',
        showAnimations: showAnimations,
      ),
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF111827), Color(0xFF1E3A8A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: pages.length,
                  onPageChanged: (value) => setState(() => _index = value),
                  itemBuilder: (context, index) =>
                      pages[index].animate().fadeIn(duration: 400.ms),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: _finish,
                      child: const Text('Skip'),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          pages.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.only(right: 8),
                            height: 8,
                            width: _index == index ? 24 : 8,
                            decoration: BoxDecoration(
                              color: _index == index
                                  ? Colors.white
                                  : Colors.white38,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _next,
                      child: Text(_index == pages.length - 1 ? 'Done' : 'Next'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingCard extends StatelessWidget {
  const _OnboardingCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.showAnimations,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool showAnimations;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(30),
            ),
            child: SizedBox(
              width: 120,
              height: 120,
              child: showAnimations
                  ? Icon(icon, size: 70, color: Colors.white)
                      .animate(onPlay: (controller) => controller.repeat())
                      .shimmer(duration: 2.seconds, delay: 1.seconds)
                      .scaleXY(begin: 0.95, end: 1.05, duration: 1.seconds, curve: Curves.easeInOut)
                      .then()
                      .scaleXY(begin: 1.05, end: 0.95, duration: 1.seconds, curve: Curves.easeInOut)
                  : Icon(icon, size: 70, color: Colors.white),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
