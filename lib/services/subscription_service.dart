import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'settings_service.dart';

class SubscriptionService {
  static const _iosApiKey = 'appl_PDczFarlErpoWohPpKQUVFjTVBm';
  static const _androidApiKey = '';
  static const _entitlementId = 'premium';
  static const int freeGoalLimit = 3;
  static const int freeSubjectLimit = 3;

  /// Treats the user as a subscriber so paid features can be tried without
  /// buying anything. Debug builds only -- a release build ignores it, so
  /// leaving it on cannot hand out premium to everyone.
  ///
  /// Set back to false when you are done.
  static const bool unlockPremiumForTesting = false;

  /// How many deadlines a free user may keep: the free limit plus whatever
  /// they have unlocked by watching ads.
  static int get goalLimitWithEarned =>
      freeGoalLimit + SettingsService.earnedGoalSlots;

  static Future<void> init() async {
    if (kDebugMode) await Purchases.setLogLevel(LogLevel.debug);
    final apiKey = Platform.isIOS ? _iosApiKey : _androidApiKey;
    assert(apiKey.isNotEmpty, 'RevenueCat API key is not configured for this platform');
    await Purchases.configure(PurchasesConfiguration(apiKey));
  }

  Future<bool> isPremium() async {
    if (unlockPremiumForTesting && kDebugMode) return true;

    try {
      final info = await Purchases.getCustomerInfo();
      return info.entitlements.active.containsKey(_entitlementId);
    } catch (e) {
      debugPrint('isPremium check failed: $e');
      return false;
    }
  }

  Future<Offerings?> getOfferings() async {
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      // Usually means the products are not (yet) fetchable from App Store
      // Connect. The paywall falls back to its "no offerings" message.
      debugPrint('Failed to load offerings: $e');
      return null;
    }
  }

  Future<bool> purchase(Package package) async {
    try {
      final info = await Purchases.purchasePackage(package);
      return info.entitlements.active.containsKey(_entitlementId);
    } on PurchasesErrorCode catch (e) {
      if (e == PurchasesErrorCode.purchaseCancelledError) return false;
      rethrow;
    }
  }

  Future<bool> restorePurchases() async {
    try {
      final info = await Purchases.restorePurchases();
      return info.entitlements.active.containsKey(_entitlementId);
    } catch (_) {
      return false;
    }
  }
}
