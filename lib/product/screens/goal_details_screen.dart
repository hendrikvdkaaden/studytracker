import 'package:flutter/material.dart';

import '../../models/goal.dart';
import '../../services/goal_dialog_service.dart';
import '../../services/goal_operations_service.dart';
import '../../widgets/goal_details_modern/edit_progress_dialog.dart';
import '../../widgets/goal_details_modern/goal_details_app_bar.dart';
import '../templates/goal_details_template.dart';

class GoalDetailsScreen extends StatefulWidget {
  final Goal goal;

  const GoalDetailsScreen({super.key, required this.goal});

  @override
  State<GoalDetailsScreen> createState() => _GoalDetailsScreenState();
}

class _GoalDetailsScreenState extends State<GoalDetailsScreen> {
  late Goal _goal;
  final GoalOperationsService _operationsService = GoalOperationsService();

  @override
  void initState() {
    super.initState();
    _goal = widget.goal;
  }

  Future<void> _toggleComplete() async {
    final updatedGoal = await _operationsService.toggleComplete(_goal);
    setState(() {
      _goal = updatedGoal;
    });
  }

  Future<void> _showEditProgressDialog() async {
    final timeSpent = _operationsService.getTotalStudyTime(_goal.id);

    await showDialog(
      context: context,
      builder: (context) => EditProgressDialog(
        initialTargetTimeMinutes: _goal.studyTime,
        initialTimeSpentMinutes: timeSpent,
        onSave: (targetTime, timeSpent) async {
          final updatedGoal = await _operationsService.updateProgress(
            goal: _goal,
            newTargetTimeMinutes: targetTime,
            newTimeSpentMinutes: timeSpent,
          );
          setState(() {
            _goal = updatedGoal;
          });
          if (!mounted) return;
          GoalDialogService.showSuccessMessage(
            context,
            'Progress updated successfully!',
          );
        },
      ),
    );
  }

  Future<void> _deleteGoal() async {
    final confirmed = await GoalDialogService.showDeleteConfirmation(context);

    if (!confirmed) return;

    await _operationsService.deleteGoal(_goal.id);

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timeSpent = _operationsService.getTotalStudyTime(_goal.id);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF102221) : const Color(0xFFF5F8F8),
      appBar: GoalDetailsAppBar(onDelete: _deleteGoal),
      body: GoalDetailsTemplate(
        goal: _goal,
        timeSpent: timeSpent,
        onEditProgress: _showEditProgressDialog,
        onMarkComplete: _toggleComplete,
      ),
    );
  }
}
