import 'package:flutter/material.dart';
import '../../../models/goal.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/goal_type_helper.dart';

class GoalInfoCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback? onTap;

  const GoalInfoCard({
    super.key,
    required this.goal,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.calendarAccent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    GoalTypeHelper.getIconForType(goal.type),
                    color: isDark ? AppColors.calendarAccent : AppColors.darkText,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                // Title and Subject
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.lightText : AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${goal.subject} • ${GoalTypeHelper.getLabel(goal.type)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.upcoming,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
                  const Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: AppColors.upcoming,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
