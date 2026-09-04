import 'package:deadly/utils/format_helpers.dart';
import 'package:flutter_test/flutter_test.dart';

/// The week strip on the home screen scrolls freely, so it names the month it
/// is showing. A week can straddle two months, and once a year two years, and
/// the label has to stay honest in both.
void main() {
  String label(DateTime first, DateTime last) =>
      FormatHelpers.formatWeekMonth(first, last);

  test('a week inside one month names it in full', () {
    expect(
      label(DateTime(2026, 9, 14), DateTime(2026, 9, 20)),
      'September 2026',
    );
  });

  test('a week across two months names both', () {
    expect(
      label(DateTime(2026, 9, 28), DateTime(2026, 10, 4)),
      'Sep - Oct 2026',
      reason: 'naming only one would be wrong for half the week',
    );
  });

  test('a week across new year names both years', () {
    expect(
      label(DateTime(2026, 12, 28), DateTime(2027, 1, 3)),
      'Dec 2026 - Jan 2027',
    );
  });

  test('the year is stated once when the week does not cross one', () {
    expect(label(DateTime(2026, 1, 5), DateTime(2026, 1, 11)), 'January 2026');
    expect(
      label(DateTime(2026, 1, 26), DateTime(2026, 2, 1)),
      'Jan - Feb 2026',
    );
  });

  test('a single day works', () {
    // Not how the strip calls it, but the helper should not assume a span.
    expect(
      label(DateTime(2026, 3, 9), DateTime(2026, 3, 9)),
      'March 2026',
    );
  });
}
