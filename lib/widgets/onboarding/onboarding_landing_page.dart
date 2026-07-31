import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme_extension.dart';
import '../../utils/l10n_extension.dart';
import 'onboarding_landing_button.dart';

class OnboardingLandingPage extends StatelessWidget {
  final VoidCallback onNext;

  const OnboardingLandingPage({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 48),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),

              ),
              padding: const EdgeInsets.fromLTRB(12, 35, 12, 0),
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Deadly',
              style: TextStyle(
                color: context.colors.isDark ? Colors.white : AppColors.lightNavy,
                fontSize: 48,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.onboardingLandingTagline,
              style: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            OnboardingLandingButton(
              label: l10n.onboardingGetStarted,
              onTap: onNext,
            ),
            const SizedBox(height: 64),
          ],
        ),
      ),
    );
  }
}
