import 'dart:async';

import 'package:flutter/material.dart';
import '../../main.dart';
import '../../services/ad_service.dart';
import '../../services/hive_service.dart';
import '../../services/notification_service.dart';
import '../../services/session_navigator.dart';
import '../../services/settings_service.dart';
import '../../services/study_session_repository.dart';
import '../../services/streak_freeze_service.dart';
import '../../services/subscription_service.dart';
import '../../theme/app_theme_extension.dart';
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
      NotificationService.onSessionTapped = SessionNavigator.openSession;
      // A tap that launched the app arrives before any of this ran, so ask
      // for it rather than waiting for a callback that already fired.
      final launchSessionId = await NotificationService.sessionIdFromLaunch();
      if (launchSessionId != null) {
        SessionNavigator.setPending(launchSessionId);
      }
      await SubscriptionService.init();
      // Not awaited: ads are optional, so a slow or failing SDK must never
      // hold up the splash screen.
      unawaited(AdService.init());
      themeModeNotifier.value = SettingsService.themeMode;
      // Without this the app paints the default palette for a frame before
      // the stored choice lands.
      accentPaletteNotifier.value = SettingsService.accentPaletteIndex;
      // Once per launch, and only here: the streak itself is recalculated on
      // every dashboard rebuild, so spending a token there would drain the
      // stock as the user scrolls.
      final sessions = StudySessionRepository().getAllSessions();
      final outcome = await StreakFreezeService.check(
        sessions: sessions,
        now: DateTime.now(),
      );
      // The evening warning is otherwise only rebuilt from the Profile
      // screen, so someone who plans a session and never goes there would
      // never be warned. Launch is the one point that reliably sees the
      // day's plan.
      await NotificationService.refreshStreakWarning(sessions);
      if (outcome.savedStreak) {
        // Surfaced by HomePage on first paint. Without telling the user, the
        // freeze is invisible and the rule is never learned.
        pendingFreezeOutcome.value = outcome;
      }
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

    // Opened after the frame so the timer lands on top of the home screen,
    // leaving a back button that goes somewhere sensible.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SessionNavigator.openPending();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
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
