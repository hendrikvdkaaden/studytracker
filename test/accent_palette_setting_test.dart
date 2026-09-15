import 'dart:io';

import 'package:deadly/services/settings_service.dart';
import 'package:deadly/theme/accent_palette.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

/// The accent choice is stored as an index into [AccentPalette.all], which
/// makes that list's order append-only: reordering it would silently change
/// the colour everyone already picked.
void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('accent_setting');
    Hive.init(tempDir.path);
    await Hive.openBox('settings');
  });

  tearDown(() async {
    await Hive.box('settings').deleteFromDisk();
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('a fresh install gets the colour the app shipped with', () {
    expect(SettingsService.accentPaletteIndex, 0);
    expect(AccentPalette.byId(SettingsService.accentPaletteIndex),
        AccentPalette.all.first);
  });

  test('a choice survives a restart', () async {
    await SettingsService.setAccentPaletteIndex(3);

    await Hive.close();
    Hive.init(tempDir.path);
    await Hive.openBox('settings');

    expect(SettingsService.accentPaletteIndex, 3);
  });

  test('an index from a build with more colours does not crash', () async {
    // Downgrade: the stored index points past the end of the list.
    await SettingsService.setAccentPaletteIndex(99);

    expect(
      AccentPalette.byId(SettingsService.accentPaletteIndex),
      AccentPalette.all.first,
      reason: 'an unknown colour must fall back, not throw',
    );
  });

  test('every index maps to a distinct colour', () async {
    final seen = <int>{};
    for (var i = 0; i < AccentPalette.all.length; i++) {
      await SettingsService.setAccentPaletteIndex(i);
      seen.add(AccentPalette.byId(SettingsService.accentPaletteIndex)
          .accent
          .toARGB32());
    }

    expect(seen.length, AccentPalette.all.length);
  });
}
