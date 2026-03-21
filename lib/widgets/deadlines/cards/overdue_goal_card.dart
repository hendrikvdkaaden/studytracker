import 'package:flutter/material.dart';
import '../../../models/goal.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/goal_type_helper.dart';

class OverdueGoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback onTap;

  const OverdueGoalCard({
    super.key,
    required this.goal,
    required this.onTap,
  });

  int _getDaysOverdue() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deadline = DateTime(goal.date.year, goal.date.month, goal.date.day);
    return today.difference(deadline).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final daysOverdue = _getDaysOverdue();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.sectionDarkBg : AppColors.sectionLightBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : AppColors.lightBorder,
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.overdue.withValues(alpha: 0.1)
                    : AppColors.overdue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                GoalTypeHelper.getIconForType(goal.type),
                color: AppColors.overdue,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    goal.subject,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.overdue.withValues(alpha: 0.1)
                    : AppColors.overdue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.history,
                    size: 13,
                    color: AppColors.overdue,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$daysOverdue day${daysOverdue != 1 ? 's' : ''} overdue',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.overdue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
