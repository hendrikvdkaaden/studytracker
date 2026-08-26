import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme_extension.dart';
import '../../utils/l10n_extension.dart';
import 'onboarding_card_decoration.dart';
import 'onboarding_landing_button.dart';
import 'onboarding_step_header.dart';
import 'onboarding_top_nav.dart';

/// Last onboarding step: offers to mirror deadlines and sessions to the
/// device calendar.
///
/// Connecting is the primary button rather than a settings row, so it reads
/// as the thing to do here. Skipping stays available underneath, and the
/// button turns into "Let's go!" once the calendar is connected.
class OnboardingStepCalendar extends StatelessWidget {
  final bool isConnected;

  /// True while the permission prompt and calendar creation are running, so
  /// the button cannot be pressed twice.
  final bool isBusy;

  /// True once connecting failed. The button is not offered again: iOS shows
  /// its permission prompt only once, so a second press would do nothing.
  final bool isDenied;

  final Future<void> Function() onConnectTap;
  final Future<void> Function() onComplete;

  const OnboardingStepCalendar({
    super.key,
    required this.isConnected,
    required this.isBusy,
    required this.isDenied,
    required this.onConnectTap,
    required this.onComplete,
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
              icon: Icons.calendar_month_outlined,
              step: 4,
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
                  TextSpan(text: '${l10n.onboardingStep4TitleLine1}\n'),
                  TextSpan(
                    text: l10n.onboardingStep4TitleLine2,
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
              l10n.onboardingStep4Subtitle,
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
                l10n.onboardingStep4Note,
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

  /// Shows what the calendar will actually look like, so the offer is
  /// concrete rather than an abstract permission request.
  Widget _buildPreviewCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: onboardingCardDecoration(context),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPreviewEntry(
            context: context,
            color: AppColors.primary,
            title: 'Deadline Biology: Chapter 7',
            detail: 'All day',
          ),
          const SizedBox(height: 14),
          _buildPreviewEntry(
            context: context,
            color: AppColors.iconPurple,
            title: 'Study: Chapter 7',
            detail: '14:00 - 15:30',
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewEntry({
    required BuildContext context,
    required Color color,
    required String title,
    required String detail,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 3,
          height: 34,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
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

    // Once connected there is nothing left to do here, so the primary button
    // becomes the way out of onboarding.
    if (isConnected) {
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
                l10n.onboardingCalendarConnected,
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
            label: l10n.onboardingLetsGo,
            onTap: onComplete,
            width: double.infinity,
          ),
        ],
      );
    }

    // Access was refused. Pressing again would open nothing, so the step
    // explains where to change it and moves on.
    if (isDenied) {
      return Column(
        children: [
          Text(
            l10n.onboardingCalendarDenied,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          OnboardingLandingButton(
            label: l10n.onboardingLetsGo,
            onTap: onComplete,
            width: double.infinity,
          ),
        ],
      );
    }

    return Column(
      children: [
        OnboardingLandingButton(
          label: isBusy
              ? l10n.onboardingCalendarConnecting
              : l10n.onboardingCalendarConnectButton,
          onTap: isBusy ? null : onConnectTap,
          width: double.infinity,
        ),
        const SizedBox(height: 4),
        TextButton(
          onPressed: isBusy ? null : onComplete,
          style: TextButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            foregroundColor: AppColors.textTertiary,
          ),
          child: Text(
            l10n.onboardingCalendarSkip,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
