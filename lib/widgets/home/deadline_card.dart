import 'package:flutter/material.dart';
import '../../models/goal.dart';
import '../../theme/app_colors.dart';

class HomeDeadlineCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback onTap;

  const HomeDeadlineCard({
    super.key,
    required this.goal,
    required this.onTap,
  });

  Color _getBorderColor() {
    if (goal.isOverdue()) {
      return AppColors.overdue;
    }
    return Colors.amber;
  }

  String _getPriorityLabel() {
    if (goal.isOverdue()) {
      return 'Urgent Priority';
    }
    switch (goal.difficulty) {
      case Difficulty.veryHard:
        return 'High Priority';
      case Difficulty.hard:
        return 'Important';
      default:
        return 'Scheduled';
    }
  }

  String _getTimeInfo() {
    if (goal.isOverdue()) {
      final daysOverdue = -goal.daysUntilDeadline();
      return daysOverdue == 0 ? 'Due today' : 'Overdue by $daysOverdue days';
    }
    return 'Due at 11:59 PM';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = _getBorderColor();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border(
            left: BorderSide(
              color: borderColor,
              width: 4,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getPriorityLabel().toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: borderColor,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              goal.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 18,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                const SizedBox(width: 6),
                Text(
                  _getTimeInfo(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
