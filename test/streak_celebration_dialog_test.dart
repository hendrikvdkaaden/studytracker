import 'package:confetti/confetti.dart';
import 'package:deadly/l10n/app_localizations.dart';
import 'package:deadly/services/streak_freeze_service.dart';
import 'package:deadly/theme/app_theme_extension.dart';
import 'package:deadly/widgets/common/streak_celebration_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// The two dialogs share a shell but must not share a tone.
///
/// A rescued streak is news; a grown streak is an achievement. Celebrating a
/// day the user did not study would congratulate them for nothing, so the
/// confetti belongs to exactly one of the two.
void main() {
  Future<void> pumpHost(
    WidgetTester tester, {
    required void Function(BuildContext) onReady,
    bool dark = false,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: [dark ? AppTheme.dark : AppTheme.light],
        ),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => onReady(context),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    // Pumped past the 1100ms hero animation rather than settled: the confetti
    // controller never quiesces, so pumpAndSettle times out on the
    // celebration variant.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1300));
  }

  group('the streak celebration', () {
    testWidgets('shows the streak it was given', (tester) async {
      await pumpHost(
        tester,
        onReady: (context) =>
            showStreakCelebrationDialog(context: context, streak: 8),
      );

      expect(find.text('8'), findsOneWidget);
      expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
    });

    testWidgets('a first day settles on one', (tester) async {
      await pumpHost(
        tester,
        onReady: (context) =>
            showStreakCelebrationDialog(context: context, streak: 1),
      );

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('both numbers are on screen so one can push the other out',
        (tester) async {
      // The slide keeps the outgoing and incoming totals mounted together.
      // Asserting only the final value cannot tell a slide from a number that
      // simply appeared -- which is exactly how a version with no animation at
      // all once shipped looking correct.
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppTheme.light]),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () =>
                    showStreakCelebrationDialog(context: context, streak: 9),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));

      expect(find.text('8'), findsOneWidget, reason: 'the outgoing total');
      expect(find.text('9'), findsOneWidget, reason: 'the incoming total');
    });

    testWidgets('the new number rises into place as the old one leaves',
        (tester) async {
      // Position, not presence: both digits exist for the whole run, so only
      // their offsets show that anything actually moved.
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppTheme.light]),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () =>
                    showStreakCelebrationDialog(context: context, streak: 9),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));

      final startNew = tester.getTopLeft(find.text('9')).dy;
      final startOld = tester.getTopLeft(find.text('8')).dy;

      await tester.pump(const Duration(milliseconds: 1300));

      final endNew = tester.getTopLeft(find.text('9')).dy;
      final endOld = tester.getTopLeft(find.text('8')).dy;

      expect(endNew, lessThan(startNew), reason: 'the new total travels up');
      expect(endOld, lessThan(startOld), reason: 'the old total is pushed up');
      expect(
        endOld,
        lessThan(endNew),
        reason: 'the old one ends above the new one, having been pushed out',
      );
    });

    testWidgets('a first streak has no outgoing number', (tester) async {
      // A leading "0" sliding away would suggest a streak the user never had.
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppTheme.light]),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () =>
                    showStreakCelebrationDialog(context: context, streak: 1),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));

      expect(find.text('0'), findsNothing);
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('fires confetti', (tester) async {
      await pumpHost(
        tester,
        onReady: (context) =>
            showStreakCelebrationDialog(context: context, streak: 5),
      );

      expect(find.byType(ConfettiWidget), findsOneWidget);
    });

    testWidgets('closes on the button', (tester) async {
      await pumpHost(
        tester,
        onReady: (context) =>
            showStreakCelebrationDialog(context: context, streak: 5),
      );

      expect(find.byType(Dialog), findsOneWidget);
      await tester.tap(find.text("Let's go"));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(Dialog), findsNothing);
    });
  });

  group('the freeze rescue', () {
    FreezeOutcome outcome({int days = 1, int left = 1}) => FreezeOutcome(
          daysFrozen: [
            for (var i = 0; i < days; i++) DateTime(2026, 9, 10 + i),
          ],
          freezesEarned: 0,
          freezesAvailable: left,
        );

    testWidgets('shows the snowflake, not the flame', (tester) async {
      await pumpHost(
        tester,
        onReady: (context) =>
            showFreezeRescueDialog(context: context, outcome: outcome()),
      );

      expect(find.byIcon(Icons.ac_unit), findsOneWidget);
      expect(find.byIcon(Icons.local_fire_department), findsNothing);
    });

    testWidgets('does not celebrate', (tester) async {
      // The day was not studied. Confetti here would congratulate the user for
      // a day the app itself covered.
      await pumpHost(
        tester,
        onReady: (context) =>
            showFreezeRescueDialog(context: context, outcome: outcome()),
      );

      expect(find.byType(ConfettiWidget), findsNothing);
    });

    testWidgets('names how many freezes are left', (tester) async {
      await pumpHost(
        tester,
        onReady: (context) => showFreezeRescueDialog(
          context: context,
          outcome: outcome(left: 2),
        ),
      );

      expect(find.textContaining('2'), findsWidgets);
    });

    testWidgets('reads differently when several days were covered',
        (tester) async {
      await pumpHost(
        tester,
        onReady: (context) => showFreezeRescueDialog(
          context: context,
          outcome: outcome(days: 2),
        ),
      );

      expect(find.textContaining('2 missed days'), findsOneWidget);
    });

    testWidgets('renders in dark mode', (tester) async {
      await pumpHost(
        tester,
        dark: true,
        onReady: (context) =>
            showFreezeRescueDialog(context: context, outcome: outcome()),
      );

      expect(find.byIcon(Icons.ac_unit), findsOneWidget);
    });
  });
}
