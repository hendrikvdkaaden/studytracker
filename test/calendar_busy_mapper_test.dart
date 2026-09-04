import 'package:deadly/services/auto_planner_service.dart';
import 'package:deadly/services/calendar_busy_mapper.dart';
import 'package:device_calendar_plus/device_calendar_plus.dart';
import 'package:flutter_test/flutter_test.dart';

/// Which calendar entries keep the planner out of a time slot, and which are
/// ignored. Getting this wrong is quiet: too strict and the planner reports it
/// could not fit anything, too loose and study time lands on a real
/// appointment.
void main() {
  final windowStart = DateTime(2026, 9, 14, 0);
  final windowEnd = DateTime(2026, 9, 21, 0);

  Event event({
    DateTime? start,
    DateTime? end,
    bool isAllDay = false,
    EventAvailability availability = EventAvailability.busy,
    EventStatus status = EventStatus.confirmed,
    String calendarId = 'work',
  }) {
    return Event(
      eventId: 'e1',
      instanceId: 'i1',
      calendarId: calendarId,
      title: 'Dentist',
      startDate: start ?? DateTime(2026, 9, 15, 14),
      endDate: end ?? DateTime(2026, 9, 15, 15),
      isAllDay: isAllDay,
      availability: availability,
      status: status,
      isRecurring: false,
    );
  }

  BusyBlock? block(Event e, {String? ownCalendarId}) =>
      CalendarBusyMapper.toBusyBlock(
        e,
        windowStart: windowStart,
        windowEnd: windowEnd,
        ownCalendarId: ownCalendarId,
      );

  group('what counts as busy', () {
    test('a normal appointment blocks its time', () {
      final b = block(event());

      expect(b, isNotNull);
      expect(b!.start, DateTime(2026, 9, 15, 14));
      expect(b.end, DateTime(2026, 9, 15, 15));
    });

    test('an event marked free does not', () {
      expect(block(event(availability: EventAvailability.free)), isNull);
    });

    test('tentative and unavailable both block', () {
      // A tentative meeting is likelier to happen than not, and moving a
      // study block costs less than colliding with a real appointment.
      expect(block(event(availability: EventAvailability.tentative)), isNotNull);
      expect(
        block(event(availability: EventAvailability.unavailable)),
        isNotNull,
      );
    });

    test('a calendar that cannot say is treated as busy', () {
      expect(
        block(event(availability: EventAvailability.notSupported)),
        isNotNull,
        reason: 'assuming free would schedule over real commitments',
      );
    });

    test('a cancelled event does not block, however it is marked', () {
      expect(
        block(event(
          status: EventStatus.canceled,
          availability: EventAvailability.busy,
        )),
        isNull,
      );
    });
  });

  group('all-day entries', () {
    test('do not block the day', () {
      // Birthdays, holidays and "week 12" markers vastly outnumber real
      // all-day commitments; blocking on them would empty whole days.
      expect(
        block(event(
          isAllDay: true,
          start: DateTime(2026, 9, 15),
          end: DateTime(2026, 9, 16),
        )),
        isNull,
      );
    });
  });

  group('our own calendar', () {
    test('is excluded, because those sessions are already accounted for', () {
      expect(
        block(event(calendarId: 'deadly-cal'), ownCalendarId: 'deadly-cal'),
        isNull,
      );
    });

    test('every other calendar still counts', () {
      expect(
        block(event(calendarId: 'work'), ownCalendarId: 'deadly-cal'),
        isNotNull,
      );
    });

    test('nothing is excluded when we have no calendar of our own', () {
      expect(block(event(calendarId: 'work'), ownCalendarId: null), isNotNull);
    });
  });

  group('clipping to the planning window', () {
    test('an event starting before the window starts at the window', () {
      final b = block(event(
        start: DateTime(2026, 9, 13, 22),
        end: DateTime(2026, 9, 14, 2),
      ));

      expect(b!.start, windowStart);
      expect(b.end, DateTime(2026, 9, 14, 2));
    });

    test('an event running past the window ends at the window', () {
      final b = block(event(
        start: DateTime(2026, 9, 20, 22),
        end: DateTime(2026, 9, 22, 10),
      ));

      expect(b!.start, DateTime(2026, 9, 20, 22));
      expect(b.end, windowEnd);
    });

    test('an event spanning the whole window becomes the whole window', () {
      final b = block(event(
        start: DateTime(2026, 9, 1),
        end: DateTime(2026, 10, 1),
      ));

      expect(b!.start, windowStart);
      expect(b.end, windowEnd);
    });

    test('events entirely outside the window are dropped', () {
      expect(
        block(event(
          start: DateTime(2026, 9, 10),
          end: DateTime(2026, 9, 11),
        )),
        isNull,
      );
      expect(
        block(event(
          start: DateTime(2026, 9, 25),
          end: DateTime(2026, 9, 26),
        )),
        isNull,
      );
    });

    test('a zero-length event occupies nothing', () {
      final at = DateTime(2026, 9, 15, 14);

      expect(block(event(start: at, end: at)), isNull);
    });

    test('an event ending exactly at the window start is dropped', () {
      expect(
        block(event(
          start: DateTime(2026, 9, 13, 20),
          end: windowStart,
        )),
        isNull,
        reason: 'the range is half-open, so it occupies no time inside it',
      );
    });
  });

  group('merging', () {
    List<BusyBlock> merge(List<List<DateTime>> pairs) =>
        CalendarBusyMapper.mergeOverlapping(
          [for (final p in pairs) BusyBlock(p[0], p[1])],
        );

    test('overlapping blocks become one', () {
      final merged = merge([
        [DateTime(2026, 9, 15, 9), DateTime(2026, 9, 15, 11)],
        [DateTime(2026, 9, 15, 10), DateTime(2026, 9, 15, 12)],
      ]);

      expect(merged.length, 1);
      expect(merged.single.start, DateTime(2026, 9, 15, 9));
      expect(merged.single.end, DateTime(2026, 9, 15, 12));
    });

    test('back-to-back blocks become one', () {
      // Meetings that touch leave no usable gap between them.
      final merged = merge([
        [DateTime(2026, 9, 15, 9), DateTime(2026, 9, 15, 10)],
        [DateTime(2026, 9, 15, 10), DateTime(2026, 9, 15, 11)],
      ]);

      expect(merged.length, 1);
      expect(merged.single.end, DateTime(2026, 9, 15, 11));
    });

    test('a block inside another is swallowed', () {
      final merged = merge([
        [DateTime(2026, 9, 15, 9), DateTime(2026, 9, 15, 17)],
        [DateTime(2026, 9, 15, 12), DateTime(2026, 9, 15, 13)],
      ]);

      expect(merged.length, 1);
      expect(merged.single.end, DateTime(2026, 9, 15, 17));
    });

    test('separate blocks stay separate', () {
      final merged = merge([
        [DateTime(2026, 9, 15, 9), DateTime(2026, 9, 15, 10)],
        [DateTime(2026, 9, 15, 14), DateTime(2026, 9, 15, 15)],
      ]);

      expect(merged.length, 2);
    });

    test('order does not matter', () {
      final merged = merge([
        [DateTime(2026, 9, 15, 14), DateTime(2026, 9, 15, 15)],
        [DateTime(2026, 9, 15, 9), DateTime(2026, 9, 15, 10)],
      ]);

      expect(merged.length, 2);
      expect(merged.first.start, DateTime(2026, 9, 15, 9));
    });
  });

  group('the whole pipeline', () {
    test('filters, clips and merges in one pass', () {
      final blocks = CalendarBusyMapper.toBusyBlocks(
        [
          event(
            start: DateTime(2026, 9, 15, 9),
            end: DateTime(2026, 9, 15, 11),
          ),
          event(
            start: DateTime(2026, 9, 15, 10),
            end: DateTime(2026, 9, 15, 12),
          ),
          event(availability: EventAvailability.free),
          event(isAllDay: true),
          event(calendarId: 'deadly-cal'),
        ],
        windowStart: windowStart,
        windowEnd: windowEnd,
        ownCalendarId: 'deadly-cal',
      );

      expect(blocks.length, 1);
      expect(blocks.single.start, DateTime(2026, 9, 15, 9));
      expect(blocks.single.end, DateTime(2026, 9, 15, 12));
    });

    test('an empty calendar blocks nothing', () {
      expect(
        CalendarBusyMapper.toBusyBlocks(
          const [],
          windowStart: windowStart,
          windowEnd: windowEnd,
          ownCalendarId: null,
        ),
        isEmpty,
      );
    });
  });
}
