import 'package:flutter/material.dart';
import '../../main.dart';
import '../../services/hive_service.dart';
import '../../services/notification_service.dart';
import '../../services/settings_service.dart';
import '../../services/subscription_service.dart';
import '../../theme/app_colors.dart';
import '../navigation/home_page.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  bool _initialized = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _controller.addListener(() {
      if (_controller.value >= 0.75 && _initialized && !_navigated) {
        _navigated = true;
        _navigate();
      }
    });

    _controller.forward();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await HiveService.init();
      await NotificationService.init();
      await SubscriptionService.init();
      themeModeNotifier.value = SettingsService.themeMode;
    } catch (e) {
      debugPrint('Initialization error: $e');
    }

    _initialized = true;

    if (_controller.value >= 0.75 && !_navigated) {
      _navigated = true;
      _navigate();
    }
  }

  void _navigate() {
    if (!mounted) return;
    final destination = SettingsService.onboardingCompleted
        ? const HomePage()
        : const OnboardingScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => destination,
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Center(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        width: 120,
                        height: 120,
                      ),
                    ],
                  ),
                ),
              ),
            );
        },
      ),
    );
  }
}
