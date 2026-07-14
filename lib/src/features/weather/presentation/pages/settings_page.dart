import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';

import '../../../../core/presentation/providers/app_settings_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: Theme.of(context).brightness == Brightness.dark
                ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                : [const Color(0xFFE0F2FE), const Color(0xFFBAE6FD)],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            children: [
              _buildSectionHeader('Appearance', context),
              _buildGlassCard(
                context,
                child: Column(
                  children: [
                    _buildSettingTile(
                      title: 'Theme',
                      subtitle: _themeLabel(settings.themeMode),
                      icon: Icons.palette_outlined,
                      onTap: () => _showThemePicker(context, ref, settings.themeMode),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('Units', context),
              _buildGlassCard(
                context,
                child: Column(
                  children: [
                    _buildSettingTile(
                      title: 'Temperature Unit',
                      subtitle: settings.temperatureUnit == '°C' ? 'Celsius (°C)' : 'Fahrenheit (°F)',
                      icon: Icons.thermostat_outlined,
                      onTap: () => _showTempUnitPicker(context, ref, settings.temperatureUnit),
                    ),
                    Divider(color: Colors.white.withOpacity(0.1), height: 1),
                    _buildSettingTile(
                      title: 'Wind Speed Unit',
                      subtitle: settings.windUnit == 'km/h' ? 'Kilometers per hour' : 'Miles per hour',
                      icon: Icons.air,
                      onTap: () => _showWindUnitPicker(context, ref, settings.windUnit),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('Information', context),
              _buildGlassCard(
                context,
                child: _buildSettingTile(
                  title: 'About SkyCast Pro',
                  subtitle: 'Version 1.0.0',
                  icon: Icons.info_outline,
                  onTap: () => _showAboutDialog(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
    );
  }

  Widget _buildGlassCard(BuildContext context, {required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.blueAccent),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 13)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }

  void _showThemePicker(BuildContext context, WidgetRef ref, ThemeMode currentTheme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBottomSheet(
        context,
        title: 'Choose Theme',
        children: [
          _buildRadioOption<ThemeMode>(
            title: 'System Default',
            value: ThemeMode.system,
            groupValue: currentTheme,
            onChanged: (val) {
              ref.read(appSettingsProvider.notifier).setThemeMode(val!);
              Navigator.pop(context);
            },
          ),
          _buildRadioOption<ThemeMode>(
            title: 'Light Mode',
            value: ThemeMode.light,
            groupValue: currentTheme,
            onChanged: (val) {
              ref.read(appSettingsProvider.notifier).setThemeMode(val!);
              Navigator.pop(context);
            },
          ),
          _buildRadioOption<ThemeMode>(
            title: 'Dark Mode',
            value: ThemeMode.dark,
            groupValue: currentTheme,
            onChanged: (val) {
              ref.read(appSettingsProvider.notifier).setThemeMode(val!);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showTempUnitPicker(BuildContext context, WidgetRef ref, String currentUnit) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBottomSheet(
        context,
        title: 'Temperature Unit',
        children: [
          _buildRadioOption<String>(
            title: 'Celsius (°C)',
            value: '°C',
            groupValue: currentUnit,
            onChanged: (val) {
              ref.read(appSettingsProvider.notifier).setTemperatureUnit(val!);
              Navigator.pop(context);
            },
          ),
          _buildRadioOption<String>(
            title: 'Fahrenheit (°F)',
            value: '°F',
            groupValue: currentUnit,
            onChanged: (val) {
              ref.read(appSettingsProvider.notifier).setTemperatureUnit(val!);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showWindUnitPicker(BuildContext context, WidgetRef ref, String currentUnit) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBottomSheet(
        context,
        title: 'Wind Speed Unit',
        children: [
          _buildRadioOption<String>(
            title: 'Kilometers per hour (km/h)',
            value: 'km/h',
            groupValue: currentUnit,
            onChanged: (val) {
              ref.read(appSettingsProvider.notifier).setWindUnit(val!);
              Navigator.pop(context);
            },
          ),
          _buildRadioOption<String>(
            title: 'Miles per hour (mph)',
            value: 'mph',
            groupValue: currentUnit,
            onChanged: (val) {
              ref.read(appSettingsProvider.notifier).setWindUnit(val!);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet(BuildContext context, {required String title, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRadioOption<T>({
    required String title,
    required T value,
    required T groupValue,
    required ValueChanged<T?> onChanged,
  }) {
    return RadioListTile<T>(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: Colors.blueAccent,
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.cloud_outlined, color: Colors.blueAccent, size: 32),
            SizedBox(width: 12),
            Text('SkyCast Pro', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'SkyCast Pro is a premium weather application providing highly accurate forecasting, stunning UI, and a smooth experience.\n\nVersion 1.0.0',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  String _themeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.system:
        return 'System Default';
    }
  }
}
