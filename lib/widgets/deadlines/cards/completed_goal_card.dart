import 'package:flutter/material.dart';
import '../../../models/goal.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme_extension.dart';
import '../../../utils/goal_type_helper.dart';

class CompletedGoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback onTap;

  const CompletedGoalCard({
    super.key,
    required this.goal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = context.colors.textTertiary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.colors.sectionBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: context.colors.isDark
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
                color: context.colors.isDark
                    ? AppColors.completed.withValues(alpha: 0.1)
                    : AppColors.completed.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                GoalTypeHelper.getIconForType(goal.type),
                color: AppColors.completed,
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
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: titleColor,
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
              height: 28,
              width: 28,
              decoration: BoxDecoration(
                color: AppColors.completed.withValues(alpha: context.colors.isDark ? 0.15 : 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: AppColors.completed,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
