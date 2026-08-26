/// Compares semantic version strings like "1.2.0".
///
/// Kept apart from [UpdateService] so the comparison — the part that decides
/// whether a user is nagged — can be tested without a network call.
class VersionComparator {
  /// Whether [storeVersion] is newer than [currentVersion].
  ///
  /// Returns false whenever either version cannot be read as a sequence of
  /// numbers. A malformed answer from the store must never prompt someone to
  /// update to something that may not exist.
  static bool isNewer(String storeVersion, String currentVersion) {
    final store = _parse(storeVersion);
    final current = _parse(currentVersion);
    if (store == null || current == null) return false;

    // Compare part by part, treating a missing part as 0 so "1.2" and
    // "1.2.0" are the same version.
    final length = store.length > current.length ? store.length : current.length;
    for (var i = 0; i < length; i++) {
      final s = i < store.length ? store[i] : 0;
      final c = i < current.length ? current[i] : 0;
      if (s != c) return s > c;
    }
    return false;
  }

  /// Splits a version into its numeric parts, or null if it is not a version.
  ///
  /// Anything after a `+` or `-` is dropped, so a Flutter build number
  /// ("1.2.0+7") or a pre-release tag ("1.2.0-beta") compares on the release
  /// version alone.
  static List<int>? _parse(String version) {
    var trimmed = version.trim();
    if (trimmed.isEmpty) return null;

    for (final separator in ['+', '-']) {
      final index = trimmed.indexOf(separator);
      if (index != -1) trimmed = trimmed.substring(0, index);
    }

    final parts = trimmed.split('.');
    final numbers = <int>[];
    for (final part in parts) {
      final value = int.tryParse(part.trim());
      if (value == null || value < 0) return null;
      numbers.add(value);
    }
    return numbers.isEmpty ? null : numbers;
  }
}
