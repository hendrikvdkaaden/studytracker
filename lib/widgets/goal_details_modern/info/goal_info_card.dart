import 'package:flutter/material.dart';
import '../../../models/goal.dart';
import '../../../services/settings_service.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/goal_type_helper.dart';

class GoalInfoCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback? onTap;
  final Color? accentColor;

  const GoalInfoCard({
    super.key,
    required this.goal,
    this.onTap,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Use provided color, fall back to lookup, fall back to default
    final color = accentColor
        ?? SettingsService.colorForSubject(goal.subject)
        ?? AppColors.calendarAccent;

    final cardColor = isDark ? AppColors.calendarDarkCard : AppColors.lightCard;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    GoalTypeHelper.getIconForType(goal.type),
                    color: color,
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
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
                  Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: color,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
