import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme_extension.dart';
import '../../../utils/l10n_extension.dart';

class ProgressSectionHeader extends StatelessWidget {
  const ProgressSectionHeader({super.key});

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
      ],
    );
  }
}
