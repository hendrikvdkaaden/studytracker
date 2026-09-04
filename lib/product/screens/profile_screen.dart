import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../../services/ad_service.dart';
import '../../services/calendar_sync_service.dart';
import '../../services/hive_service.dart';
import '../../services/settings_service.dart';
import '../../services/subscription_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme_extension.dart';
import '../../utils/l10n_extension.dart';
import '../../utils/legal_links.dart';
import '../../widgets/common/app_dialog.dart';
import '../../widgets/common/paywall_bottom_sheet.dart';
import '../../widgets/profile/add_subject_modal.dart';
import '../../widgets/profile/edit_name_dialog.dart';
import '../templates/profile_template.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final VoidCallback? onThemeChanged;

  const ProfileScreen({super.key, this.onThemeChanged});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String _userName = '';
  int _sessionReminderMinutes = 15;
  int _deadlineReminderDays = 1;
  int _themeModeIndex = 0;
  List<SubjectData> _subjects = [];
  String _schoolName = '';
  bool _showPrivacyOptions = false;
  bool _calendarSyncEnabled = false;
  bool _planAroundCalendar = SettingsService.planAroundCalendar;
  bool _calendarBusy = false;

  @override
  void initState() {
    super.initState();
    _userName = SettingsService.userName;
    _sessionReminderMinutes = SettingsService.sessionReminderMinutes;
    _deadlineReminderDays = SettingsService.deadlineReminderDays;
    _themeModeIndex = SettingsService.themeModeIndex;
    _subjects = SettingsService.subjectData;
    _schoolName = SettingsService.schoolName;
    _loadPrivacyOptionsStatus();
    _loadCalendarSyncStatus();
  }

  /// Reconciles the stored preference with reality: the user may have revoked
  /// calendar access in system settings since they turned sync on.
  ///
  /// Switching sync off here has to clear the stored event ids as well.
  /// Without that, re-enabling would write a second entry for every goal and
  /// session that still carried an id from before.
  Future<void> _loadCalendarSyncStatus() async {
    var enabled = SettingsService.calendarSyncEnabled;
    if (enabled && !await CalendarSyncService.hasPermission()) {
      await SettingsService.setCalendarSyncEnabled(false);
      await SettingsService.setCalendarId(null);
      await _clearStoredEventIds();
      enabled = false;
    }
    if (mounted) setState(() => _calendarSyncEnabled = enabled);
  }

  Future<void> _togglePlanAroundCalendar() async {
    final next = !_planAroundCalendar;
    setState(() => _planAroundCalendar = next);
    await SettingsService.setPlanAroundCalendar(next);
  }

  Future<void> _onCalendarSyncTap() async {
    if (_calendarBusy) return;
    // Held across the confirmation dialog as well, so a second tap while the
    // dialog is open cannot start a parallel sync.
    setState(() => _calendarBusy = true);
    try {
      if (_calendarSyncEnabled) {
        await _disableCalendarSync();
      } else {
        await _enableCalendarSync();
      }
    } finally {
      if (mounted) setState(() => _calendarBusy = false);
    }
  }

  Future<void> _enableCalendarSync() async {
    final l10n = context.l10n;
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: l10n.calendarSyncEnableTitle,
      message: l10n.calendarSyncEnableMessage,
      confirmLabel: l10n.calendarSyncEnableConfirm,
      icon: Icons.calendar_month_outlined,
    );
    if (!confirmed || !mounted) return;

    final granted = await CalendarSyncService.requestPermission();
    if (!mounted) return;

    if (!granted) {
      final openSettings = await showAppConfirmDialog(
        context: context,
        title: l10n.calendarSyncDeniedTitle,
        message: l10n.calendarSyncDeniedMessage,
        confirmLabel: l10n.calendarSyncDeniedConfirm,
        icon: Icons.lock_outline,
      );
      if (openSettings) await CalendarSyncService.openSettings();
      return;
    }

    await CalendarSyncService.enableAndBackfill(
      goalRepo: ref.read(goalRepositoryProvider),
      sessionRepo: ref.read(studySessionRepositoryProvider),
    );
    if (!mounted) return;
    setState(() {
      _calendarSyncEnabled = SettingsService.calendarSyncEnabled;
    });
  }

  Future<void> _disableCalendarSync() async {
    final l10n = context.l10n;
    final confirmed = await _showDestructiveConfirmation(
      title: l10n.calendarSyncDisableTitle,
      body: l10n.calendarSyncDisableMessage,
      confirmLabel: l10n.calendarSyncDisableConfirm,
    );
    if (confirmed != true || !mounted) return;

    await CalendarSyncService.purgeAll();
    await SettingsService.setCalendarSyncEnabled(false);
    await _clearStoredEventIds();
    if (!mounted) return;
    setState(() => _calendarSyncEnabled = false);
  }

  /// Drops every stored event id. Without this, re-enabling sync would try to
  /// update events in a calendar that no longer exists.
  Future<void> _clearStoredEventIds() async {
    final goalRepo = ref.read(goalRepositoryProvider);
    final sessionRepo = ref.read(studySessionRepositoryProvider);

    for (final goal in goalRepo.getAllGoals()) {
      if (goal.calendarEventId == null) continue;
      goal.calendarEventId = null;
      await goalRepo.updateGoal(goal);
    }
    for (final session in sessionRepo.getAllSessions()) {
      if (session.calendarEventId == null) continue;
      session.calendarEventId = null;
      await sessionRepo.updateSession(session);
    }
  }

  /// Google decides per region whether a consent entry point must be offered,
  /// so the row is only shown when it reports one is required.
  Future<void> _loadPrivacyOptionsStatus() async {
    final required = await AdService.isPrivacyOptionsRequired();
    if (mounted) setState(() => _showPrivacyOptions = required);
  }

  Future<void> _editProfile() async {
    final result = await showModalBottomSheet<EditProfileResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: EditNameDialog(
          initialName: _userName,
          initialSchoolName: _schoolName,
        ),
      ),
    );

    if (result != null && mounted) {
      await SettingsService.setUserName(result.name);
      await SettingsService.setSchoolName(result.schoolName);
      setState(() {
        _userName = result.name;
        _schoolName = result.schoolName;
      });
    }
  }

  Future<void> _addSubject() async {
    final isPremium = await ref.read(subscriptionServiceProvider).isPremium();
    if (!mounted) return;
    if (!isPremium && _subjects.length >= SubscriptionService.freeSubjectLimit) {
      final purchased = await showPaywallBottomSheet(context);
      if (!purchased || !mounted) return;
      ref.invalidate(isPremiumProvider);
    }

    final result = await showModalBottomSheet<SubjectData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddSubjectModal(),
    );
    if (result != null && mounted) {
      final updated = [..._subjects, result];
      await SettingsService.setSubjectData(updated);
      setState(() => _subjects = updated);
    }
  }

  Future<void> _deleteSubject(SubjectData subject) async {
    final l10n = context.l10n;
    final confirmed = await _showDestructiveConfirmation(
      title: l10n.profileRemoveSubjectTitle,
      body: l10n.profileRemoveSubjectBody(subject.name),
      confirmLabel: l10n.profileRemoveSubjectConfirm,
    );
    if (confirmed == true && mounted) {
      final updated = _subjects.where((s) => s.name != subject.name).toList();
      await SettingsService.setSubjectData(updated);
      setState(() => _subjects = updated);
    }
  }

  Future<void> _pickSessionReminder() async {
    final l10n = context.l10n;
    final isDark = context.colors.isDark;

    // Build list of minutes: 1–59
    final minutes = List.generate(59, (i) => i + 1);
    int tempValue = _sessionReminderMinutes.clamp(1, 59);

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: ctx.colors.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                      l10n.profilePickerSessionTitle,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.profilePickerSessionSubtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: ctx.colors.textSecondary,
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
                      initialItem: minutes.indexOf(tempValue),
                    ),
                    itemExtent: 44,
                    onSelectedItemChanged: (index) {
                      tempValue = minutes[index];
                    },
                    children: minutes.map((m) {
                      return Center(
                        child: Text(l10n.profilePickerSessionOptionFormat(m)),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    16, 12, 16, MediaQuery.of(ctx).padding.bottom + 16),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await SettingsService.setSessionReminderMinutes(tempValue);
                      setState(() => _sessionReminderMinutes = tempValue);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      context.l10n.btnConfirm,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickDeadlineReminder() async {
    final l10n = context.l10n;
    final isDark = context.colors.isDark;

    final days = List.generate(30, (i) => i + 1);
    int tempValue = _deadlineReminderDays.clamp(1, 30);

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: ctx.colors.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ctx.colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.profilePickerDeadlineTitle,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.profilePickerDeadlineSubtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: ctx.colors.textSecondary,
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
                      initialItem: days.indexOf(tempValue),
                    ),
                    itemExtent: 44,
                    onSelectedItemChanged: (index) {
                      tempValue = days[index];
                    },
                    children: days.map((d) {
                      return Center(
                        child: Text(l10n.profilePickerDeadlineOptionFormat(d)),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    16, 12, 16, MediaQuery.of(ctx).padding.bottom + 16),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await SettingsService.setDeadlineReminderDays(tempValue);
                      setState(() => _deadlineReminderDays = tempValue);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      context.l10n.btnConfirm,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickTheme() async {
    final l10n = context.l10n;
    final labels = [l10n.profileThemeSystem, l10n.profileThemeLight, l10n.profileThemeDark];
    await _showPickerSheet(
      title: l10n.profilePickerThemeTitle,
      options: [0, 1, 2],
      currentValue: _themeModeIndex,
      labelBuilder: (i) => labels[i],
      onSelected: (i) async {
        await SettingsService.setThemeModeIndex(i);
        setState(() => _themeModeIndex = i);
        widget.onThemeChanged?.call();
      },
    );
  }

  Future<void> _showPickerSheet<T>({
    required String title,
    String? subtitle,
    required List<T> options,
    required T currentValue,
    required String Function(T) labelBuilder,
    required Future<void> Function(T) onSelected,
  }) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: ctx.colors.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ctx.colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: ctx.colors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ...options.map((option) {
                final isSelected = option == currentValue;
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  title: Text(
                    labelBuilder(option),
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? AppColors.primary : null,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () async {
                    Navigator.pop(ctx);
                    await onSelected(option);
                  },
                );
              }),
              SizedBox(height: MediaQuery.of(ctx).padding.bottom + 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDeleteSessions() async {
    final l10n = context.l10n;
    final confirmed = await _showDestructiveConfirmation(
      title: l10n.profileDeleteSessionsTitle,
      body: l10n.profileDeleteSessionsBody,
      confirmLabel: l10n.profileDeleteSessionsConfirm,
    );
    if (confirmed == true && mounted) {
      // Remove only the study blocks. purgeAll would delete the whole
      // calendar, taking every deadline the user did not ask to remove with
      // it and stranding the event ids the goals still hold.
      final sessionRepo = ref.read(studySessionRepositoryProvider);
      await CalendarSyncService.deleteEvents(
        sessionRepo.getAllSessions().map((s) => s.calendarEventId),
      );
      await sessionRepo.clearAll();
    }
  }

  Future<void> _confirmDeleteEverything() async {
    final l10n = context.l10n;
    final confirmed = await _showDestructiveConfirmation(
      title: l10n.profileDeleteEverythingTitle,
      body: l10n.profileDeleteEverythingBody,
      confirmLabel: l10n.profileDeleteEverythingConfirm,
    );
    if (confirmed == true && mounted) {
      await CalendarSyncService.purgeAll();
      await HiveService.clearAllData();
      // clearAllData drops the settings box, so the stored ids go with it --
      // but sync would otherwise keep running against a calendar that is now
      // gone. Turning it off leaves the user a working toggle.
      await SettingsService.setCalendarSyncEnabled(false);
      if (mounted) setState(() => _calendarSyncEnabled = false);
    }
  }

  Future<bool?> _showDestructiveConfirmation({
    required String title,
    required String body,
    required String confirmLabel,
  }) {
    final cancelLabel = context.l10n.btnCancel;
    return showAppConfirmDialog(
      context: context,
      title: title,
      message: body,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      icon: Icons.warning_amber_rounded,
      isDestructive: true,
    );
  }

  Future<void> _onSubscriptionTap() async {
    final isPremium = await ref.read(subscriptionServiceProvider).isPremium();
    if (!mounted) return;
    if (isPremium) {
      // Send subscribers straight to Apple's subscription settings instead of
      // a toast telling them where to look.
      await LegalLinks.open(LegalLinks.manageSubscriptions);
    } else {
      final purchased = await showPaywallBottomSheet(context);
      if (purchased && mounted) ref.invalidate(isPremiumProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = ref.watch(isPremiumProvider).valueOrNull ?? false;

    return ProfileTemplate(
      userName: _userName,
      sessionReminderMinutes: _sessionReminderMinutes,
      deadlineReminderDays: _deadlineReminderDays,
      themeModeIndex: _themeModeIndex,
      subjects: _subjects,
      schoolName: _schoolName,
      isPremium: isPremium,
      showPrivacyOptions: _showPrivacyOptions,
      calendarSyncEnabled: _calendarSyncEnabled,
      planAroundCalendar: _planAroundCalendar,
      onPlanAroundCalendarTap: _togglePlanAroundCalendar,
      calendarSyncBusy: _calendarBusy,
      onCalendarSyncTap: _onCalendarSyncTap,
      onPrivacyOptions: AdService.showPrivacyOptionsForm,
      onSubscriptionTap: _onSubscriptionTap,
      onEditName: _editProfile,
      onSessionReminderTap: _pickSessionReminder,
      onDeadlineReminderTap: _pickDeadlineReminder,
      onThemeTap: _pickTheme,
      onDeleteSessions: _confirmDeleteSessions,
      onDeleteEverything: _confirmDeleteEverything,
      onAddSubject: _addSubject,
      onDeleteSubject: _deleteSubject,
    );
  }
}

