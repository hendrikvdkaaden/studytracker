import 'package:deadly/theme/app_theme_extension.dart';
import 'package:deadly/widgets/common/app_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The switch is drawn rather than borrowed, because Flutter's own tracks are
/// a fixed size and scaling one to this shape stretches its knob into an oval.
/// These pin the geometry that made it worth drawing.
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

  Rect knob(WidgetTester tester) => tester.getRect(
        find
            .descendant(
              of: find.byType(AppSwitch),
              matching: find.byType(Container),
            )
            .last,
      );

  testWidgets('the track is 52 by 22', (tester) async {
    await pump(tester, value: false);

    expect(tester.getSize(find.byType(AppSwitch)), const Size(52, 22));
  });

  testWidgets('the knob is 30 by 18', (tester) async {
    await pump(tester, value: false);

    final k = knob(tester);

    expect(k.width, 30);
    expect(k.height, 18);
  });

  testWidgets('2pt of track shows all the way around the knob',
      (tester) async {
    // The inset is what makes it read as a knob sitting in a track rather
    // than a block filling one, so it has to survive any resizing.
    await pump(tester, value: false);

    final track = tester.getRect(find.byType(AppSwitch));
    final k = knob(tester);

    expect(k.top - track.top, 2);
    expect(track.bottom - k.bottom, 2);
    expect(k.left - track.left, 2);
  });

  testWidgets('the knob sits left when off and right when on', (tester) async {
    await pump(tester, value: false);
    final track = tester.getRect(find.byType(AppSwitch));
    final off = knob(tester).left - track.left;

    await pump(tester, value: true);
    final on = knob(tester).left - tester.getRect(find.byType(AppSwitch)).left;

    expect(off, 2, reason: '2pt of track shows beside the knob');
    expect(on, 20);
    expect(on, greaterThan(off));
  });

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
