import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../services/calendar_sync_service.dart';
import '../../services/settings_service.dart';
import '../../theme/app_theme_extension.dart';
import '../../utils/l10n_extension.dart';
import '../../widgets/onboarding/onboarding_landing_button.dart';
import '../../widgets/onboarding/onboarding_landing_page.dart';
import '../../widgets/onboarding/onboarding_step_calendar.dart';
import '../../widgets/onboarding/onboarding_step_name.dart';
import '../../widgets/onboarding/onboarding_step_notifications.dart';
import '../../widgets/onboarding/onboarding_step_subjects.dart';
import '../../widgets/profile/add_subject_modal.dart';
import '../navigation/home_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final _nameController = TextEditingController();
  final _schoolController = TextEditingController();
  bool _nameError = false;

  List<SubjectData> _subjects = [];
  int _sessionReminderMinutes = 15;
  int _deadlineReminderDays = 1;
  bool _calendarConnected = false;
  bool _calendarBusy = false;
  bool _calendarDenied = false;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _schoolController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage == 1) {
      if (_nameController.text.trim().isEmpty) {
        setState(() => _nameError = true);
        return;
      }
    }
    // Advancing swaps pages without disposing the fields, so focus has to be
    // cleared explicitly or the keyboard stays up over the next step.
    FocusManager.instance.primaryFocus?.unfocus();
    if (_currentPage < 4) {
      setState(() {
        _nameError = false;
        _currentPage++;
      });
      _pageController.jumpToPage(_currentPage);
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) await SettingsService.setUserName(name);
    final school = _schoolController.text.trim();
    if (school.isNotEmpty) await SettingsService.setSchoolName(school);
    if (_subjects.isNotEmpty) await SettingsService.setSubjectData(_subjects);
    await SettingsService.setSessionReminderMinutes(_sessionReminderMinutes);
    await SettingsService.setDeadlineReminderDays(_deadlineReminderDays);
    await SettingsService.setOnboardingCompleted(true);
    // The calendar step above already made the offer, so the one-off prompt
    // on the home screen — which exists for users who upgraded past it —
    // must not fire for this user.
    await SettingsService.setCalendarPromptShown(true);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    }
  }

  /// Asks for calendar access and creates the app's own calendar.
  ///
  /// Nothing is written yet: a new user has no deadlines to mirror. The first
  /// deadline they save syncs itself, because the setting is on by then.
  Future<void> _connectCalendar() async {
    if (_calendarBusy || _calendarConnected) return;
    setState(() => _calendarBusy = true);

    final granted = await CalendarSyncService.requestPermission();
    var connected = false;
    if (granted) {
      // The backfill finds nothing for a new user, but going through the same
      // path as everywhere else keeps this to one way of switching sync on.
      connected = await CalendarSyncService.enableAndBackfill();
    }

    if (!mounted) return;
    setState(() {
      _calendarBusy = false;
      _calendarConnected = connected;
      // Only a refused permission is a dead end: iOS shows its prompt once,
      // so offering the button again would go nowhere. A permission that was
      // granted but whose calendar could not be created is worth retrying,
      // so the button stays.
      _calendarDenied = !granted;
    });
  }

  void _addSubject(SubjectData subject) {
    if (_subjects.contains(subject)) return;
    setState(() => _subjects = [..._subjects, subject]);
  }

  void _removeSubject(SubjectData subject) {
    setState(() => _subjects = _subjects.where((s) => s != subject).toList());
  }

  Future<void> _showAddSubjectModal() async {
    final result = await showModalBottomSheet<SubjectData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddSubjectModal(),
    );
    if (result != null && mounted) {
      _addSubject(result);
    }
  }

  Future<void> _pickSessionReminder() async {
    final options = [0, 5, 10, 15, 30, 60];
    final initialIndex = options.indexOf(_sessionReminderMinutes);
    final title = context.l10n.onboardingSessionReminder;
    final subtitle = context.l10n.profilePickerSessionSubtitle;
    final itemLabels = options
        .map((m) => context.l10n.profileSessionReminderFormat(m))
        .toList();

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _buildPickerSheet(
          ctx: ctx,
          title: title,
          subtitle: subtitle,
          initialIndex: initialIndex < 0 ? 3 : initialIndex,
          itemCount: options.length,
          itemBuilder: (i) => itemLabels[i],
          onConfirm: (index) async {
            if (mounted) setState(() => _sessionReminderMinutes = options[index]);
          },
        );
      },
    );
  }

  Future<void> _pickDeadlineReminder() async {
    final options = [1, 2, 3, 7];
    final initialIndex = options.indexOf(_deadlineReminderDays);
    final title = context.l10n.onboardingDeadlineReminder;
    final subtitle = context.l10n.profilePickerDeadlineSubtitle;
    final itemLabels = options
        .map((d) => context.l10n.profilePickerDeadlineOptionFormat(d))
        .toList();

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _buildPickerSheet(
          ctx: ctx,
          title: title,
          subtitle: subtitle,
          initialIndex: initialIndex < 0 ? 0 : initialIndex,
          itemCount: options.length,
          itemBuilder: (i) => itemLabels[i],
          onConfirm: (index) async {
            if (mounted) setState(() => _deadlineReminderDays = options[index]);
          },
        );
      },
    );
  }

  Widget _buildPickerSheet({
    required BuildContext ctx,
    required String title,
    required String subtitle,
    required int initialIndex,
    required int itemCount,
    required String Function(int) itemBuilder,
    required Future<void> Function(int) onConfirm,
  }) {
    final isDark = ctx.colors.isDark;
    int selectedIndex = initialIndex;

    return Container(
      decoration: BoxDecoration(
        color: ctx.colors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ctx.colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: ctx.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: ctx.colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 200,
            child: CupertinoTheme(
              data: CupertinoThemeData(
                brightness: isDark ? Brightness.dark : Brightness.light,
                textTheme: CupertinoTextThemeData(
                  pickerTextStyle: TextStyle(
                    fontSize: 20,
                    color: ctx.colors.textPrimary,
                  ),
                ),
              ),
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(
                  initialItem: initialIndex,
                ),
                itemExtent: 44,
                onSelectedItemChanged: (i) => selectedIndex = i,
                children: List.generate(
                  itemCount,
                  (i) => Center(child: Text(itemBuilder(i))),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
                16, 12, 16, MediaQuery.of(ctx).padding.bottom + 16),
            child: OnboardingLandingButton(
              label: context.l10n.btnConfirm,
              width: double.infinity,
              onTap: () async {
                Navigator.pop(ctx);
                await onConfirm(selectedIndex);
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          OnboardingLandingPage(onNext: _nextPage),
          OnboardingStepName(
            nameController: _nameController,
            schoolController: _schoolController,
            nameError: _nameError,
            onNext: _nextPage,
            onNameChanged: (_) {
              if (_nameError) setState(() => _nameError = false);
            },
          ),
          OnboardingStepSubjects(
            subjects: _subjects,
            onNext: _nextPage,
            onAddSubject: _showAddSubjectModal,
            onRemoveSubject: _removeSubject,
          ),
          OnboardingStepNotifications(
            sessionReminderMinutes: _sessionReminderMinutes,
            deadlineReminderDays: _deadlineReminderDays,
            onNext: _nextPage,
            onSessionReminderTap: _pickSessionReminder,
            onDeadlineReminderTap: _pickDeadlineReminder,
          ),
          OnboardingStepCalendar(
            isConnected: _calendarConnected,
            isBusy: _calendarBusy,
            isDenied: _calendarDenied,
            onConnectTap: _connectCalendar,
            onComplete: _completeOnboarding,
          ),
        ],
      ),
    );
  }
}
