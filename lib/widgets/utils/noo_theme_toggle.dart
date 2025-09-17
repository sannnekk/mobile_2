import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  static const _key = 'theme_mode';
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getString(_key);
    if (mode == 'dark') {
      state = ThemeMode.dark;
    } else if (mode == 'light') {
      state = ThemeMode.light;
    } else {
      state = ThemeMode.system;
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, _themeToString(mode));
  }

  String _themeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.light:
        return 'light';
      default:
        return 'system';
    }
  }
}

class NooThemeToggle extends ConsumerWidget {
  const NooThemeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.light_mode),
          color: mode == ThemeMode.light
              ? Theme.of(context).colorScheme.primary
              : null,
          onPressed: () =>
              ref.read(themeModeProvider.notifier).setTheme(ThemeMode.light),
        ),
        IconButton(
          icon: const Icon(Icons.dark_mode),
          color: mode == ThemeMode.dark
              ? Theme.of(context).colorScheme.primary
              : null,
          onPressed: () =>
              ref.read(themeModeProvider.notifier).setTheme(ThemeMode.dark),
        ),
        IconButton(
          icon: const Icon(Icons.brightness_auto),
          color: mode == ThemeMode.system
              ? Theme.of(context).colorScheme.primary
              : null,
          onPressed: () =>
              ref.read(themeModeProvider.notifier).setTheme(ThemeMode.system),
        ),
      ],
    );
  }
}
