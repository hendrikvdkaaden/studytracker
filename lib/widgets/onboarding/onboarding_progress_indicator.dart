import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme_extension.dart';
import '../../utils/l10n_extension.dart';

class OnboardingProgressIndicator extends StatelessWidget {
  final int step;

  const OnboardingProgressIndicator({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    final isDark = context.colors.isDark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.onboardingStepOf(step, 3),
          style: TextStyle(
            color: isDark
                ? AppColors.textTertiary
                : AppColors.lightNavyMuted.withValues(alpha: 0.5),
            fontSize: 12,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: List.generate(3, (i) {
            return Container(
              width: 40,
              height: 6,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: i < step
                    ? (isDark ? AppColors.primaryVeryLight : AppColors.primary)
                    : isDark
                        ? AppColors.darkBorder
                        : AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(999),
              ),
            );
          }),
        ),
      ],
    );
  }
}
