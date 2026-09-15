import 'package:deadly/widgets/common/pending_value_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// That a value parked after startup is still noticed.
///
/// The bug this exists for: the streak celebration was drained from a
/// post-frame callback in HomePage.initState. That runs once, at cold start.
/// A streak grows mid-session, hours later, so the value was set and then sat
/// unread until the next launch -- finishing the first session of the day
/// produced no dialog at all.
///
/// An earlier version of this file asserted that ValueNotifier notifies its
/// listeners, which Flutter guarantees. Removing the subscription from
/// HomePage -- reintroducing the exact bug -- left all 310 tests green. These
/// pump the subscription itself, so they can fail.
void main() {
  Future<void> pump(
    WidgetTester tester, {
    required ValueNotifier<int?> notifier,
    required Future<void> Function(int) onValue,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PendingValueListener<int>(
          notifier: notifier,
          onValue: onValue,
          child: const Scaffold(body: Text('body')),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('a value arriving after the first frame is handled',
      (tester) async {
    // The regression. A startup-only read never sees this.
    final notifier = ValueNotifier<int?>(null);
    addTearDown(notifier.dispose);
    final seen = <int>[];

    await pump(tester, notifier: notifier, onValue: (v) async => seen.add(v));
    expect(seen, isEmpty);

    notifier.value = 1;
    await tester.pump();
    await tester.pump();

    expect(seen, [1], reason: 'the subscription must outlive the first frame');
  });

  testWidgets('a value parked before the widget existed is still handled',
      (tester) async {
    // The splash screen writes a freeze outcome before HomePage is built.
    final notifier = ValueNotifier<int?>(7);
    addTearDown(notifier.dispose);
    final seen = <int>[];

    await pump(tester, notifier: notifier, onValue: (v) async => seen.add(v));
    await tester.pump();

    expect(seen, [7]);
  });

  testWidgets('the value is cleared so it is handled only once',
      (tester) async {
    final notifier = ValueNotifier<int?>(null);
    addTearDown(notifier.dispose);
    final seen = <int>[];

    await pump(tester, notifier: notifier, onValue: (v) async => seen.add(v));

    notifier.value = 3;
    await tester.pump();
    await tester.pump();

    expect(seen, [3]);
    expect(notifier.value, isNull);
  });

  testWidgets('several values in a row are handled one at a time',
      (tester) async {
    // Two sessions finished in quick succession must not stack two dialogs.
    final notifier = ValueNotifier<int?>(null);
    addTearDown(notifier.dispose);
    final seen = <int>[];
    var inFlight = 0;
    var maxConcurrent = 0;

    await pump(
      tester,
      notifier: notifier,
      onValue: (v) async {
        inFlight++;
        maxConcurrent = inFlight > maxConcurrent ? inFlight : maxConcurrent;
        await Future<void>.delayed(const Duration(milliseconds: 50));
        seen.add(v);
        inFlight--;
      },
    );

    notifier.value = 1;
    await tester.pump();
    await tester.pump();
    notifier.value = 2;
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    expect(maxConcurrent, 1, reason: 'two at once would stack two dialogs');
    expect(seen, [1, 2], reason: 'the second must not be dropped');
  });

  testWidgets('nothing is handled after the widget is gone', (tester) async {
    final notifier = ValueNotifier<int?>(null);
    addTearDown(notifier.dispose);
    final seen = <int>[];

    await pump(tester, notifier: notifier, onValue: (v) async => seen.add(v));

    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    notifier.value = 9;
    await tester.pump();
    await tester.pump();

    expect(seen, isEmpty, reason: 'a disposed state must not be asked to show');
  });

  testWidgets('a null value is not handled', (tester) async {
    final notifier = ValueNotifier<int?>(5);
    addTearDown(notifier.dispose);
    final seen = <int>[];

    await pump(tester, notifier: notifier, onValue: (v) async => seen.add(v));
    await tester.pump();
    seen.clear();

    notifier.value = null;
    await tester.pump();
    await tester.pump();

    expect(seen, isEmpty);
  });
}
