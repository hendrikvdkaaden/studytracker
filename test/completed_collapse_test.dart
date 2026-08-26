import 'dart:io';

import 'package:deadly/services/settings_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

/// Hiding the completed section has to survive a restart -- someone who folds
/// their finished deadlines away does not want them back on the next launch.
void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('completed_collapse');
    Hive.init(tempDir.path);
    await Hive.openBox('settings');
  });

  tearDown(() async {
    await Hive.box('settings').deleteFromDisk();
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('starts expanded', () {
    expect(
      SettingsService.completedCollapsed,
      isFalse,
      reason: 'a new user should see what they finished',
    );
  });

  test('remembers being hidden', () async {
    await SettingsService.setCompletedCollapsed(true);

    expect(SettingsService.completedCollapsed, isTrue);
  });

  test('remembers being shown again', () async {
    await SettingsService.setCompletedCollapsed(true);
    await SettingsService.setCompletedCollapsed(false);

    expect(SettingsService.completedCollapsed, isFalse);
  });
}
