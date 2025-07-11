import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/text_style.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../utils/date_formatter.dart';

// Model for daily calorie data
class CalorieData {
  final DateTime date;
  final double consumedCalories;
  final double targetCalories;
  final double progress;

  CalorieData({
    required this.date,
    required this.consumedCalories,
    required this.targetCalories,
    required this.progress,
  });

  double get percentage => (consumedCalories / targetCalories) * 100;
}

class CalorieCalendarWidget extends StatefulWidget {
  final Map<DateTime, CalorieData> calorieData;
  final DateTime? selectedDay;
  final Function(DateTime)? onDaySelected;

  const CalorieCalendarWidget({
    Key? key,
    required this.calorieData,
    this.selectedDay,
    this.onDaySelected,
  }) : super(key: key);

  @override
  State<CalorieCalendarWidget> createState() => _CalorieCalendarWidgetState();
}

class _CalorieCalendarWidgetState extends State<CalorieCalendarWidget> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.week; // เริ่มต้นเป็นมุมมองรายสัปดาห์
  bool _isChangingMonth = false;
  String _currentMonth = '';

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = widget.selectedDay ?? DateTime.now();
    _currentMonth = '${_focusedDay.year}-${_focusedDay.month}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildCalendar(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final now = DateTime.now();
    final isCurrentDay = isSameDay(_selectedDay, now);
    final isCurrentMonth = _focusedDay.month == now.month && _focusedDay.year == now.year;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'แคลอรี่ประจำวัน',
                style: AppTextStyle.titleLarge(context).copyWith(
                  color: AppTheme.primaryPurple,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () => _showMonthYearPicker(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormatter.getFullDate(_focusedDay),
                      style: AppTextStyle.titleSmall(context).copyWith(
                        color: AppTheme.primaryPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_drop_down,
                      color: AppTheme.primaryPurple,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildViewToggleButton(
                      text: 'เดือน',
                      isSelected: _calendarFormat == CalendarFormat.month,
                      onTap: () => setState(() {
                        _calendarFormat = CalendarFormat.month;
                      }),
                    ),
                    _buildViewToggleButton(
                      text: 'สัปดาห์',
                      isSelected: _calendarFormat == CalendarFormat.week,
                      onTap: () => setState(() {
                        _calendarFormat = CalendarFormat.week;
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDay = DateTime.now();
                    _focusedDay = DateTime.now();
                  });
                  widget.onDaySelected?.call(DateTime.now());
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isCurrentMonth && isCurrentDay
                        ? AppTheme.primaryPurple
                        : isCurrentMonth
                            ? AppTheme.primaryPurple.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'วันนี้',
                    style: AppTextStyle.labelMedium(context).copyWith(
                      color: isCurrentMonth && isCurrentDay
                          ? Colors.white
                          : isCurrentMonth
                              ? AppTheme.primaryPurple
                              : Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar<CalorieData>(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      availableGestures: AvailableGestures.horizontalSwipe,
      startingDayOfWeek: StartingDayOfWeek.monday,
      locale: 'th_TH',
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        leftChevronIcon: Icon(Icons.chevron_left, color: Color(0xFF7C3AED)),
        rightChevronIcon: Icon(Icons.chevron_right, color: Color(0xFF7C3AED)),
      ),
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        weekendTextStyle: AppTextStyle.titleSmall(context),
        defaultTextStyle: AppTextStyle.titleSmall(context),
      ),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, date, _) {
          return _buildCalendarDay(date, false, false);
        },
        todayBuilder: (context, date, _) {
          return _buildCalendarDay(date, true, false);
        },
        selectedBuilder: (context, date, _) {
          return _buildCalendarDay(date, false, true);
        },
      ),
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
        widget.onDaySelected?.call(selectedDay);
      },
      onFormatChanged: (format) {
        setState(() {
          _calendarFormat = format;
        });
      },
      onPageChanged: (focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
      },
    );
  }

  Widget _buildCalendarDay(DateTime date, bool isToday, bool isSelected) {
    final dayData = widget.calorieData[DateTime(date.year, date.month, date.day)];
    final bool hasData = dayData != null;

    Color backgroundColor = Colors.transparent;
    Color textColor = AppTheme.textPrimary;
    Color borderColor = Colors.transparent;
    double borderWidth = 0;

    if (isSelected) {
      backgroundColor = AppTheme.primaryPurple;
      textColor = Colors.white;
    } else if (isToday) {
      backgroundColor = AppTheme.primaryPurple.withOpacity(0.1);
      textColor = AppTheme.primaryPurple;
      borderColor = AppTheme.primaryPurple;
      borderWidth = 1.5;
    }

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
      ),
      child: Center(
        child: Text(
          '${date.day}',
          style: AppTextStyle.titleSmall(context).copyWith(
            color: textColor,
            fontWeight: isToday || isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildViewToggleButton({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: AppTextStyle.titleSmall(context).copyWith(
            color: isSelected ? Colors.white : AppTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  void _showMonthYearPicker() {
    // Implementation remains the same
  }
}

// Helper extension
extension CalorieCalculator on CalorieData {
  static double calculateProgress(double consumed, double target) {
    return consumed / target;
  }
}
