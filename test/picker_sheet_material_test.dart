import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The option sheets (theme, accent colour) are a background-painting box
/// wrapping a column of ListTiles. Flutter asserts on that combination: a
/// tile paints its ink splash on the nearest Material ancestor, so a plain
/// Container in between covers the splash it is supposed to show.
///
/// The sheet therefore paints with a Material rather than a decoration.
/// These pin both halves -- that the old shape really does throw, and that
/// the shape now shipped does not -- so the picker cannot quietly regress to
/// a Container.
void main() {
  Widget sheet({required Widget Function(Widget child) wrapper}) {
    return MaterialApp(
      home: Scaffold(
        body: wrapper(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(title: const Text('System'), onTap: () {}),
              ListTile(title: const Text('Light'), onTap: () {}),
              ListTile(title: const Text('Dark'), onTap: () {}),
            ],
          ),
        ),
      ),
    );
  }

  testWidgets('a decorated box over the tiles is what Flutter rejects',
      (tester) async {
    await tester.pumpWidget(
      sheet(
        wrapper: (child) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: child,
        ),
      ),
    );

    // One assertion per tile, so the framework hands back a combined
    // exception rather than a single AssertionError.
    expect(
      tester.takeException().toString(),
      contains('Multiple exceptions (3)'),
    );
  });

  testWidgets('painting with a Material instead is clean', (tester) async {
    await tester.pumpWidget(
      sheet(
        wrapper: (child) => Material(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          clipBehavior: Clip.antiAlias,
          child: child,
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(ListTile), findsNWidgets(3));
  });
}
