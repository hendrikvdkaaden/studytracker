import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class OnboardingTopNav extends StatelessWidget {
  const OnboardingTopNav({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brandColor = isDark ? AppColors.primaryVeryLight : AppColors.lightNavy;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Icon(
            Icons.menu_book,
            color: isDark ? AppColors.primaryVeryLight : AppColors.primary,
            size: 22,
          ),
          const SizedBox(width: 8),
          Text(
            'StudyTracker',
            style: TextStyle(
              color: brandColor,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}
