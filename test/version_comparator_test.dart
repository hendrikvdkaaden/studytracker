import 'package:deadly/services/version_comparator.dart';
import 'package:flutter_test/flutter_test.dart';

/// Deciding "is the store version newer" is the whole update check. Getting
/// it wrong either nags users who are already up to date, or leaves them on
/// an old build without ever saying so.
void main() {
  group('finds a newer version', () {
    test('a higher patch, minor or major', () {
      expect(VersionComparator.isNewer('1.1.1', '1.1.0'), isTrue);
      expect(VersionComparator.isNewer('1.2.0', '1.1.9'), isTrue);
      expect(VersionComparator.isNewer('2.0.0', '1.9.9'), isTrue);
    });

    test('double digits are compared as numbers, not text', () {
      expect(
        VersionComparator.isNewer('1.10.0', '1.9.0'),
        isTrue,
        reason: 'string ordering would put 1.10.0 before 1.9.0',
      );
      expect(VersionComparator.isNewer('1.2.10', '1.2.9'), isTrue);
    });
  });

  group('leaves an up-to-date app alone', () {
    test('the same version', () {
      expect(VersionComparator.isNewer('1.1.0', '1.1.0'), isFalse);
    });

    test('an older store version', () {
      expect(VersionComparator.isNewer('1.0.9', '1.1.0'), isFalse);
      expect(VersionComparator.isNewer('1.1.0', '2.0.0'), isFalse);
    });

    test('a missing part counts as zero', () {
      expect(VersionComparator.isNewer('1.2', '1.2.0'), isFalse);
      expect(VersionComparator.isNewer('1.2.0', '1.2'), isFalse);
      expect(VersionComparator.isNewer('1.2.1', '1.2'), isTrue);
    });
  });

  group('ignores build metadata', () {
    test('a Flutter build number does not make a version newer', () {
      expect(
        VersionComparator.isNewer('1.1.0', '1.1.0+7'),
        isFalse,
        reason: 'the build number is not part of the released version',
      );
      expect(VersionComparator.isNewer('1.1.0+9', '1.1.0+7'), isFalse);
    });

    test('a pre-release tag is dropped', () {
      expect(VersionComparator.isNewer('1.2.0-beta', '1.1.0'), isTrue);
      expect(VersionComparator.isNewer('1.1.0-beta', '1.1.0'), isFalse);
    });
  });

  group('refuses to guess', () {
    test('anything unparseable means no update', () {
      // A bad answer from the store must never send someone to the App Store
      // for a version that may not exist.
      expect(VersionComparator.isNewer('', '1.1.0'), isFalse);
      expect(VersionComparator.isNewer('latest', '1.1.0'), isFalse);
      expect(VersionComparator.isNewer('1.x.0', '1.1.0'), isFalse);
      expect(VersionComparator.isNewer('1.1.0', ''), isFalse);
      expect(VersionComparator.isNewer('-1.0.0', '1.1.0'), isFalse);
    });

    test('surrounding whitespace is tolerated', () {
      expect(VersionComparator.isNewer(' 1.2.0 ', '1.1.0'), isTrue);
    });
  });
}
