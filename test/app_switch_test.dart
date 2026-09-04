import 'package:deadly/theme/app_theme_extension.dart';
import 'package:deadly/widgets/common/app_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The switch is drawn rather than borrowed, because Flutter's own tracks are
/// a fixed size and scaling one to this shape stretches its knob into an oval.
///
/// Only the tap behaviour is asserted here; the drawn shape is free to change.
void main() {
  Future<void> pump(
    WidgetTester tester, {
    required bool value,
    ValueChanged<bool>? onChanged,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [AppTheme.light]),
        home: Scaffold(
          body: Center(
            child: AppSwitch(value: value, onChanged: onChanged ?? (_) {}),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('tapping reports the opposite of what it shows',
      (tester) async {
    bool? reported;
    await pump(tester, value: false, onChanged: (v) => reported = v);

    await tester.tap(find.byType(AppSwitch));

    expect(reported, isTrue);
  });

  testWidgets('tapping the track beside the knob counts too', (tester) async {
    // HitTestBehavior.opaque: the gap between knob and edge is still the
    // switch, not a hole through to whatever is behind it.
    bool? reported;
    await pump(tester, value: false, onChanged: (v) => reported = v);

    final track = tester.getRect(find.byType(AppSwitch));
    await tester.tapAt(Offset(track.right - 4, track.center.dy));

    expect(reported, isTrue);
  });
}
