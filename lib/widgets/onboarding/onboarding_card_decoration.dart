import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme_extension.dart';

BoxDecoration onboardingCardDecoration(BuildContext context) {
  final isDark = context.colors.isDark;
  return BoxDecoration(
    color: context.colors.card,
    borderRadius: BorderRadius.circular(24),
    border: isDark
        ? null
        : Border.all(color: AppColors.lightChipBorder.withValues(alpha: 0.5)),
    boxShadow: isDark
        ? null
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
  );
}
