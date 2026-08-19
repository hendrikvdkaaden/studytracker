import 'package:flutter/material.dart';
import '../../services/ad_service.dart';
import '../../services/settings_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme_extension.dart';
import '../../utils/l10n_extension.dart';
import 'paywall_bottom_sheet.dart';
import 'premium_icon.dart';

/// How the user left the premium gate.
enum PremiumGateResult {
  /// Closed without unlocking anything.
  dismissed,

  /// Subscribed through the paywall.
  purchased,

  /// Watched a rewarded ad to unlock the feature once.
  adReward,
}

/// Shows a "feature locked" bottom sheet.
///
/// Tapping "Upgrade" opens the paywall. When [allowAdReward] is set and an ad
/// is actually available, the sheet also offers a one-off unlock in exchange
/// for watching a rewarded ad.
Future<PremiumGateResult> showPremiumGateSheet(
  BuildContext context, {
  required String title,
  required String message,
  bool allowAdReward = false,
}) async {
  if (allowAdReward) {
    // Settle consent before the sheet opens, so the form is never stacked on
    // top of it.
    await AdService.ensureConsent();
    if (!context.mounted) return PremiumGateResult.dismissed;
  }

  final outcome = await showModalBottomSheet<PremiumGateResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    // Leave a strip of the screen visible so the sheet can still be swiped
    // down or dismissed by tapping outside it.
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.92,
    ),
    builder: (_) => _PremiumGateSheet(
      title: title,
      message: message,
      allowAdReward: allowAdReward,
    ),
  );

  if (outcome == PremiumGateResult.purchased && context.mounted) {
    final purchased = await showPaywallBottomSheet(context);
    return purchased ? PremiumGateResult.purchased : PremiumGateResult.dismissed;
  }
  return outcome ?? PremiumGateResult.dismissed;
}

class _PremiumGateSheet extends StatefulWidget {
  const _PremiumGateSheet({
    required this.title,
    required this.message,
    this.allowAdReward = false,
  });

  final String title;
  final String message;
  final bool allowAdReward;

  @override
  State<_PremiumGateSheet> createState() => _PremiumGateSheetState();
}

class _PremiumGateSheetState extends State<_PremiumGateSheet> {
  /// Only true once an ad is loaded and ready — the button is never shown for
  /// an ad that cannot play.
  bool _adReady = false;
  bool _watchingAd = false;

  @override
  void initState() {
    super.initState();
    _prepareAd();
  }

  @override
  void dispose() {
    AdService.disposeAd();
    super.dispose();
  }

  Future<void> _prepareAd() async {
    if (!widget.allowAdReward) return;
    if (!SettingsService.canUseAdTrialToday) return;

    final ready = await AdService.loadRewardedAd();
    if (mounted && ready) setState(() => _adReady = true);
  }

  Future<void> _watchAd() async {
    setState(() => _watchingAd = true);
    final earned = await AdService.showRewardedAd();
    if (!mounted) return;

    if (earned) {
      Navigator.of(context).pop(PremiumGateResult.adReward);
    } else {
      // Ad dismissed early or failed: leave the sheet open so the user can
      // still upgrade, and drop the button since the ad is spent.
      setState(() {
        _watchingAd = false;
        _adReady = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.title;
    final message = widget.message;
    final sheetBg = context.colors.modalBackground;

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        0,
        24,
        MediaQuery.of(context).padding.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.overlay(darkAlpha: 0.12, lightAlpha: 0.12),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Icon
          const PremiumIcon(),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: context.colors.textPrimary,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: TextStyle(
              fontSize: 15,
              color: context.colors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          // Upgrade button
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.premiumBlue, AppColors.premiumGradientEnd],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.premiumBlue.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _watchingAd
                  ? null
                  : () => Navigator.of(context).pop(PremiumGateResult.purchased),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                disabledBackgroundColor: Colors.transparent,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                context.l10n.premiumDialogUpgradeButton,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
          // Ad option — only rendered once an ad is loaded and ready.
          if (_adReady) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _watchingAd ? null : _watchAd,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: _watchingAd
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.play_circle_outline, size: 20),
              label: Text(
                context.l10n.premiumDialogWatchAd,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          // Not now button
          TextButton(
            onPressed: _watchingAd
                ? null
                : () => Navigator.of(context).pop(PremiumGateResult.dismissed),
            style: TextButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(
              context.l10n.premiumDialogNotNow,
              style: TextStyle(
                fontSize: 15,
                color: context.colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
