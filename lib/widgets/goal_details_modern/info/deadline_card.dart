import 'package:flutter/material.dart';

import '../../../models/goal.dart';
import '../../../theme/app_colors.dart';

class DeadlineCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback? onTap;

  const DeadlineCard({
    super.key,
    required this.goal,
    this.onTap,
  });

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final daysLeft = goal.daysUntilDeadline();
    final isOverdue = goal.isOverdue();
    final isCompleted = goal.isCompleted;
    final showWarning = !isCompleted && (isOverdue || daysLeft <= 2);

    String daysLeftText;
    if (isCompleted) {
      daysLeftText = 'Completed';
    } else if (isOverdue) {
      daysLeftText = '${daysLeft.abs()} day${daysLeft.abs() == 1 ? '' : 's'} overdue';
    } else if (daysLeft == 0) {
      daysLeftText = 'Due today';
    } else if (daysLeft == 1) {
      daysLeftText = '1 day left';
    } else {
      daysLeftText = '$daysLeft days left';
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            color: isDark ? AppColors.calendarDarkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.calendarAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isCompleted ? Icons.check_circle : Icons.calendar_today,
                    color: isCompleted
                        ? AppColors.completed
                        : isDark ? AppColors.calendarAccent : AppColors.darkText,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // Deadline info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Deadline: ${_formatDate(goal.date)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.lightText : AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        daysLeftText,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isCompleted
                              ? AppColors.completed
                              : isOverdue
                                  ? AppColors.overdue
                                  : AppColors.upcoming,
                        ),
                      ),
                    ],
                  ),
                ),
                // Trailing icons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showWarning)
                      const Icon(
                        Icons.error,
                        color: AppColors.overdue,
                        size: 22,
                      ),
                    if (onTap != null && !isCompleted) ...[
                      if (showWarning) const SizedBox(width: 4),
                      const Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: AppColors.upcoming,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
