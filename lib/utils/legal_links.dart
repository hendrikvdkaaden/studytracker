import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Legal URLs required by App Store Review Guideline 3.1.2.
///
/// Both links must be reachable from the paywall before an app with an
/// auto-renewing subscription can be approved.
class LegalLinks {
  /// Apple's standard EULA. Use this unless you host your own terms — in that
  /// case the same URL must also be entered in App Store Connect.
  static const String termsOfUse =
      'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/';

  /// Must point at a publicly reachable page and match the Privacy Policy URL
  /// configured in App Store Connect.
  ///
  /// Served from docs/privacy.html via GitHub Pages. Enable Pages on the
  /// repository (Settings > Pages > Deploy from branch: main, folder: /docs)
  /// and verify this URL loads in a browser before submitting for review.
  static const String privacyPolicy =
      'https://hendrikvdkaaden.github.io/studytracker/privacy.html';

  static Future<void> open(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Failed to open legal link $url: $e');
    }
  }

  static Future<void> openTermsOfUse() => open(termsOfUse);

  static Future<void> openPrivacyPolicy() => open(privacyPolicy);
}
