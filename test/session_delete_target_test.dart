import 'package:deadly/models/study_session.dart';
import 'package:deadly/theme/app_theme_extension.dart';
import 'package:deadly/widgets/common/planned_session_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Deleting a planned session was easy to miss: the icon was 18pt and its hit
/// area was exactly the icon. Missing it lands on the row, which opens the
/// editor — the wrong thing entirely.
///
/// The target grew sideways rather than in every direction, because the row
/// has to keep the height it had.
void main() {
  StudySession session() => StudySession(
        id: 's1',
        goalId: 'g1',
        date: DateTime(2026, 9, 14),
        duration: 60,
        startTime: DateTime(2026, 9, 14, 14),
      );

  Future<void> pump(
    WidgetTester tester, {
    VoidCallback? onDelete,
    VoidCallback? onEdit,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [AppTheme.light]),
        home: Scaffold(
          body: PlannedSessionItem(
            session: session(),
            index: 0,
            title: 'Chapter 7',
            onEdit: onEdit,
            onDelete: onDelete,
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('the delete target is wider than the icon', (tester) async {
    await pump(tester, onDelete: () {});

    final target = tester.getSize(
      find.ancestor(
        of: find.byIcon(Icons.delete_outline),
        matching: find.byType(InkWell),
      ),
    );
    final icon = tester.widget<Icon>(find.byIcon(Icons.delete_outline));

    expect(
      target.width,
      greaterThan(icon.size! * 1.5),
      reason: 'the icon alone was the whole target, and too small to hit',
    );
  });

  testWidgets('the row keeps the height it had', (tester) async {
    // A taller target would push every session card down the list.
    await pump(tester, onDelete: () {});

    final target = tester.getSize(
      find.ancestor(
        of: find.byIcon(Icons.delete_outline),
        matching: find.byType(InkWell),
      ),
    );

    expect(target.height, lessThanOrEqualTo(20));
  });

  testWidgets('tapping it deletes rather than opening the editor',
      (tester) async {
    var deleted = 0;
    var edited = 0;
    await pump(tester, onDelete: () => deleted++, onEdit: () => edited++);

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pump();

    expect(deleted, 1);
    expect(edited, 0, reason: 'the row underneath must not also fire');
  });

  testWidgets('no delete target at all when deleting is not offered',
      (tester) async {
    await pump(tester);

    expect(find.byIcon(Icons.delete_outline), findsNothing);
  });
}
