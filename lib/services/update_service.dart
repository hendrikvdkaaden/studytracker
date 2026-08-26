import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import 'settings_service.dart';
import 'version_comparator.dart';

/// What the store says about a newer release.
class UpdateInfo {
  final String version;
  final Uri storeUrl;

  const UpdateInfo({required this.version, required this.storeUrl});
}

/// Checks whether a newer build of the app is on the App Store.
///
/// Same posture as NotificationService and CalendarSyncService: every failure
/// is swallowed and reported as "no update". A checker that cannot reach the
/// network must never block or nag anyone.
class UpdateService {
  /// Apple's public lookup endpoint. No key, no account, no rate agreement —
  /// but it is undocumented enough to be worth failing softly on.
  static const String _lookupHost = 'itunes.apple.com';

  /// How long to wait before giving up. This runs at launch, so a slow
  /// network must not hold anything up.
  static const Duration _timeout = Duration(seconds: 5);

  /// Only ask the store once a day. The answer changes rarely, and a request
  /// on every launch is wasted traffic.
  static const Duration _minInterval = Duration(hours: 24);

  /// Returns the newer release, or null when the app is current, the check
  /// fails, or it ran recently.
  ///
  /// Pass [force] to skip the daily interval — used by a manual check.
  static Future<UpdateInfo?> checkForUpdate({bool force = false}) async {
    // Android would need the Play Store's own API; nothing else is supported.
    if (!Platform.isIOS) return null;

    if (!force && !_intervalElapsed()) return null;

    try {
      final info = await PackageInfo.fromPlatform();
      final result = await _lookup(info.packageName);
      if (result == null) return null;

      final storeVersion = result.version;
      if (!VersionComparator.isNewer(storeVersion, info.version)) return null;

      return UpdateInfo(version: storeVersion, storeUrl: result.storeUrl);
    } catch (e) {
      debugPrint('Update check failed: $e');
      return null;
    } finally {
      // Recorded whatever the outcome. A lookup that keeps failing -- a
      // bundle id not on the store yet answers with an empty list forever --
      // would otherwise never engage the interval and hit the network on
      // every single launch.
      await SettingsService.setLastUpdateCheck(DateTime.now());
    }
  }

  static bool _intervalElapsed() {
    final last = SettingsService.lastUpdateCheck;
    if (last == null) return true;
    return DateTime.now().difference(last) >= _minInterval;
  }

  /// Asks the store what the current release is for [bundleId].
  static Future<UpdateInfo?> _lookup(String bundleId) async {
    // Always the US storefront, which carries every app released anywhere.
    // Deriving it from the device locale guessed wrong often enough to matter
    // -- a Dutch user with an en_US phone, or a locale with no country subtag
    // -- and a wrong storefront answers with an empty list, which is
    // indistinguishable from "no such app".
    final uri = Uri.https(_lookupHost, '/lookup', {
      'bundleId': bundleId,
      'country': _storefront,
    });

    final response = await http.get(uri).timeout(_timeout);
    if (response.statusCode != 200) {
      debugPrint('Update lookup returned ${response.statusCode}');
      return null;
    }

    final body = jsonDecode(response.body);
    if (body is! Map<String, dynamic>) return null;

    final results = body['results'];
    if (results is! List || results.isEmpty) {
      // An app that is not on the store yet answers with an empty list.
      return null;
    }

    final entry = results.first;
    if (entry is! Map<String, dynamic>) return null;

    final version = entry['version'];
    final trackViewUrl = entry['trackViewUrl'];
    if (version is! String || version.isEmpty) return null;
    if (trackViewUrl is! String) return null;

    final storeUrl = Uri.tryParse(trackViewUrl);
    if (storeUrl == null) return null;

    return UpdateInfo(version: version, storeUrl: storeUrl);
  }

  /// Storefront to query. See [_lookup] for why this is not per-device.
  static const String _storefront = 'us';
}
