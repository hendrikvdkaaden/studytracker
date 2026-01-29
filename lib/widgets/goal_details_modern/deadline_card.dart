import 'package:flutter/material.dart';
import '../../models/goal.dart';

class DeadlineCard extends StatelessWidget {
  final Goal goal;

  const DeadlineCard({
    super.key,
    required this.goal,
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

    String daysLeftText;
    if (isOverdue) {
      daysLeftText = '${daysLeft.abs()} day${daysLeft.abs() == 1 ? '' : 's'} overdue';
    } else if (daysLeft == 0) {
      daysLeftText = 'Due today';
    } else if (daysLeft == 1) {
      daysLeftText = '1 day left';
    } else {
      daysLeftText = '$daysLeft days left';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2E2D) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF0DF2DF).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.calendar_today,
              color: isDark ? const Color(0xFF0DF2DF) : const Color(0xFF0D1C1B),
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
                    color: isDark ? Colors.white : const Color(0xFF0D1C1B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  daysLeftText,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isOverdue ? const Color(0xFFFF5C5C) : const Color(0xFF499C95),
                  ),
                ),
              ],
            ),
          ),
          // Warning icon if overdue or soon
          if (isOverdue || daysLeft <= 2)
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error,
                color: Color(0xFFFF5C5C),
                size: 28,
              ),
            ),
        ],
      ),
    );
  }
}
