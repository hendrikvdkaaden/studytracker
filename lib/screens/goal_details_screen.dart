import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/goal.dart';
import '../models/study_session.dart';
import '../services/goal_repository.dart';
import '../services/study_session_repository.dart';
import '../widgets/goal_details_modern/goal_info_card.dart';
import '../widgets/goal_details_modern/deadline_card.dart';
import '../widgets/goal_details_modern/progress_circle.dart';
import '../widgets/goal_details_modern/action_buttons.dart';
import '../widgets/goal_details_modern/edit_progress_dialog.dart';

class GoalDetailsScreen extends StatefulWidget {
  final Goal goal;

  const GoalDetailsScreen({super.key, required this.goal});

  @override
  State<GoalDetailsScreen> createState() => _GoalDetailsScreenState();
}

class _GoalDetailsScreenState extends State<GoalDetailsScreen> {
  late Goal _goal;
  final GoalRepository _goalRepo = GoalRepository();
  final StudySessionRepository _sessionRepo = StudySessionRepository();

  @override
  void initState() {
    super.initState();
    _goal = widget.goal;
  }

  void _toggleComplete() async {
    setState(() {
      _goal = _goal.copyWith(isCompleted: !_goal.isCompleted);
    });
    await _goalRepo.updateGoal(_goal);
  }

  Future<void> _showEditProgressDialog() async {
    final timeSpent = _sessionRepo.getTotalStudyTimeForGoal(_goal.id);

    await showDialog(
      context: context,
      builder: (context) => EditProgressDialog(
        initialTargetTimeMinutes: _goal.studyTime,
        initialTimeSpentMinutes: timeSpent,
        onSave: (targetTime, timeSpent) async {
          // Update goal's target time
          final updatedGoal = _goal.copyWith(studyTime: targetTime);
          await _goalRepo.updateGoal(updatedGoal);
          // Calculate difference in time spent and adjust sessions
          final currentTimeSpent = _sessionRepo.getTotalStudyTimeForGoal(_goal.id);
          final difference = timeSpent - currentTimeSpent;
          if (difference != 0) {
            // Create adjustment session
            final adjustmentSession = StudySession(
              id: const Uuid().v4(),
              goalId: _goal.id,
              date: DateTime.now(),
              duration: difference,
            );
            await _sessionRepo.addSession(adjustmentSession);
          }
          // Update local state
          setState(() {
            _goal = updatedGoal;
          });
          if (!mounted) return;
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Progress updated successfully!'),
              backgroundColor: Color(0xFF0DF2DF),
            ),
          );
        },
      ),
    );
  }

  void _deleteGoal() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Goal'),
        content: const Text('Are you sure you want to delete this goal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              await _goalRepo.deleteGoal(_goal.id);
              if (mounted) {
                navigator.pop(); // Close dialog
                navigator.pop(true); // Go back to home screen with result
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timeSpent = _sessionRepo.getTotalStudyTimeForGoal(_goal.id);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF102221) : const Color(0xFFF5F8F8),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF102221) : const Color(0xFFF5F8F8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Goal Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.015,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _deleteGoal,
            color: Colors.red,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Goal Info Card
            Padding(
              padding: const EdgeInsets.all(16),
              child: GoalInfoCard(goal: _goal),
            ),
            // Deadline Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: DeadlineCard(goal: _goal),
            ),
            // Progress Overview Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.015,
                      color: isDark ? Colors.white : const Color(0xFF0D1C1B),
                    ),
                  ),
                  GestureDetector(
                    onTap: _showEditProgressDialog,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0DF2DF).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.edit,
                        size: 18,
                        color: isDark ? const Color(0xFF0DF2DF) : const Color(0xFF0D1C1B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Circular Progress
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ProgressCircle(
                timeSpent: timeSpent,
                targetTime: _goal.studyTime,
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: ActionButtons(
                onMarkComplete: _toggleComplete,
                isCompleted: _goal.isCompleted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
