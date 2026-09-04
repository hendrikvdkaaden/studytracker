import 'package:deadly/models/study_session.dart';
import 'package:deadly/theme/app_theme_extension.dart';
import 'package:deadly/widgets/common/planned_session_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Deleting a planned session was easy to miss: the icon was 18pt and its hit
/// area was exactly the icon. Missing it lands on the row, which opens the
/// editor — the wrong thing entirely.
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

  testWidgets('the delete target is big enough for a fingertip',
      (tester) async {
    await pump(tester, onDelete: () {});

    final target = tester.getSize(
      find.ancestor(
        of: find.byIcon(Icons.delete_outline),
        matching: find.byType(InkWell),
      ),
    );

    // 44pt is Apple's minimum; 40 is the practical floor for an icon button
    // sitting inside a row this height.
    expect(target.width, greaterThanOrEqualTo(40));
    expect(target.height, greaterThanOrEqualTo(40));
  });

  testWidgets('the icon itself stays small', (tester) async {
    await pump(tester, onDelete: () {});

    final icon = tester.widget<Icon>(find.byIcon(Icons.delete_outline));

    expect(
      icon.size,
      18,
      reason: 'a bigger target must not mean a heavier-looking row',
    );
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
