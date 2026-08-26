import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'l10n/app_localizations.dart';
import 'product/screens/splash_screen.dart';
import 'services/session_navigator.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme_extension.dart';

final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(ThemeMode.system);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'Deadly',
          // Lets a notification tap navigate without a BuildContext.
          navigatorKey: SessionNavigator.navigatorKey,
          // Release builds never show this banner anyway; disabling it keeps
          // debug builds usable for App Store screenshots.
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              brightness: Brightness.light,
              surface: AppColors.lightBackground,
            ),
            scaffoldBackgroundColor: AppColors.lightBackground,
            useMaterial3: true,
            fontFamily: 'Roboto',
            extensions: const [AppTheme.light],
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              brightness: Brightness.dark,
              surface: AppColors.darkBackground,
            ),
            scaffoldBackgroundColor: AppColors.darkBackground,
            cardColor: AppColors.darkCard,
            useMaterial3: true,
            fontFamily: 'Roboto',
            extensions: const [AppTheme.dark],
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
