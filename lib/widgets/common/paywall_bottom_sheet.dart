import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme_extension.dart';
import '../../utils/l10n_extension.dart';
import '../../utils/legal_links.dart';
import 'premium_icon.dart';

Future<bool> showPaywallBottomSheet(BuildContext context) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _PaywallBottomSheet(),
  );
  return result ?? false;
}

class _PaywallBottomSheet extends ConsumerStatefulWidget {
  const _PaywallBottomSheet();

  @override
  ConsumerState<_PaywallBottomSheet> createState() => _PaywallBottomSheetState();
}

class _PaywallBottomSheetState extends ConsumerState<_PaywallBottomSheet> {
  Offerings? _offerings;
  Package? _selectedPackage;
  bool _isLoading = true;
  bool _isPurchasing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    final offerings = await ref.read(subscriptionServiceProvider).getOfferings();
    if (!mounted) return;
    setState(() {
      _offerings = offerings;
      _isLoading = false;
      final annual = offerings?.current?.annual;
      final monthly = offerings?.current?.monthly;
      _selectedPackage = annual ?? monthly;
    });
  }

  Future<void> _purchase() async {
    if (_selectedPackage == null) return;
    setState(() => _isPurchasing = true);
    try {
      final success = await ref.read(subscriptionServiceProvider).purchase(_selectedPackage!);
      if (!mounted) return;
      if (success) {
        ref.invalidate(isPremiumProvider);
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = context.l10n.paywallErrorGeneric);
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  Future<void> _restore() async {
    setState(() => _isPurchasing = true);
    try {
      final success = await ref.read(subscriptionServiceProvider).restorePurchases();
      if (!mounted) return;
      if (success) {
        ref.invalidate(isPremiumProvider);
        Navigator.of(context).pop(true);
      } else {
        setState(() => _errorMessage = context.l10n.paywallErrorNoPurchases);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = context.l10n.paywallErrorRestoreFailed);
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sheetBg = context.colors.modalBackground;

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.overlay(darkAlpha: 0.12, lightAlpha: 0.12),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Close button
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 4, 16, 0),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(false),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: context.colors.overlay(darkAlpha: 0.06, lightAlpha: 0.06),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    size: 18,
                    color: context.colors.isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: _isLoading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : _buildContent(),
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final l10n = context.l10n;
    final current = _offerings?.current;
    final monthly = current?.monthly;
    final annual = current?.annual;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildIcon(),
        const SizedBox(height: 20),
        Text(
          l10n.paywallTitle,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: context.colors.textPrimary,
            letterSpacing: -0.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.paywallSubtitle,
          style: TextStyle(
            fontSize: 15,
            color: context.colors.textSecondary,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        _buildFeatureList(l10n),
        const SizedBox(height: 24),
        if (monthly != null || annual != null) ...[
          if (annual != null)
            _buildPackageCard(
              package: annual,
              label: l10n.paywallYearlyLabel,
              subtitle: _yearlySubtitle(l10n, annual),
              badge: _yearlySaveBadge(l10n, annual, monthly),
              valueBadge: l10n.paywallYearlyValueBadge,
              period: l10n.paywallPeriodYear,
            ),
          const SizedBox(height: 12),
          if (monthly != null)
            _buildPackageCard(
              package: monthly,
              label: l10n.paywallMonthlyLabel,
              subtitle: l10n.paywallMonthlySubtitle,
              period: l10n.paywallPeriodMonth,
            ),
        ] else
          Text(
            l10n.paywallNoOfferings,
            style: TextStyle(color: context.colors.textSecondary),
            textAlign: TextAlign.center,
          ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildIcon() => const PremiumIcon();

  /// Derives the per-month price from the store's own annual price so the
  /// figure is correct in every storefront and currency. Falls back to a
  /// generic label when the store gives us no usable price data.
  String _yearlySubtitle(AppLocalizations l10n, Package annual) {
    final product = annual.storeProduct;
    final monthlyPrice = product.price / 12;
    if (monthlyPrice <= 0) return l10n.paywallYearlySubtitleFallback;

    final formatted = NumberFormat.simpleCurrency(
      name: product.currencyCode,
    ).format(monthlyPrice);
    return l10n.paywallYearlySubtitle(formatted);
  }

  /// Only shows a savings badge when both packages are available and the
  /// annual plan is genuinely cheaper per month.
  String? _yearlySaveBadge(
    AppLocalizations l10n,
    Package annual,
    Package? monthly,
  ) {
    if (monthly == null) return null;
    final monthlyPrice = monthly.storeProduct.price;
    if (monthlyPrice <= 0) return null;

    final annualPerMonth = annual.storeProduct.price / 12;
    final percent = ((1 - (annualPerMonth / monthlyPrice)) * 100).round();
    if (percent <= 0) return null;

    return l10n.paywallYearlySaveBadge(percent);
  }

  Widget _buildFeatureList(AppLocalizations l10n) {
    final features = [
      l10n.paywallFeature1,
      l10n.paywallFeature2,
      l10n.paywallFeature3,
    ];

    return Column(
      children: features
          .map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.only(top: 1),
                    decoration: BoxDecoration(
                      color: AppColors.premiumBlue.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: AppColors.premiumBlue, size: 14),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      f,
                      style: TextStyle(
                        fontSize: 15,
                        color: context.colors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildPackageCard({
    required Package package,
    required String label,
    required String subtitle,
    required String period,
    String? badge,
    String? valueBadge,
  }) {
    final isSelected = _selectedPackage?.identifier == package.identifier;
    final price = package.storeProduct.priceString;

    return GestureDetector(
      onTap: () => setState(() => _selectedPackage = package),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.premiumBlue
                : (context.colors.isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.premiumCardBorder),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.premiumBlue.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: context.colors.textPrimary,
                          ),
                        ),
                        if (valueBadge != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.premiumBlue.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              valueBadge,
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppColors.premiumBlue,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 13, color: context.colors.textSecondary),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      price,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    Text(
                      period,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppColors.premiumBlue : context.colors.textSecondary,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (badge != null)
              Positioned(
                top: -28,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.premiumBlue,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.premiumBlue.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    final l10n = context.l10n;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 24),
      decoration: BoxDecoration(
        color: context.colors.modalBackground,
        border: Border(
          top: BorderSide(
            color: context.colors.overlay(darkAlpha: 0.06, lightAlpha: 0.06),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_errorMessage != null) ...[
            Text(
              _errorMessage!,
              style: const TextStyle(color: AppColors.overdue, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
          ],
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: _selectedPackage != null
                  ? const LinearGradient(
                      colors: [AppColors.premiumBlue, AppColors.premiumGradientEnd],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                  : const LinearGradient(colors: [Colors.grey, Colors.grey]),
              borderRadius: BorderRadius.circular(16),
              boxShadow: _selectedPackage != null
                  ? [
                      BoxShadow(
                        color: AppColors.premiumBlue.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: ElevatedButton(
              onPressed: (_selectedPackage == null || _isPurchasing) ? null : _purchase,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                disabledBackgroundColor: Colors.transparent,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isPurchasing
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      l10n.paywallCtaButton,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _isPurchasing ? null : _restore,
            child: Text(
              l10n.paywallRestorePurchases,
              style: TextStyle(
                fontSize: 13,
                color: context.colors.textSecondary,
                decoration: TextDecoration.underline,
                decorationColor: context.colors.textTertiary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.paywallDisclaimerText,
            style: TextStyle(
              fontSize: 11,
              color: context.colors.textTertiary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          _buildLegalLinks(l10n),
        ],
      ),
    );
  }

  /// Terms of Use and Privacy Policy links are required by App Store Review
  /// Guideline 3.1.2 for apps offering auto-renewing subscriptions.
  Widget _buildLegalLinks(AppLocalizations l10n) {
    final linkStyle = TextStyle(
      fontSize: 11,
      color: context.colors.textSecondary,
      decoration: TextDecoration.underline,
      decorationColor: context.colors.textTertiary,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: LegalLinks.openTermsOfUse,
          child: Text(l10n.paywallTermsOfUse, style: linkStyle),
        ),
        Text(
          l10n.paywallLegalSeparator,
          style: TextStyle(fontSize: 11, color: context.colors.textTertiary),
        ),
        GestureDetector(
          onTap: LegalLinks.openPrivacyPolicy,
          child: Text(l10n.paywallPrivacyPolicy, style: linkStyle),
        ),
      ],
    );
  }
}
