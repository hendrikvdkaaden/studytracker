import 'package:flutter/material.dart';
import '../../main.dart';
import '../../services/calendar_sync_service.dart';
import '../../services/settings_service.dart';
import '../../services/streak_freeze_service.dart';
import '../../services/update_service.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../theme/app_theme_extension.dart';
import '../../utils/l10n_extension.dart';
import '../screens/home_screen.dart';
import '../screens/plan_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/profile_screen.dart';
import '../../widgets/common/app_dialog.dart';
import '../../widgets/common/pending_value_listener.dart';
import '../../widgets/common/streak_celebration_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final _homeScreenKey = GlobalKey<HomeScreenState>();
  final _planScreenKey = GlobalKey<PlanScreenState>();
  final _dashboardScreenKey = GlobalKey<DashboardScreenState>();
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // Notification permission is asked for during onboarding now, where it
    // comes with an explanation. Requesting it here would put a bare system
    // dialog on a screen that says nothing about why.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Awaited: these ask the user for something, and awaiting is what keeps
      // them from stacking on top of each other -- each waits for the
      // previous to be dismissed. The freeze notice is not here; it rides a
      // PendingValueListener instead, see build.
      await _maybeOfferCalendarSync();
      if (!mounted) return;
      await _maybeOfferUpdate();
    });
    _screens = [
      HomeScreen(key: _homeScreenKey),
      PlanScreen(key: _planScreenKey),
      DashboardScreen(key: _dashboardScreenKey),
      ProfileScreen(onThemeChanged: _onThemeChanged),
    ];
  }

  /// Tells the user a freeze covered a missed day, once.
  ///
  /// The rescue happens on the splash screen, silently and automatically. Left
  /// unreported it would look like the streak simply survived a day off, and
  /// the rule would never be learned.
  ///
  /// A dialog rather than the snackbar this used to be: a snackbar that times
  /// out after five seconds is the wrong carrier for the one event that
  /// explains the freeze rule.
  Future<void> _showPendingFreezeNotice(FreezeOutcome outcome) async {
    if (!FreezeOutcome.worthReporting(outcome)) return;
    if (!mounted) return;

    await showFreezeRescueDialog(context: context, outcome: outcome);
  }

  /// Celebrates a streak that grew while the timer was open.
  ///
  /// The timer screen parks the number here rather than showing it itself, so
  /// the celebration lands after that screen closes -- and so the notification
  /// route into the timer, which has no screen underneath listening for a pop
  /// result, is covered too.
  Future<void> _showStreakCelebration(int streak) async {
    if (!mounted) return;
    await showStreakCelebrationDialog(context: context, streak: streak);
  }

  /// Offers calendar sync once to users who onboarded before the feature
  /// existed — they never saw the onboarding step that asks.
  ///
  /// The flag is stored as soon as the dialog is shown, not when it is
  /// accepted, so declining it does not bring it back every launch.

  Future<void> _maybeOfferCalendarSync() async {
    if (!SettingsService.shouldOfferCalendarSync) {
      // Nothing owed. Record it so the check settles for good.
      if (!SettingsService.calendarPromptShown) {
        await SettingsService.setCalendarPromptShown(true);
      }
      return;
    }
    if (!mounted) return;

    // Read the strings before the await, so the context is not used across
    // an async gap.
    final l10n = context.l10n;
    await SettingsService.setCalendarPromptShown(true);
    if (!mounted) return;

    // "Continue" rather than "Connect calendar": App Review reads a button
    // that names the permission as steering the user toward granting it.
    //
    // The dismiss option stays. Unlike the onboarding step, this appears
    // unasked at launch, so a dialog with no way out would be worse than the
    // guideline it satisfies -- and someone who never opens it is never taken
    // to the system prompt at all.
    final accepted = await showAppConfirmDialog(
      context: context,
      title: l10n.calendarPromptTitle,
      message: l10n.calendarPromptMessage,
      confirmLabel: l10n.calendarPromptConfirm,
      cancelLabel: l10n.calendarPromptDismiss,
      icon: Icons.calendar_month_outlined,
    );
    if (!accepted) return;

    final granted = await CalendarSyncService.requestPermission();
    if (!granted) return;

    // Backfilled, not just enabled: this prompt is aimed at people who
    // upgraded past onboarding, so they already have deadlines that would
    // otherwise never reach the calendar they just connected.
    await CalendarSyncService.enableAndBackfill();
  }

  /// Tells the user when a newer build is on the App Store.
  ///
  /// Dismissing is remembered per version, so "Later" holds until the next
  /// release rather than reappearing every launch. Nothing is blocked: a
  /// failed check, an offline device or a declined prompt all just carry on.
  Future<void> _maybeOfferUpdate() async {
    final update = await UpdateService.checkForUpdate();
    if (update == null || !mounted) return;
    if (!SettingsService.shouldPromptForUpdate(update.version)) return;

    final l10n = context.l10n;
    final accepted = await showAppConfirmDialog(
      context: context,
      title: l10n.updateAvailableTitle,
      message: l10n.updateAvailableMessage(update.version),
      confirmLabel: l10n.updateAvailableConfirm,
      cancelLabel: l10n.updateAvailableDismiss,
      icon: Icons.system_update_alt,
    );

    if (!accepted) {
      await SettingsService.setUpdateSnoozedVersion(update.version);
      return;
    }

    // Failing softly: the prompt is a convenience, and throwing here would
    // escape the post-frame callback with nothing to catch it.
    try {
      await launchUrl(update.storeUrl, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Opening the store page failed: $e');
    }
  }

  void _onThemeChanged() {
    // A payload-free ping: Profile has already persisted whichever of the two
    // the user changed, so both are re-read.
    themeModeNotifier.value = SettingsService.themeMode;
    accentPaletteNotifier.value = SettingsService.accentPaletteIndex;
  }

  @override
  Widget build(BuildContext context) {
    // Wraps the whole page so the subscription lives as long as it does. The
    // celebration is parked by the timer screen mid-session, long after any
    // startup callback has run -- see PendingValueListener for the bug that
    // caused.
    return PendingValueListener<FreezeOutcome>(
      notifier: pendingFreezeOutcome,
      // A one-shot read in the startup callback raced the splash: the rescue
      // is awaited inside _initializeApp, but navigation can fire from the
      // animation instead, so the value sometimes landed after HomePage had
      // already looked. The listener picks it up either way.
      onValue: _showPendingFreezeNotice,
      child: PendingValueListener<int>(
        notifier: pendingStreakCelebration,
        onValue: _showStreakCelebration,
        child: _buildScaffold(context),
      ),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/logo.png',
          width: 32,
          height: 32,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
        backgroundColor: context.colors.background.withValues(alpha: 0.8),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: context.colors.border,
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            // IndexedStack keeps every tab alive, so switching back does not
            // rebuild it. Each data-driven tab is refreshed explicitly.
            switch (index) {
              case 0:
                _homeScreenKey.currentState?.refresh();
              case 1:
                _planScreenKey.currentState?.refresh();
              case 2:
                _dashboardScreenKey.currentState?.refresh();
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: context.colors.card.withValues(alpha: 0.8),
          selectedItemColor: context.colors.accent,
          unselectedItemColor: context.colors.textSecondary,
          selectedFontSize: 10,
          unselectedFontSize: 10,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: context.l10n.navHome,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.calendar_today),
              label: context.l10n.navCalendar,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.bar_chart),
              label: context.l10n.navDeadlines,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person),
              label: context.l10n.navProfile,
            ),
          ],
        ),
      ),
    );
  }
}
