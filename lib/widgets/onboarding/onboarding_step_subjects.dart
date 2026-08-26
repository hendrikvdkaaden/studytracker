import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme_extension.dart';
import '../../utils/l10n_extension.dart';
import '../../services/settings_service.dart';
import 'onboarding_card_decoration.dart';
import 'onboarding_landing_button.dart';
import 'onboarding_step_header.dart';
import 'onboarding_top_nav.dart';

class OnboardingStepSubjects extends StatelessWidget {
  final List<SubjectData> subjects;
  final VoidCallback onNext;
  final Future<void> Function() onAddSubject;
  final ValueChanged<SubjectData> onRemoveSubject;

  const OnboardingStepSubjects({
    super.key,
    required this.subjects,
    required this.onNext,
    required this.onAddSubject,
    required this.onRemoveSubject,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const OnboardingTopNav(),
            const SizedBox(height: 16),
            const OnboardingStepHeader(
              icon: Icons.book_outlined,
              step: 2,
            ),
            const SizedBox(height: 20),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  color: context.colors.textPrimary,
                ),
                children: [
                  const TextSpan(text: 'Add your\n'),
                  TextSpan(
                    text: 'subjects',
                    style: TextStyle(
                      color: context.colors.isDark
                          ? AppColors.primaryVeryLight
                          : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.onboardingStep2Subtitle,
              style: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              decoration: onboardingCardDecoration(context),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (subjects.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: subjects
                          .map((s) => _buildSubjectChip(context, s))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onAddSubject,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add,
                                color: AppColors.primaryLight,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              l10n.onboardingAddSubject,
                              style: const TextStyle(
                                color: AppColors.primaryLight,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                l10n.onboardingStep2Note,
                style: const TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            OnboardingLandingButton(
              label: l10n.onboardingContinue,
              onTap: onNext,
              width: double.infinity,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectChip(BuildContext context, SubjectData subject) {
    final isDark = context.colors.isDark;
    // The whole pill removes the subject, not just the small cross: the icon
    // alone was a tap target barely wider than a fingertip.
    return Material(
      color: isDark ? const Color(0xFF2D3449) : AppColors.lightChipBg,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: () => onRemoveSubject(subject),
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightChipBorder,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: subject.color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: subject.color.withValues(alpha: 0.5),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                subject.name,
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.close,
                size: 16,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

