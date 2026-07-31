import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme_extension.dart';
import '../../utils/l10n_extension.dart';
import 'onboarding_card_decoration.dart';
import 'onboarding_landing_button.dart';
import 'onboarding_step_header.dart';
import 'onboarding_top_nav.dart';

class OnboardingStepName extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController schoolController;
  final bool nameError;
  final VoidCallback onNext;
  final ValueChanged<String> onNameChanged;

  const OnboardingStepName({
    super.key,
    required this.nameController,
    required this.schoolController,
    required this.nameError,
    required this.onNext,
    required this.onNameChanged,
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
              icon: Icons.person_outline,
              step: 1,
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
                  const TextSpan(text: "What's your\n"),
                  TextSpan(
                    text: 'name?',
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
              l10n.onboardingStep1Subtitle,
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
                  _buildTextField(
                    context: context,
                    controller: nameController,
                    hint: l10n.onboardingNameHint,
                    hasError: nameError,
                    onChanged: onNameChanged,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    context: context,
                    controller: schoolController,
                    hint: l10n.onboardingSchoolHint,
                  ),
                ],
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
}


Widget _buildTextField({
  required BuildContext context,
  required TextEditingController controller,
  required String hint,
  bool hasError = false,
  ValueChanged<String>? onChanged,
}) {
  final isDark = context.colors.isDark;
  return TextField(
    controller: controller,
    style: TextStyle(color: context.colors.textPrimary),
    textCapitalization: TextCapitalization.words,
    onChanged: onChanged,
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: isDark
            ? Colors.white.withValues(alpha: 0.3)
            : AppColors.textTertiary,
      ),
      errorText: hasError ? context.l10n.onboardingNameError : null,
      errorStyle: const TextStyle(color: AppColors.overdue, fontSize: 12),
      filled: true,
      fillColor: isDark
          ? context.colors.fieldBackground
          : AppColors.lightChipBg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: hasError
            ? const BorderSide(color: AppColors.overdue, width: 1.5)
            : BorderSide(
                color: isDark
                    ? AppColors.darkBorder
                    : AppColors.lightChipBorder,
                width: 1,
              ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: hasError
            ? const BorderSide(color: AppColors.overdue, width: 2)
            : const BorderSide(color: AppColors.primaryLight, width: 2),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    ),
  );
}
