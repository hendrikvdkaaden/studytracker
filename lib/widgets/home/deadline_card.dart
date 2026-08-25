import 'package:flutter/material.dart';
import '../../models/goal.dart';
import '../../services/settings_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme_extension.dart';

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
    return AppColors.warning;
  }

  String _getPriorityLabel() {
    return goal.isOverdue() ? 'Urgent Priority' : 'Scheduled';
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
    final subjectColor = SettingsService.colorForSubject(goal.subject);
    final borderColor = subjectColor ?? _getBorderColor();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border(
            left: BorderSide(
              color: borderColor,
              width: 4,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
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
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 18,
                  color: context.colors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  _getTimeInfo(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: context.colors.textSecondary,
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
