import 'package:device_calendar_plus/device_calendar_plus.dart';

import 'auto_planner_service.dart';

/// Turns the user's calendar entries into blocks the auto planner must avoid.
///
/// The read-direction counterpart to [CalendarEventMapper], which builds
/// entries to write. Kept free of platform calls so every rule below can be
/// tested without a device.
class CalendarBusyMapper {
  /// Whether an event should keep the planner out of that time.
  static bool blocksTime(Event event, {String? ownCalendarId}) {
    // Our own entries are already accounted for through existingSessions.
    // Counting them again would make the planner avoid its own plan.
    if (ownCalendarId != null && event.calendarId == ownCalendarId) {
      return false;
    }

    // A cancelled event is not happening, whatever its availability says.
    if (event.status == EventStatus.canceled) return false;

    // All-day entries are birthdays, holidays and "week 12" markers far more
    // often than real commitments, and blocking on them would empty whole
    // days of study time. Their dates are also floating rather than real
    // instants, so there is nothing dependable to block with.
    if (event.isAllDay) return false;

    switch (event.availability) {
      case EventAvailability.free:
        return false;
      case EventAvailability.busy:
      case EventAvailability.unavailable:
      // A tentative meeting is more likely to happen than not, and moving a
      // study block costs less than colliding with a real appointment.
      case EventAvailability.tentative:
      // The calendar cannot say; assume the time is taken.
      case EventAvailability.notSupported:
        return true;
    }
  }

  /// Clips [event] to `[windowStart, windowEnd)`, or null when it does not
  /// block or falls outside the window.
  static BusyBlock? toBusyBlock(
    Event event, {
    required DateTime windowStart,
    required DateTime windowEnd,
    String? ownCalendarId,
  }) {
    if (!blocksTime(event, ownCalendarId: ownCalendarId)) return null;

    final start =
        event.startDate.isBefore(windowStart) ? windowStart : event.startDate;
    final end = event.endDate.isAfter(windowEnd) ? windowEnd : event.endDate;

    // Half-open, matching both the planner's overlap test and the range the
    // plugin lists events for: a zero-length block occupies nothing.
    if (!start.isBefore(end)) return null;

    return BusyBlock(start, end);
  }

  /// The blocks [events] contribute, clipped to the window and merged.
  ///
  /// Merging is not needed for correctness — the planner tests every block —
  /// but a synced work account can hold hundreds of events over a six-week
  /// window, and the planner checks every block for every candidate slot.
  static List<BusyBlock> toBusyBlocks(
    List<Event> events, {
    required DateTime windowStart,
    required DateTime windowEnd,
    String? ownCalendarId,
  }) {
    final blocks = <BusyBlock>[];
    for (final event in events) {
      final block = toBusyBlock(
        event,
        windowStart: windowStart,
        windowEnd: windowEnd,
        ownCalendarId: ownCalendarId,
      );
      if (block != null) blocks.add(block);
    }

    return mergeOverlapping(blocks);
  }

  /// Collapses overlapping and touching blocks into as few as cover the same
  /// time. Blocks that only touch are joined too: back-to-back meetings leave
  /// no usable gap between them.
  static List<BusyBlock> mergeOverlapping(List<BusyBlock> blocks) {
    if (blocks.length < 2) return List<BusyBlock>.from(blocks);

    final sorted = List<BusyBlock>.from(blocks)
      ..sort((a, b) => a.start.compareTo(b.start));

    final merged = <BusyBlock>[sorted.first];
    for (final block in sorted.skip(1)) {
      final last = merged.last;
      if (block.start.isAfter(last.end)) {
        merged.add(block);
        continue;
      }
      if (block.end.isAfter(last.end)) {
        merged[merged.length - 1] = BusyBlock(last.start, block.end);
      }
    }
    return merged;
  }
}
