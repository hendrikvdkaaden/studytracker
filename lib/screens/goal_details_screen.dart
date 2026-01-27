import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../services/goal_repository.dart';
import '../widgets/goal_details/status_banner.dart';
import '../widgets/goal_details/goal_info_list.dart';
import '../widgets/goal_details/complete_button.dart';

class GoalDetailsScreen extends StatefulWidget {
  final Goal goal;

  const GoalDetailsScreen({super.key, required this.goal});

  @override
  State<GoalDetailsScreen> createState() => _GoalDetailsScreenState();
}

class _GoalDetailsScreenState extends State<GoalDetailsScreen> {
  late Goal _goal;
  final GoalRepository _goalRepo = GoalRepository();

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
    final daysLeft = _goal.daysUntilDeadline();
    final isOverdue = _goal.isOverdue();
    final color = isOverdue
        ? Colors.red
        : daysLeft <= 3
            ? Colors.orange
            : Colors.blue;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Goal Details'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteGoal,
            color: Colors.red,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StatusBanner(
              isCompleted: _goal.isCompleted,
              isOverdue: isOverdue,
              daysLeft: daysLeft,
              color: color,
            ),
            const SizedBox(height: 24),
            Text(
              _goal.title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            GoalInfoList(
              goal: _goal,
              color: color,
            ),
            const SizedBox(height: 32),
            CompleteButton(
              isCompleted: _goal.isCompleted,
              onPressed: _toggleComplete,
            ),
          ],
        ),
      ),
    );
  }
}
