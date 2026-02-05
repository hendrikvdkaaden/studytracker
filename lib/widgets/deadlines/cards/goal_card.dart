import 'package:flutter/material.dart';
import '../../../models/goal.dart';
import '../../../utils/goal_type_helper.dart';
import 'study_progress_compact.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;
  final bool isOverdue;
  final bool isCompleted;
  final VoidCallback onTap;

  const GoalCard({
    super.key,
    required this.goal,
    this.isOverdue = false,
    this.isCompleted = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final daysLeft = goal.daysUntilDeadline();
    final color = isCompleted
        ? Colors.green
        : isOverdue
            ? Colors.red
            : daysLeft <= 3
                ? Colors.orange
                : Colors.blue;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(
            GoalTypeHelper.getIconForType(goal.type),
            color: color,
          ),
        ),
        title: Text(
          goal.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(goal.subject),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  isCompleted ? Icons.check_circle : Icons.calendar_today,
                  size: 14,
                  color: color,
                ),
                const SizedBox(width: 4),
                Text(
                  isCompleted
                      ? 'Completed'
                      : isOverdue
                          ? '${daysLeft.abs()} days overdue'
                          : '$daysLeft days left',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (goal.studyTime > 0) ...[
              const SizedBox(height: 8),
              StudyProgressCompact(goal: goal),
            ],
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
