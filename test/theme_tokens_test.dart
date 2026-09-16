import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:deadly/theme/app_theme_extension.dart';

/// Where a brightness branch is legitimate: the token definitions themselves,
/// and the helpers on AppTheme that return a per-brightness *alpha*.
const _allowedIsDark = {'lib/theme/app_theme_extension.dart'};

/// Reading `isDark` for a helper argument is fine; what is banned is
/// branching on it to pick between two colors. These catch the branch.
final _banned = <String, RegExp>{
  'a colour chosen by a brightness ternary':
      RegExp(r'isDark\s*\n?\s*\?[^;]{0,200}?:\s*[^;]{0,200}?(Color|Colors\.|'
          r'AppColors\.|context\.colors\.|colors\.)'),
  'Theme.of(context).brightness read directly in a widget':
      RegExp(r'Theme\.of\([^)]*\)\.brightness'),
};

/// Strips `//` comments so prose *describing* the banned pattern (this file's
/// own guidance, and app_colors.dart's) does not read as a violation.
String _stripComments(String source) {
  return source
      .split('\n')
      .map((line) {
        final i = line.indexOf('//');
        return i == -1 ? line : line.substring(0, i);
      })
      .join('\n');
}

Iterable<File> _dartFiles(String root) sync* {
  for (final e in Directory(root).listSync(recursive: true)) {
    if (e is File && e.path.endsWith('.dart')) yield e;
  }
}

void main() {
  group('theme tokens', () {
    test('no widget picks a colour by branching on brightness', () {
      final offenders = <String>[];

      for (final file in _dartFiles('lib')) {
        final rel = file.path.replaceFirst(RegExp(r'^.*?(?=lib/)'), '');
        if (_allowedIsDark.contains(rel)) continue;

        final source = _stripComments(file.readAsStringSync());
        for (final entry in _banned.entries) {
          if (entry.value.hasMatch(source)) {
            offenders.add('$rel — ${entry.key}');
          }
        }
      }

      expect(
        offenders,
        isEmpty,
        reason: 'Colours that differ between light and dark belong on AppTheme '
            'as a token, reached with context.colors.<token>. See the theming '
            'section of CLAUDE.md.\nOffenders:\n${offenders.join('\n')}',
      );
    });

    test('light and dark define every token', () {
      // copyWith with nothing set must round-trip, which only holds if every
      // field is threaded through it — the usual place a new token is missed.
      expect(AppTheme.light.copyWith(), AppTheme.light);
      expect(AppTheme.dark.copyWith(), AppTheme.dark);
    });

    test('lerp is total — no token is dropped mid-animation', () {
      expect(AppTheme.light.lerp(AppTheme.dark, 0), AppTheme.light);
      expect(AppTheme.light.lerp(AppTheme.dark, 1), AppTheme.dark);
    });

    test('dark mode draws its accent-on-surface lighter than its card', () {
      // The whole reason accentOnSurface exists: on a dark card the solid
      // accent is unreadable, so the token must resolve to the pale end.
      double luminance(Color c) => c.computeLuminance();
      expect(
        luminance(AppTheme.dark.accentOnSurface),
        greaterThan(luminance(AppTheme.dark.card)),
      );
      expect(
        luminance(AppTheme.light.accentOnSurface),
        lessThan(luminance(AppTheme.light.card)),
      );
    });
  });
}
