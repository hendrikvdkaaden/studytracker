import 'package:flutter/material.dart';

import '../../models/goal.dart';
import '../../theme/app_colors.dart';
import '../../models/study_session.dart';
import '../../services/goal_dialog_service.dart';
import '../../services/goal_operations_service.dart';
import '../../services/notification_service.dart';
import '../../services/study_session_repository.dart';
import '../../widgets/goal_details_modern/actions/goal_details_app_bar.dart';
import '../../widgets/goal_details_modern/progress/edit_progress_dialog.dart';
import '../../widgets/goal_details_modern/info/goal_info_edit_modal.dart';
import '../../widgets/add_goal/pickers/study_session_picker_modal.dart';
import '../templates/goal_details_template.dart';

class GoalDetailsScreen extends StatefulWidget {
  final Goal goal;

  const GoalDetailsScreen({super.key, required this.goal});

  @override
  State<GoalDetailsScreen> createState() => _GoalDetailsScreenState();
}

class _GoalDetailsScreenState extends State<GoalDetailsScreen> {
  late Goal _goal;
  late int _timeSpent;
  late List<StudySession> _plannedSessions;

  final GoalOperationsService _operationsService = GoalOperationsService();
  final StudySessionRepository _sessionRepo = StudySessionRepository();

  @override
  void initState() {
    super.initState();
    _goal = widget.goal;
    _refreshData();
  }

  void _refreshData() {
    _timeSpent = _operationsService.getTotalStudyTime(_goal.id);
    _plannedSessions = _sessionRepo.getPlannedSessionsByGoalId(_goal.id);
  }

  Future<void> _toggleComplete() async {
    final updatedGoal = await _operationsService.toggleComplete(_goal);
    if (!mounted) return;
    setState(() {
      _goal = updatedGoal;
      _refreshData();
    });
  }

  Future<void> _showEditProgressDialog() async {
    final screenContext = context;
    await showDialog(
      context: screenContext,
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
          setState(() {
            _goal = updatedGoal;
            _refreshData();
          });
          if (!mounted) return;
          GoalDialogService.showSuccessMessage(
            screenContext,
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

  Future<void> _addSession() async {
    await showStudySessionPicker(
      context: context,
      existingSessions: _plannedSessions,
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF102221) : const Color(0xFFF5F8F8),
      appBar: GoalDetailsAppBar(onDelete: _deleteGoal),
      body: GoalDetailsTemplate(
        goal: _goal,
        timeSpent: _timeSpent,
        plannedSessions: _plannedSessions,
        onEditProgress: _showEditProgressDialog,
        onMarkComplete: _toggleComplete,
        onAddSession: _addSession,
        onEditInfo: _showEditInfoModal,
        onEditDeadline: _pickDeadline,
      ),
    );
  }
}
