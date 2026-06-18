import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../utils/l10n_extension.dart';
import 'onboarding_landing_button.dart';

class OnboardingLandingPage extends StatelessWidget {
  final VoidCallback onNext;

  const OnboardingLandingPage({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 48),
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F766E), Color(0xFF04B4A2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(
                      alpha: isDark ? 0.4 : 0.2,
                    ),
                    blurRadius: isDark ? 32 : 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: const Icon(Icons.school, color: Colors.white, size: 48),
            ),
            const SizedBox(height: 32),
            Text(
              'StudyTracker',
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.lightNavy,
                fontSize: 48,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 12),
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
