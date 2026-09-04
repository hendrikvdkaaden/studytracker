import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../models/goal.dart';
import '../../models/study_session.dart';
import '../../providers/app_providers.dart';
import '../../services/auto_planner_service.dart';
import '../../services/calendar_sync_service.dart';
import '../../services/goal_repository.dart';
import '../../services/notification_service.dart';
import '../../services/settings_service.dart';
import '../../services/subscription_service.dart';
import '../../services/study_session_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme_extension.dart';
import '../../utils/format_helpers.dart';
import '../../utils/l10n_extension.dart';
import '../../widgets/add_goal/pickers/auto_plan_wizard_modal.dart';
import '../../widgets/add_goal/pickers/study_session_picker_modal.dart';
import '../../widgets/add_goal/pickers/time_picker_modal.dart';
import '../../widgets/common/app_dialog.dart';
import '../../widgets/common/premium_gate_bottom_sheet.dart';
import '../templates/add_goal_template.dart';

class AddGoalScreen extends ConsumerStatefulWidget {
  /// Day to start the deadline on. Used when adding from a screen that is
  /// already showing a particular day, so the form opens on that day instead
  /// of the default a week out.
  final DateTime? initialDate;

  const AddGoalScreen({super.key, this.initialDate});

  @override
  ConsumerState<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends ConsumerState<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subjectController = TextEditingController();
  GoalRepository get _goalRepo => ref.read(goalRepositoryProvider);
  StudySessionRepository get _sessionRepo => ref.read(studySessionRepositoryProvider);

  // New deadlines default to midday; the user can change the time explicitly.
  late DateTime _selectedDate;

  static DateTime _atNoon(DateTime d) => DateTime(d.year, d.month, d.day, 12, 0);
  GoalType _selectedType = GoalType.exam;
  final List<StudySession> _plannedSessions = [];
  List<SubjectData> _subjects = [];
  String? _selectedSubject;

  @override
  void initState() {
    super.initState();
    _selectedDate = _atNoon(
      widget.initialDate ?? DateTime.now().add(const Duration(days: 7)),
    );
    _subjects = SettingsService.subjectData;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    // Adding from a past day on the home screen puts the deadline before
    // today; showDatePicker asserts when its initial date falls outside the
    // range, so the bounds have to stretch around it.
    final first = _selectedDate.isBefore(now) ? _selectedDate : now;
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: first,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        // Keep the time the user picked; showDatePicker returns midnight.
        _selectedDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          _selectedDate.hour,
          _selectedDate.minute,
        );
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePickerModal(
      context: context,
      initialHour: _selectedDate.hour,
      initialMinute: _selectedDate.minute,
    );

    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  int _calculateTotalStudyTime() {
    int totalMinutes = 0;
    for (var session in _plannedSessions) {
      totalMinutes += session.duration;
    }
    return totalMinutes;
  }

  Future<void> _showStudySessionPicker() async {
    FocusScope.of(context).unfocus();
    await showStudySessionPicker(
      context: context,
      existingSessions: _plannedSessions,
      deadline: _selectedDate,
      onSessionAdded: (session) {
        setState(() {
          _plannedSessions.add(session);
          _sortSessions();
        });
      },
    );
    if (mounted) FocusScope.of(context).unfocus();
  }

  void _sortSessions() {
    _plannedSessions.sort((a, b) {
      final dateCompare = a.date.compareTo(b.date);
      if (dateCompare != 0) return dateCompare;
      final aStart = a.startTime;
      final bStart = b.startTime;
      if (aStart == null && bStart == null) return 0;
      if (aStart == null) return 1;
      if (bStart == null) return -1;
      return aStart.compareTo(bStart);
    });
  }

  void _deleteSession(int index) {
    setState(() {
      _plannedSessions.removeAt(index);
    });
  }

  Future<void> _editSession(int index) async {
    FocusScope.of(context).unfocus();
    await showStudySessionEditor(
      context: context,
      session: _plannedSessions[index],
      existingSessions: _plannedSessions,
      deadline: _selectedDate,
      onSessionUpdated: (updated) {
        setState(() {
          _plannedSessions[index] = updated;
          _sortSessions();
        });
      },
    );
  }

  void _onSubjectSelected(String subject) {
    setState(() => _selectedSubject = subject);
  }

