import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../utils/l10n_extension.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? AppColors.darkCard : Colors.white;

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
                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.12),
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
                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    size: 18,
                    color: isDark ? Colors.white70 : Colors.black54,
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
                  : _buildContent(isDark),
            ),
          ),
          _buildFooter(isDark),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDark) {
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
            color: isDark ? Colors.white : AppColors.premiumText,
            letterSpacing: -0.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.paywallSubtitle,
          style: TextStyle(
            fontSize: 15,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        _buildFeatureList(isDark, l10n),
        const SizedBox(height: 24),
        if (monthly != null || annual != null) ...[
          if (annual != null)
            _buildPackageCard(
              package: annual,
              label: l10n.paywallYearlyLabel,
              subtitle: l10n.paywallYearlySubtitle,
              badge: l10n.paywallYearlySaveBadge,
              valueBadge: l10n.paywallYearlyValueBadge,
              period: l10n.paywallPeriodYear,
              isDark: isDark,
            ),
          const SizedBox(height: 12),
          if (monthly != null)
            _buildPackageCard(
              package: monthly,
              label: l10n.paywallMonthlyLabel,
              subtitle: l10n.paywallMonthlySubtitle,
              period: l10n.paywallPeriodMonth,
              isDark: isDark,
            ),
        ] else
          Text(
            l10n.paywallNoOfferings,
            style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildIcon() => const PremiumIcon();

  Widget _buildFeatureList(bool isDark, AppLocalizations l10n) {
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
                        color: isDark ? Colors.grey[200] : AppColors.premiumText,
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
    required bool isDark,
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
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.premiumBlue
                : (isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.premiumCardBorder),
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
                            color: isDark ? Colors.white : AppColors.premiumText,
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
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
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
                        color: isDark ? Colors.white : AppColors.premiumText,
                      ),
                    ),
                    Text(
                      period,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppColors.premiumBlue : Colors.grey,
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

  Widget _buildFooter(bool isDark) {
    final l10n = context.l10n;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        border: Border(
          top: BorderSide(
            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
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
                color: isDark ? Colors.grey[500] : Colors.grey[600],
                decoration: TextDecoration.underline,
                decorationColor: isDark ? Colors.grey[600] : Colors.grey[400],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.paywallDisclaimerText,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
