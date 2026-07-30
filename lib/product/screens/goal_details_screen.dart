import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/goal.dart';
import '../../theme/app_colors.dart';
import '../../models/study_session.dart';
import '../../providers/app_providers.dart';
import '../../services/auto_planner_service.dart';
import '../../services/goal_dialog_service.dart';
import '../../services/goal_operations_service.dart';
import '../../services/notification_service.dart';
import '../../services/study_session_repository.dart';
import '../../utils/l10n_extension.dart';
import '../../widgets/goal_details_modern/actions/goal_details_app_bar.dart';
import '../../widgets/goal_details_modern/progress/edit_progress_dialog.dart';
import '../../widgets/goal_details_modern/info/goal_info_edit_modal.dart';
import '../../widgets/add_goal/pickers/auto_plan_wizard_modal.dart';
import '../../widgets/add_goal/pickers/study_session_picker_modal.dart';
import '../../widgets/common/premium_gate_bottom_sheet.dart';
import '../templates/goal_details_template.dart';

class GoalDetailsScreen extends ConsumerStatefulWidget {
  final Goal goal;

  const GoalDetailsScreen({super.key, required this.goal});

  @override
  ConsumerState<GoalDetailsScreen> createState() => _GoalDetailsScreenState();
}

class _GoalDetailsScreenState extends ConsumerState<GoalDetailsScreen> {
  late Goal _goal;
  late int _timeSpent;
  late List<StudySession> _plannedSessions;

  GoalOperationsService get _operationsService => ref.read(goalOperationsServiceProvider);
  StudySessionRepository get _sessionRepo => ref.read(studySessionRepositoryProvider);

  @override
  void initState() {
    super.initState();
    _goal = widget.goal;
    _refreshData();
  }

  void _refreshData() {
    _timeSpent = _operationsService.getTotalStudyTime(_goal.id);
    final planned = _sessionRepo.getPlannedSessionsByGoalId(_goal.id);
    final completed = _sessionRepo.getCompletedSessionsByGoalId(_goal.id);
    _plannedSessions = [...planned, ...completed]
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  Future<void> _toggleComplete() async {
    final updatedGoal = await _operationsService.toggleComplete(_goal);
    if (!mounted) return;
    _goal = updatedGoal;
    _refreshData();
    setState(() {});
  }

  Future<void> _showEditProgressDialog() async {
    await showDialog(
      context: context,
      builder: (dialogContext) => EditProgressDialog(
        initialTargetTimeMinutes: _goal.studyTime,
        initialTimeSpentMinutes: _timeSpent,
        onSave: (targetTime, timeSpent) async {
          final updatedGoal = await _operationsService.updateProgress(
            goal: _goal,
            newTargetTimeMinutes: targetTime,
            newTimeSpentMinutes: timeSpent,
          );
          if (!mounted) return;
          _goal = updatedGoal;
          _refreshData();
          setState(() {});
          GoalDialogService.showSuccessMessage(
            context,
            'Progress updated successfully!',
          );
        },
      ),
    );
  }

  Future<void> _showEditInfoModal() async {
    final updated = await showGoalInfoEditModal(context, _goal);
    if (updated == null) return;

    await _operationsService.updateGoalData(updated);
    if (!mounted) return;
    setState(() {
      _goal = updated;
      _refreshData();
    });
  }

  Future<void> _pickDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _goal.date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date == null) return;

    final updated = _goal.copyWith(date: date);
    await _operationsService.updateGoalData(updated);
    if (!mounted) return;
    setState(() {
      _goal = updated;
      _refreshData();
    });
  }

  Future<void> _deleteGoal() async {
    final confirmed = await GoalDialogService.showDeleteConfirmation(context);
    if (!confirmed) return;

    await NotificationService.cancelGoalNotifications(_goal.id, _plannedSessions);
    await _operationsService.deleteGoal(_goal.id);

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Future<void> _editSession(StudySession session) async {
    await showStudySessionEditor(
      context: context,
      session: session,
      existingSessions: _plannedSessions,
      deadline: _goal.date,
      onSessionUpdated: (updated) async {
        await _sessionRepo.updateSession(updated);
        await Future.wait([
          NotificationService.cancelSessionNotification(updated.id),
          NotificationService.scheduleSessionReminder(updated, _goal.title),
        ]);
        if (!mounted) return;
        setState(() => _refreshData());
      },
    );
  }

  Future<void> _deleteSession(StudySession session) async {
    await NotificationService.cancelSessionNotification(session.id);
    await _sessionRepo.deleteSession(session.id);
    if (!mounted) return;
    setState(() => _refreshData());
  }

  Future<void> _addSession() async {
    await showStudySessionPicker(
      context: context,
      existingSessions: _plannedSessions,
      deadline: _goal.date,
      onSessionAdded: (session) async {
        final sessionWithGoalId = session.copyWith(goalId: _goal.id);
        await _sessionRepo.addSession(sessionWithGoalId);
        await NotificationService.scheduleSessionReminder(
          sessionWithGoalId,
          _goal.title,
        );

        if (!mounted) return;
        setState(() => _refreshData());

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Study session added!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  Future<void> _autoPlanSessions() async {
    final isPremium = await ref.read(subscriptionServiceProvider).isPremium();
    if (!mounted) return;
    if (!isPremium) {
      final purchased = await showPremiumGateSheet(
        context,
        title: context.l10n.premiumAutoPlanTitle,
        message: context.l10n.premiumAutoPlanMessage,
      );
      if (!purchased || !mounted) return;
    }

    if (!mounted) return;
    final result = await showAutoPlanWizard(context: context);
    if (result == null || !mounted) return;

    final generated = AutoPlannerService.generateSessions(
      goalId: _goal.id,
      deadline: _goal.date,
      totalMinutes: result.totalMinutes,
      weekdays: result.weekdays,
      startHour: result.startHour,
      startMinute: result.startMinute,
      endHour: result.endHour,
      endMinute: result.endMinute,
      sessionDuration: result.sessionDuration,
      breakMinutes: result.breakMinutes,
      existingSessions: _plannedSessions,
    );

    if (!mounted) return;
    if (generated.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.autoPlanErrorNoAvailableDays),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    for (final session in generated) {
      await _sessionRepo.addSession(session);
      await NotificationService.scheduleSessionReminder(session, _goal.title);
    }

    if (!mounted) return;
    setState(() => _refreshData());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.autoPlanSuccessSnack(generated.length)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      appBar: GoalDetailsAppBar(onDelete: _deleteGoal),
      body: GoalDetailsTemplate(
        goal: _goal,
        timeSpent: _timeSpent,
        plannedSessions: _plannedSessions,
        onEditProgress: _showEditProgressDialog,
        onMarkComplete: _toggleComplete,
        onAddSession: _addSession,
        onAutoplan: _autoPlanSessions,
        onEditSession: _editSession,
        onDeleteSession: _deleteSession,
        onEditInfo: _showEditInfoModal,
        onEditDeadline: _pickDeadline,
      ),
    );
  }
}