  Future<void> _autoPlanSessions() async {
    final isPremium = await ref.read(subscriptionServiceProvider).isPremium();
    if (!mounted) return;
    if (!isPremium) {
      final outcome = await showPremiumGateSheet(
        context,
        title: context.l10n.premiumAutoPlanTitle,
        message: context.l10n.premiumAutoPlanMessage,
        // The auto-plan reward is one try a day, so the option is only worth
        // offering while today's is unspent.
        allowAdReward: SettingsService.canUseAdTrialToday,
      );
      if (outcome == PremiumGateResult.dismissed || !mounted) return;

      if (outcome == PremiumGateResult.adReward) {
        // Only spend the daily allowance once the reward was actually earned.
        await SettingsService.setLastAdTrialDate(DateTime.now());
      } else {
        ref.invalidate(isPremiumProvider);
      }
    }

    if (!mounted) return;
    final result = await showAutoPlanWizard(context: context);
    if (result == null || !mounted) return;

    // Sessions added in this screen are not saved yet, so they must be passed
    // in explicitly or the planner would schedule straight over them.
    final existing = [
      ..._sessionRepo.getAllPlannedSessions(),
      ..._plannedSessions,
    ];

    // The planner starts tomorrow, so now is a safe lower bound; the deadline
    // day is inclusive, hence the extra day on top.
    final busy = result.avoidCalendarEvents
        ? await CalendarSyncService.busyBlocks(
            from: DateTime.now(),
            to: _selectedDate.add(const Duration(days: 1)),
          )
        : const <BusyBlock>[];
    if (!mounted) return;

    final generated = AutoPlannerService.generateSessions(
      goalId: '',
      deadline: _selectedDate,
      totalMinutes: result.totalMinutes,
      weekdays: result.weekdays,
      startHour: result.startHour,
      startMinute: result.startMinute,
      endHour: result.endHour,
      endMinute: result.endMinute,
      sessionDuration: result.sessionDuration,
      breakMinutes: result.breakMinutes,
      existingSessions: existing,
      busyBlocks: busy,
    );

    if (!mounted) return;

    if (generated.isEmpty) {
      // The wizard has already closed, so there is no inline slot left for
      // this: a dialog is the only way the user learns nothing was planned.
      await showAppMessageDialog(
        context: context,
        message: context.l10n.autoPlanErrorNoAvailableDays,
        icon: Icons.event_busy_outlined,
      );
      return;
    }

    setState(() {
      // Append rather than replace: sessions the user planned by hand stay.
      _plannedSessions.addAll(generated);
      _sortSessions();
    });
  }

  Future<void> _saveGoal() async {
    if (_formKey.currentState!.validate()) {
      final isPremium = await ref.read(subscriptionServiceProvider).isPremium();
      if (!mounted) return;
      if (!isPremium) {
        final goals = _goalRepo.getAllGoals();
        if (goals.length >= SubscriptionService.goalLimitWithEarned) {
          final outcome = await showPremiumGateSheet(
            context,
            title: context.l10n.premiumGoalLimitTitle,
            message: context.l10n.premiumGoalLimitMessage,
            allowAdReward: true,
            adRewardLabel: context.l10n.premiumDialogWatchAdForDeadline,
          );
          if (outcome == PremiumGateResult.dismissed || !mounted) return;

          if (outcome == PremiumGateResult.adReward) {
            // One ad buys one deadline. Unlike the auto-plan trial this is a
            // count, not a daily allowance: the deadline it unlocks stays.
            await SettingsService.addEarnedGoalSlot();
          } else {
            ref.invalidate(isPremiumProvider);
          }
        }
      }

      final totalMinutes = _calculateTotalStudyTime();
      final subjectValue = _subjects.isNotEmpty
          ? (_selectedSubject ?? '')
          : _subjectController.text;

      final goal = Goal(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        subject: subjectValue,
        date: _selectedDate,
        type: _selectedType,
        studyTime: totalMinutes,
      );

      // Save goal first
      await _goalRepo.addGoal(goal);

      // Save planned sessions with the goal ID
      final savedSessions = <StudySession>[];
      for (var session in _plannedSessions) {
        final sessionWithGoalId = session.copyWith(goalId: goal.id);
        await _sessionRepo.addSession(sessionWithGoalId);
        savedSessions.add(sessionWithGoalId);
        await NotificationService.scheduleSessionReminder(
          sessionWithGoalId,
          goal.title,
        );
      }

      // Schedule deadline reminder
      await NotificationService.scheduleDeadlineReminder(goal);

      // Mirror to the device calendar. No-ops when the user has sync off.
      await _syncToCalendar(goal, savedSessions);

      if (!mounted) return;

      Navigator.pop(context);
    }
  }


  /// Writes the new deadline and its sessions to the device calendar, storing
  /// the returned event ids so they can be updated or removed later.
  Future<void> _syncToCalendar(Goal goal, List<StudySession> sessions) async {
    if (!CalendarSyncService.isEnabled) return;

    final deadlineEventId = await CalendarSyncService.syncDeadline(goal);
    if (deadlineEventId != null) {
      await _goalRepo.updateGoal(goal.copyWith(calendarEventId: deadlineEventId));
    }

    final eventIds = await CalendarSyncService.syncSessions(
      sessions,
      goal.title,
      goal.subject,
    );
    for (final session in sessions) {
      final eventId = eventIds[session.id];
      if (eventId == null) continue;
      await _sessionRepo.updateSession(
        session.copyWith(calendarEventId: eventId),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: _buildAppBar(context),
      body: AddGoalTemplate(
        formKey: _formKey,
        titleController: _titleController,
        subjectController: _subjectController,
        selectedDate: _selectedDate,
        selectedType: _selectedType,
        formattedDate: FormatHelpers.formatDate(_selectedDate),
        formattedTime: FormatHelpers.formatTimeOfDay(
          _selectedDate.hour,
          _selectedDate.minute,
        ),
        plannedSessions: _plannedSessions,
        subjects: _subjects,
        selectedSubject: _selectedSubject,
        onSubjectSelected: _onSubjectSelected,
        onTypeSelected: (type) => setState(() => _selectedType = type),
        onDateTap: () => _selectDate(context),
        onTimeTap: () => _selectTime(context),
        onSessionTap: _showStudySessionPicker,
        onAutoplan: _autoPlanSessions,
        onSessionDelete: _deleteSession,
        onSessionEdit: _editSession,
        onSave: _saveGoal,
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: context.colors.background,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: context.colors.textPrimary,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        context.l10n.addGoalScreenTitle,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: context.colors.textPrimary,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: context.colors.divider,
          height: 1,
        ),
      ),
    );
  }
}
