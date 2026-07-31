import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme_extension.dart';

class DateSelector extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const DateSelector({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<DateSelector> createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  static const int _initialPage = 1000;
  late final PageController _pageController;

  // Monday of the current real week
  late final DateTime _baseMonday;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _baseMonday = _mondayOf(now);
    _pageController = PageController(initialPage: _initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DateTime _mondayOf(DateTime date) {
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: date.weekday - 1));
  }

  List<DateTime> _weekDatesForPage(int page) {
    final offset = page - _initialPage;
    final monday = _baseMonday.add(Duration(days: offset * 7));
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  String _getWeekdayName(int weekday) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[weekday - 1];
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    return SizedBox(
      height: 80,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (page) {
          // Auto-select Monday of the new week if selected date is not in it
          final weekDates = _weekDatesForPage(page);
          final isInWeek = weekDates.any((d) => _isSameDay(d, widget.selectedDate));
          if (!isInWeek) {
            widget.onDateSelected(weekDates.first);
          }
        },
        itemBuilder: (context, page) {
          final weekDates = _weekDatesForPage(page);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
            child: Row(
              children: weekDates.asMap().entries.map((entry) {
                final index = entry.key;
                final date = entry.value;
                final isSelected = _isSameDay(date, widget.selectedDate);
                final isToday = _isSameDay(date, today);

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: index == 0 ? 0 : 5),
                    child: GestureDetector(
                      onTap: () => widget.onDateSelected(date),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : context.colors.card,
                          borderRadius: BorderRadius.circular(16),
                          border: isSelected
                              ? null
                              : Border.all(
                                  color: context.colors.border,
                                ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _getWeekdayName(date.weekday),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.8)
                                    : context.colors.textTertiary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              date.day.toString(),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : context.colors.textPrimary,
                              ),
                            ),
                            if (isToday && !isSelected) ...[
                              const SizedBox(height: 4),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                            if (isSelected) ...[
                              const SizedBox(height: 4),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
