import 'package:flutter/material.dart';
import '../../theme/app_theme_extension.dart';
import '../../utils/l10n_extension.dart';

class OnboardingProgressIndicator extends StatelessWidget {
  final int step;

  /// How many steps the flow has in total, so adding one does not mean
  /// hunting down hardcoded counts.
  final int totalSteps;

  const OnboardingProgressIndicator({
    super.key,
    required this.step,
    this.totalSteps = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.onboardingStepOf(step, totalSteps),
          style: TextStyle(
            color: context.colors.textTertiary,
            fontSize: 12,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: List.generate(totalSteps, (i) {
            return Container(
              width: 32,
              height: 6,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: i < step
                    ? context.colors.accentOnSurface
                    : context.colors.accentAlpha(
                        context.colors.accent,
                        darkAlpha: 0.25,
                        lightAlpha: 0.2,
                      ),
                borderRadius: BorderRadius.circular(999),
              ),
            );
          }),
        ),
      ],
    );
  }
}
