import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme_extension.dart';
import '../../utils/l10n_extension.dart';
import 'onboarding_card_decoration.dart';
import 'onboarding_landing_button.dart';
import 'onboarding_step_header.dart';
import 'onboarding_top_nav.dart';

class OnboardingStepNotifications extends StatelessWidget {
  final int sessionReminderMinutes;
  final int deadlineReminderDays;
  final VoidCallback onNext;
  final Future<void> Function() onSessionReminderTap;
  final Future<void> Function() onDeadlineReminderTap;

  const OnboardingStepNotifications({
    super.key,
    required this.sessionReminderMinutes,
    required this.deadlineReminderDays,
    required this.onNext,
    required this.onSessionReminderTap,
    required this.onDeadlineReminderTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = context.colors.isDark;

    final sessionLabel = sessionReminderMinutes == 0
        ? 'Disabled'
        : l10n.profileSessionReminderFormat(sessionReminderMinutes);
    final deadlineLabel =
        l10n.profileDeadlineReminderFormat(deadlineReminderDays);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const OnboardingTopNav(),
            const SizedBox(height: 16),
            const OnboardingStepHeader(
              icon: Icons.notifications_outlined,
              step: 3,
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
                  const TextSpan(text: 'Set up\n'),
                  TextSpan(
                    text: 'reminders',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.primaryVeryLight
                          : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.onboardingStep3Subtitle,
              style: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              decoration: onboardingCardDecoration(context),
              child: Column(
                children: [
                  _buildReminderRow(
                    context: context,
                    icon: Icons.notifications_outlined,
                    iconBgColor: AppColors.primary.withValues(alpha: 0.2),
                    iconColor: AppColors.primaryLight,
                    label: l10n.onboardingSessionReminder,
                    value: sessionLabel,
                    onTap: onSessionReminderTap,
                  ),
                  Divider(
                    height: 1,
                    color: context.colors.border,
                    indent: 24,
                    endIndent: 24,
                  ),
                  _buildReminderRow(
                    context: context,
                    icon: Icons.event_note_outlined,
                    iconBgColor: context.colors.iconChipBackground(
                      AppColors.iconPurple,
                      AppColors.iconBgPurple,
                      darkAlpha: 0.2,
                    ),
                    iconColor: AppColors.iconPurple,
                    label: l10n.onboardingDeadlineReminder,
                    value: deadlineLabel,
                    onTap: onDeadlineReminderTap,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                l10n.onboardingStep3Note,
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
}


Widget _buildReminderRow({
  required BuildContext context,
  required IconData icon,
  required Color iconBgColor,
  required Color iconColor,
  required String label,
  required String value,
  required Future<void> Function() onTap,
}) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    ),
  );
}
