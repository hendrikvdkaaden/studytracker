enum DayStatus {
  completed,
  missed,

  /// A missed day a streak freeze was spent on. Shown apart from [missed] so
  /// the week does not contradict a streak that visibly carried on.
  frozen,
  notPlanned,
  pastNoSession,
}
