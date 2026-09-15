import 'package:flutter/material.dart';
import 'onboarding_progress_indicator.dart';
import '../../theme/app_theme_extension.dart';

class OnboardingStepHeader extends StatelessWidget {
  final IconData icon;
  final int step;
  final int totalSteps;

  const OnboardingStepHeader({
    super.key,
    required this.icon,
    required this.step,
    this.totalSteps = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: context.colors.accent.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: context.colors.accentStrong, size: 24),
        ),
        const SizedBox(width: 12),
        OnboardingProgressIndicator(step: step, totalSteps: totalSteps),
      ],
    );
  }
}
