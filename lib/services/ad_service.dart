import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Wraps the Google Mobile Ads SDK so the rest of the app never touches it
/// directly. Every failure resolves to false rather than throwing: an ad is
/// always optional, and a broken ad must never break a user flow.
class AdService {
  /// Google's official test units.
  static const String _testRewardedIos =
      'ca-app-pub-3940256099942544/1712485313';
  static const String _testRewardedAndroid =
      'ca-app-pub-3940256099942544/5224354917';

  /// Live rewarded unit for the iOS app.
  static const String _liveRewardedIos =
      'ca-app-pub-3670812631941435/2056376133';

  /// Flip to true to force test ads while developing. Clicking a live ad
  /// yourself is the quickest way to get an AdMob account suspended, so switch
  /// this on before testing the paywall by hand.
  static const bool useTestAds = true;

  static bool _initialised = false;
  static bool _consentGathered = false;
  static RewardedAd? _rewardedAd;

  static String get _rewardedUnitId {
    if (useTestAds) {
      return Platform.isIOS ? _testRewardedIos : _testRewardedAndroid;
    }
    // Android has no AdMob app registered yet, so it stays on the test unit.
    return Platform.isIOS ? _liveRewardedIos : _testRewardedAndroid;
  }

  /// Initialises the SDK. Consent is gathered separately, on the first ad
  /// load, because the consent form is a dialog and needs a stable screen to
  /// appear on.
  static Future<void> init() async {
    if (_initialised) return;
    try {
      await MobileAds.instance.initialize();
      // The app does not ask for tracking permission, so every request is
      // explicitly non-personalised.
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          // The app is aimed at students of all ages, so keep ad content to
          // the most restrictive rating.
          maxAdContentRating: MaxAdContentRating.g,
        ),
      );
      _initialised = true;
    } catch (e) {
      debugPrint('AdMob init failed: $e');
    }
  }

  /// Runs the consent flow once per app session.
  ///
  /// Call this before opening UI that offers an ad, so the consent dialog does
  /// not appear stacked on top of a sheet. Gathering consent on demand rather
  /// than at startup also means users who never touch the ad option are never
  /// asked.
  static Future<void> ensureConsent() async {
    if (_consentGathered) return;
    _consentGathered = true;
    await _gatherConsent();
  }

  /// Asks the User Messaging Platform for the user's consent choice, showing
  /// the form when one is required. Failures are swallowed: [canRequestAds]
  /// decides afterwards whether an ad may actually be requested.
  static Future<void> _gatherConsent() async {
    final completer = Completer<void>();
    try {
      ConsentInformation.instance.requestConsentInfoUpdate(
        ConsentRequestParameters(),
        () async {
          try {
            await ConsentForm.loadAndShowConsentFormIfRequired((error) {
              if (error != null) {
                debugPrint('Consent form error: ${error.message}');
              }
              if (!completer.isCompleted) completer.complete();
            });
          } catch (e) {
            debugPrint('Consent form threw: $e');
            if (!completer.isCompleted) completer.complete();
          }
        },
        (error) {
          debugPrint('Consent info update failed: ${error.message}');
          if (!completer.isCompleted) completer.complete();
        },
      );
    } catch (e) {
      debugPrint('Consent request threw: $e');
      return;
    }

    // Never block startup on the consent flow.
    await completer.future.timeout(
      const Duration(seconds: 15),
      onTimeout: () {},
    );
  }

  /// Whether the user's consent state allows requesting ads at all. Used to
  /// hide the ad option rather than offer a button that cannot serve.
  static Future<bool> _canRequestAds() async {
    try {
      return await ConsentInformation.instance.canRequestAds();
    } catch (e) {
      debugPrint('canRequestAds failed: $e');
      return false;
    }
  }

  /// True when the user is in a region where a privacy options entry point
  /// must be offered, so consent can be withdrawn later.
  static Future<bool> isPrivacyOptionsRequired() async {
    try {
      final status =
          await ConsentInformation.instance.getPrivacyOptionsRequirementStatus();
      return status == PrivacyOptionsRequirementStatus.required;
    } catch (e) {
      debugPrint('Privacy options status failed: $e');
      return false;
    }
  }

  /// Reopens the consent form so the user can change or withdraw their choice.
  static Future<void> showPrivacyOptionsForm() async {
    try {
      await ConsentForm.showPrivacyOptionsForm((error) {
        if (error != null) {
          debugPrint('Privacy options form error: ${error.message}');
        }
      });
    } catch (e) {
      debugPrint('Privacy options form threw: $e');
    }
  }

  /// Loads a rewarded ad and reports whether one is ready to show.
  ///
  /// Callers use this to decide whether to offer the ad at all, so a false
  /// result should hide the entry point rather than surface an error.
  static Future<bool> loadRewardedAd() async {
    if (!_initialised) await init();
    if (!_initialised) return false;

    await ensureConsent();

    // Respect the user's consent choice: without it, no ad may be requested.
    if (!await _canRequestAds()) return false;
    if (_rewardedAd != null) return true;

    final completer = Completer<bool>();
    try {
      await RewardedAd.load(
        adUnitId: _rewardedUnitId,
        request: const AdRequest(nonPersonalizedAds: true),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            if (!completer.isCompleted) completer.complete(true);
          },
          onAdFailedToLoad: (error) {
            debugPrint('Rewarded ad failed to load: $error');
            _rewardedAd = null;
            if (!completer.isCompleted) completer.complete(false);
          },
        ),
      );
    } catch (e) {
      debugPrint('Rewarded ad load threw: $e');
      return false;
    }

    return completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () => false,
    );
  }

  /// Shows the preloaded ad. Returns true only when the user earned the
  /// reward — dismissing the ad early returns false.
  static Future<bool> showRewardedAd() async {
    final ad = _rewardedAd;
    if (ad == null) return false;
    _rewardedAd = null;

    var earned = false;
    final completer = Completer<bool>();

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (!completer.isCompleted) completer.complete(earned);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Rewarded ad failed to show: $error');
        ad.dispose();
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    try {
      await ad.show(
        onUserEarnedReward: (ad, reward) => earned = true,
      );
    } catch (e) {
      debugPrint('Rewarded ad show threw: $e');
      return false;
    }

    return completer.future;
  }

  /// Drops any preloaded ad, e.g. when the user closes the sheet without
  /// watching it.
  static void disposeAd() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}
