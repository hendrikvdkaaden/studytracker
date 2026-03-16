import 'package:flutter/material.dart';

import '../../../models/goal.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/format_helpers.dart';

class DeadlineCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback? onTap;

  const DeadlineCard({
    super.key,
    required this.goal,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final daysLeft = goal.daysUntilDeadline();
    final isOverdue = goal.isOverdue();
    final isCompleted = goal.isCompleted;

    final sectionBg = isDark ? AppColors.darkFieldBackground : AppColors.lightFieldBackground;
    final subtleText = isDark ? Colors.grey[400]! : Colors.grey[500]!;
    final textColor = isDark ? Colors.white : const Color(0xFF111827);

    String statusText;
    Color statusColor;
    if (isCompleted) {
      statusText = 'Completed';
      statusColor = AppColors.completed;
    } else if (isOverdue) {
      final days = daysLeft.abs();
      statusText = '$days day${days == 1 ? '' : 's'} overdue';
      statusColor = AppColors.overdue;
    } else if (daysLeft == 0) {
      statusText = 'Today';
      statusColor = AppColors.upcoming;
    } else if (daysLeft == 1) {
      statusText = 'Tomorrow';
      statusColor = AppColors.upcoming;
    } else {
      statusText = '$daysLeft days left';
      statusColor = AppColors.upcoming;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFFEA6C0A).withValues(alpha: 0.15)
                    : const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.calendar_month,
                size: 17,
                color: Color(0xFFEA6C0A),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'DEADLINE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
                color: subtleText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Clickable field
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: sectionBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : const Color(0xFFE5E7EB),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        FormatHelpers.formatDate(goal.date),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onTap != null && !isCompleted)
                  Icon(Icons.chevron_right, color: subtleText, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
