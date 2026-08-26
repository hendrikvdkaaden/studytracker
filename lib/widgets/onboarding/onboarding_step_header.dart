import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'onboarding_progress_indicator.dart';

class OnboardingStepHeader extends StatelessWidget {
  final IconData icon;
  final int step;
  final int totalSteps;

  const OnboardingStepHeader({
    super.key,
    required this.icon,
    required this.step,
    this.totalSteps = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primaryLight, size: 24),
        ),
        const SizedBox(width: 12),
        OnboardingProgressIndicator(step: step, totalSteps: totalSteps),
      ],
    );
  }
}
