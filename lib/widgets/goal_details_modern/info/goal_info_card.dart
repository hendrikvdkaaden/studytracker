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
    final color = accentColor
        ?? SettingsService.colorForSubject(goal.subject)
        ?? AppColors.calendarAccent;

    final sectionBg = isDark ? AppColors.darkFieldBackground : AppColors.lightFieldBackground;
    final subtleText = isDark ? Colors.grey[400]! : Colors.grey[500]!;
    final textColor = isDark ? Colors.white : const Color(0xFF111827);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isDark
                    ? color.withValues(alpha: 0.15)
                    : color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                GoalTypeHelper.getIconForType(goal.type),
                size: 17,
                color: color,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'GOAL INFO',
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
        // Content field
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
                        goal.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${goal.subject} • ${GoalTypeHelper.getLabel(goal.type)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
                  Icon(Icons.chevron_right, color: subtleText, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
