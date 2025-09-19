import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:mobile_2/widgets/utils/noo_theme_toggle.dart';
import 'core/router.dart';
import 'core/providers/api_client_provider.dart';
import 'styles/theme.dart';

void main() {
  initializeDateFormatting().then(
    (_) => runApp(const ProviderScope(child: NooApp())),
  );
}

class NooApp extends ConsumerWidget {
  const NooApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);

    // Initialize API client when the app starts
    ref.watch(apiClientProvider);

    return MaterialApp.router(
      title: 'Noo App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      localizationsDelegates: [
        ...GlobalMaterialLocalizations.delegates,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', 'US'), Locale('ru', 'RU')],
    );
  }
}
