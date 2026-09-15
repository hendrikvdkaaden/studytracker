import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme_extension.dart';
import '../../utils/l10n_extension.dart';
import 'onboarding_card_decoration.dart';
import 'onboarding_landing_button.dart';
import 'onboarding_step_header.dart';
import 'onboarding_top_nav.dart';

/// Asks for notification permission, with an explanation first.
///
/// Comes before the step that sets the reminder offsets: asking how early to
/// be reminded is meaningless until it is settled whether reminders arrive at
/// all.
///
/// The prompt used to fire during startup, on the splash screen, before the
/// user had seen anything at all. Here it follows a preview of what the
/// reminders look like, so the request has a reason attached.
///
/// No skip beside it: App Review treats a skip next to the explanation as
/// steering the user away from the prompt. Declining in the prompt itself
/// lands on the refused state, which continues to the next step.
class OnboardingStepNotificationsPermission extends StatelessWidget {
  final bool isEnabled;

  /// True while the permission prompt is open, so it cannot be opened twice.
  final bool isBusy;

  /// True once permission was refused. The button is not offered again: iOS
  /// shows its prompt only once, so a second press would do nothing.
  final bool isDenied;

  final Future<void> Function() onEnableTap;

  /// Unlike the calendar step this one sits mid-flow, so it advances rather
  /// than finishing onboarding.
  final VoidCallback onNext;

  const OnboardingStepNotificationsPermission({
    super.key,
    required this.isEnabled,
    required this.isBusy,
    required this.isDenied,
    required this.onEnableTap,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = context.colors.isDark;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const OnboardingTopNav(),
            const SizedBox(height: 16),
            const OnboardingStepHeader(
              icon: Icons.notifications_active_outlined,
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
                  TextSpan(text: '${l10n.onboardingStep3TitleLine1}\n'),
                  TextSpan(
                    text: l10n.onboardingStep3TitleLine2,
                    style: TextStyle(
                      color: isDark
                          ? context.colors.accentSoft
                          : context.colors.accent,
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
            _buildPreviewCard(context),
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
            _buildActions(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Shows what the reminders actually look like, so the request is concrete
  /// rather than an abstract ask for permission.
  Widget _buildPreviewCard(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      decoration: onboardingCardDecoration(context),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPreviewEntry(
            context: context,
            icon: Icons.timer_outlined,
            color: context.colors.accent,
            title: l10n.notificationsPreviewSessionTitle,
            detail: l10n.notificationsPreviewSessionDetail,
          ),
          const SizedBox(height: 14),
          _buildPreviewEntry(
            context: context,
            icon: Icons.event_outlined,
            color: AppColors.iconPurple,
            title: l10n.notificationsPreviewDeadlineTitle,
            detail: l10n.notificationsPreviewDeadlineDetail,
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewEntry({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String title,
    required String detail,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                detail,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    final l10n = context.l10n;

    // Granted: nothing left to ask, so the button becomes the way onward.
    if (isEnabled) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                color: AppColors.completed,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.onboardingNotificationsEnabled,
                style: const TextStyle(
                  color: AppColors.completed,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          OnboardingLandingButton(
            label: l10n.onboardingContinue,
            onTap: onNext,
            width: double.infinity,
          ),
        ],
      );
    }

    // Refused. Pressing again would open nothing, so the step says where to
    // change it and moves on.
    if (isDenied) {
      return Column(
        children: [
          Text(
            l10n.onboardingNotificationsDenied,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          OnboardingLandingButton(
            label: l10n.onboardingContinue,
            onTap: onNext,
            width: double.infinity,
          ),
        ],
      );
    }

    // One way forward and no way around it -- see the class doc.
    return OnboardingLandingButton(
      label: isBusy
          ? l10n.onboardingNotificationsEnabling
          : l10n.onboardingNotificationsEnableButton,
      onTap: isBusy ? null : onEnableTap,
      width: double.infinity,
    );
  }
}
