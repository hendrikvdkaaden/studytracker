class FormatHelpers {
  /// Format minutes into a human-readable time string (e.g., "1h 30m", "45m", "2h")
  static String formatTime(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;

    if (hours > 0 && mins > 0) {
      return '${hours}h ${mins}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${mins}m';
    }
  }

  static const _shortMonths = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  /// Format a DateTime into a short date string (e.g., "9 Feb 2026")
  static String formatDate(DateTime date) {
    return '${date.day} ${_shortMonths[date.month - 1]} ${date.year}';
  }

  /// Format a DateTime into a short date without year (e.g., "9 Feb")
  static String formatDateShort(DateTime date) {
    return '${date.day} ${_shortMonths[date.month - 1]}';
  }

  static const _fullMonths = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  /// Format a DateTime into a full date string (e.g., "9 February 2026")
  static String formatDateFull(DateTime date) {
    return '${date.day} ${_fullMonths[date.month - 1]} ${date.year}';
  }

  /// Format a TimeOfDay into a 24-hour time string (e.g., "14:30")
  static String formatTimeOfDay(int hour, int minute) {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}
