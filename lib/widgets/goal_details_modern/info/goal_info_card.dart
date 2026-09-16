import 'package:flutter/material.dart';
import '../../../models/goal.dart';
import '../../../services/settings_service.dart';
import '../../../theme/app_theme_extension.dart';
import '../../../utils/goal_type_helper.dart';
import '../../../utils/l10n_extension.dart';

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
    final color = accentColor
        ?? SettingsService.colorForSubject(goal.subject)
        ?? context.colors.accentStrong;

    final sectionBg = context.colors.fieldBackground;
    final subtleText = context.colors.textSecondary;
    final textColor = context.colors.textPrimary;

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
                color: context.colors.statusTint(color,
                    darkAlpha: 0.15, lightAlpha: 0.12),
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
              context.l10n.goalInfoCardLabel,
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
                color: context.colors.border,
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
                        '${goal.subject} • ${GoalTypeHelper.getLocalizedLabel(context, goal.type)}',
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
