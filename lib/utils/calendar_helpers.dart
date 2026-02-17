/// Helper utilities for calendar calculations and date operations
class CalendarHelpers {
  CalendarHelpers._(); // Private constructor to prevent instantiation

  /// Checks if two dates represent the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Calculates calendar information for a given month
  static CalendarInfo getCalendarInfo(DateTime focusedMonth) {
    final firstDay = _getFirstDayOfMonth(focusedMonth);
    final lastDay = _getLastDayOfMonth(focusedMonth);
    final previousMonthLastDay = _getLastDayOfPreviousMonth(focusedMonth);

    return CalendarInfo(
      startingWeekday: _calculateStartingWeekday(firstDay),
      daysInMonth: lastDay.day,
      daysInPreviousMonth: previousMonthLastDay.day,
    );
  }

  /// Determines which type of cell (previous/current/next month) based on day offset
  static CellType determineCellType(int dayOffset, int daysInMonth) {
    if (dayOffset < 0) return CellType.previousMonth;
    if (dayOffset >= daysInMonth) return CellType.nextMonth;
    return CellType.currentMonth;
  }

  /// Calculates the day number for a cell in the previous month
  static int calculatePreviousMonthDay(int dayOffset, int daysInPreviousMonth) {
    return daysInPreviousMonth + dayOffset + 1;
  }

  /// Calculates the day number for a cell in the next month
  static int calculateNextMonthDay(int dayOffset, int daysInMonth) {
    return dayOffset - daysInMonth + 1;
  }

  // Private helper methods
  static DateTime _getFirstDayOfMonth(DateTime month) {
    return DateTime(month.year, month.month, 1);
  }
  static DateTime _getLastDayOfMonth(DateTime month) {
    return DateTime(month.year, month.month + 1, 0);
  }
  static DateTime _getLastDayOfPreviousMonth(DateTime month) {
    return DateTime(month.year, month.month, 0);
  }

  /// Calculates which column (0-6) the first day of the month falls in.
  /// Returns: Monday = 0, Tuesday = 1, ..., Sunday = 6
  /// Dart's DateTime.weekday uses 1-7 (Mon-Sun), so we subtract 1 for 0-indexed grid.
  static int _calculateStartingWeekday(DateTime firstDay) {
    return firstDay.weekday - 1;
  }

  /// Returns the Monday of the week containing the given date.
  static DateTime getStartOfWeek(DateTime date) {
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: date.weekday - 1));
  }
}

/// Contains calculated information about a calendar month
class CalendarInfo {
  final int startingWeekday;
  final int daysInMonth;
  final int daysInPreviousMonth;

  CalendarInfo({
    required this.startingWeekday,
    required this.daysInMonth,
    required this.daysInPreviousMonth,
  });
}

enum CellType {
  previousMonth,
  currentMonth,
  nextMonth,
}
