import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'l10n/app_localizations.dart';
import 'product/screens/splash_screen.dart';
import 'services/session_navigator.dart';
import 'theme/accent_palette.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme_extension.dart';

final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(ThemeMode.system);

/// Index into [AccentPalette.all]. Restored from storage on the splash screen,
/// which is the earliest point Hive is open.
final ValueNotifier<int> accentPaletteNotifier = ValueNotifier(0);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ValueListenableBuilder takes a single listenable, and the theme now
    // depends on two. Merging keeps one rebuild scope rather than nesting.
    return ListenableBuilder(
      listenable: Listenable.merge([themeModeNotifier, accentPaletteNotifier]),
      builder: (context, _) {
        final themeMode = themeModeNotifier.value;
        final palette = AccentPalette.byId(accentPaletteNotifier.value);

        return MaterialApp(
          title: 'Deadly',
          // Lets a notification tap navigate without a BuildContext.
          navigatorKey: SessionNavigator.navigatorKey,
          // Release builds never show this banner anyway; disabling it keeps
          // debug builds usable for App Store screenshots.
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              // Seeded too, so the handful of widgets reading colorScheme
              // directly drift along with the choice.
              seedColor: palette.accent,
              brightness: Brightness.light,
              surface: palette.backgroundTint,
            ),
            scaffoldBackgroundColor: palette.backgroundTint,
            useMaterial3: true,
            fontFamily: 'Roboto',
            extensions: [AppTheme.light.withAccent(palette)],
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: palette.accent,
              brightness: Brightness.dark,
              surface: palette.backgroundTintDark,
            ),
            scaffoldBackgroundColor: palette.backgroundTintDark,
            // Cards stay flat: only the page beneath them takes the tint.
            cardColor: AppColors.darkCard,
            useMaterial3: true,
            fontFamily: 'Roboto',
            extensions: [AppTheme.dark.withAccent(palette)],
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          themeMode: themeMode,
          home: const SplashScreen(),
        );
      },
    );
  }
}
