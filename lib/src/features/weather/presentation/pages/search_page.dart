import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/providers/app_settings_provider.dart';
// remote data source and repository imports removed; using DI provider directly
import 'package:skycast/src/core/di/providers.dart' as di;
import '../providers/weather_provider.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  List<String> _remoteSuggestions = [];
  bool _loading = false;

  static const List<String> _cities = <String>[
    'New York',
    'London',
    'Tokyo',
    'Paris',
    'Sydney',
    'Seattle',
    'Toronto',
    'Dubai',
  ];

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    final query = _controller.text.trim();
    final suggestions = query.isEmpty
        ? _cities
        : _remoteSuggestions.isNotEmpty
            ? _remoteSuggestions
            : _cities.where((city) => city.toLowerCase().contains(query.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Search cities')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              onChanged: (val) {
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 450), () async {
                  final q = val.trim();
                  if (q.isEmpty) {
                    setState(() {
                      _remoteSuggestions = [];
                      _loading = false;
                    });
                    return;
                  }

                  setState(() => _loading = true);
                  try {
                    final ds = ref.read(di.weatherRemoteDataSourceProvider);
                    final results = await ds.searchCitySuggestions(q);
                    if (!mounted) return;
                    setState(() {
                      _remoteSuggestions = results;
                      _loading = false;
                    });
                  } catch (_) {
                    if (!mounted) return;
                    setState(() {
                      _remoteSuggestions = [];
                      _loading = false;
                    });
                  }
                });
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Search for a city',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            if (_loading) const LinearProgressIndicator(),
            const SizedBox(height: 16),
            if (settings.recentSearches.isNotEmpty) ...[
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Recent searches',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  TextButton(
                    onPressed: () => ref
                        .read(appSettingsProvider.notifier)
                        .clearRecentSearches(),
                    child: const Text('Clear'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: settings.recentSearches.map((city) {
                  return ActionChip(
                    label: Text(city),
                    avatar: const Icon(Icons.history, size: 18),
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final nav = Navigator.of(context);
                      await ref.read(appSettingsProvider.notifier).addRecentSearch(city);
                      ref.read(weatherNotifierProvider.notifier).loadWeather(city);
                      if (!mounted) return;
                      nav.pop();
                      messenger.showSnackBar(
                        SnackBar(content: Text('Loaded $city')),
                      );
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
            Expanded(
              child: ListView.separated(
                itemCount: suggestions.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final city = suggestions[index];
                  final isFavorite = settings.favorites.contains(city);
                  return ListTile(
                    leading: const Icon(Icons.place_outlined),
                    title: Text(city),
                    subtitle: const Text('Tap to save as a recent search'),
                    trailing: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.redAccent : null,
                      ),
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        await ref.read(appSettingsProvider.notifier).toggleFavorite(city);
                        if (!mounted) return;
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              isFavorite ? 'Removed $city from favorites' : 'Added $city to favorites',
                            ),
                          ),
                        );
                      },
                    ),
                    onTap: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final nav = Navigator.of(context);
                      await ref.read(appSettingsProvider.notifier).addRecentSearch(city);
                      ref.read(weatherNotifierProvider.notifier).loadWeather(city);
                      if (!mounted) return;
                      nav.pop();
                      messenger.showSnackBar(
                        SnackBar(content: Text('Loaded $city')),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
