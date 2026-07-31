import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme_extension.dart';
import '../../../utils/l10n_extension.dart';

class ProgressSectionHeader extends StatelessWidget {
  final VoidCallback onEdit;

  const ProgressSectionHeader({
    super.key,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final subtleText = context.colors.textSecondary;

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: context.colors.isDark
                ? Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.12)
                : AppColors.iconBgTeal,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.trending_up,
            size: 17,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            context.l10n.goalInfoProgressLabel,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              color: subtleText,
            ),
          ),
        ),
        GestureDetector(
          onTap: onEdit,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: context.colors.iconChipBackground(
                AppColors.primary,
                AppColors.iconBgTeal,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: context.colors.isDark
                    ? AppColors.primary.withValues(alpha: 0.3)
                    : AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.edit_outlined,
                  size: 14,
                  color: context.colors.isDark
                      ? AppColors.primary.withValues(alpha: 0.9)
                      : AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  context.l10n.btnEdit,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: context.colors.isDark
                        ? AppColors.primary.withValues(alpha: 0.9)
                        : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
