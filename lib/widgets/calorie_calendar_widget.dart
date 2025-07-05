import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/text_style.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../utils/date_formatter.dart';

// Enum for calorie status
enum CalorieStatus {
  under,    // < 85%
  perfect,  // 85-110%
  over,     // 110-130%
  wayOver,  // > 130%
  noData,   // No data
}

// Model for daily calorie data
class CalorieData {
  final DateTime date;
  final double consumedCalories;
  final double targetCalories;
  final CalorieStatus status;
  final double progress; // 0.0 - 1.0+

  CalorieData({
    required this.date,
    required this.consumedCalories,
    required this.targetCalories,
    required this.status,
    required this.progress,
  });

  // Calculate percentage
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

class _CalorieCalendarWidgetState extends State<CalorieCalendarWidget> with SingleTickerProviderStateMixin {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  bool _isChangingMonth = false;
  String _currentMonth = '';

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = widget.selectedDay ?? DateTime.now();
    _currentMonth = '${_focusedDay.year}-${_focusedDay.month}';
  }

  void _resetAnimation() {
    if (_currentMonth != '${_focusedDay.year}-${_focusedDay.month}') {
      setState(() {
        _isChangingMonth = true;
      });

      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) {
          setState(() {
            _isChangingMonth = false;
            _currentMonth = '${_focusedDay.year}-${_focusedDay.month}';
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25), // 0.1 * 255 ≈ 25
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildCalendar(),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final now = DateTime.now();
    final isCurrentDay = isSameDay(_selectedDay, now);
    // เช็คว่าเดือนและปีปัจจุบันตรงกับที่เลือกไหม
    final isCurrentMonth = _focusedDay.month == now.month && _focusedDay.year == now.year;
    final currentMonth = DateTime(_focusedDay.year, _focusedDay.month);

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
              // ปุ่มเลือกเดือน
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
              // ปุ่มสลับมุมมอง
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
                        _resetAnimation();
                      }),
                    ),
                    _buildViewToggleButton(
                      text: 'สัปดาห์',
                      isSelected: _calendarFormat == CalendarFormat.week,
                      onTap: () => setState(() {
                        _calendarFormat = CalendarFormat.week;
                        _resetAnimation();
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // ปุ่มวันนี้
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDay = DateTime.now();
                    _focusedDay = DateTime.now();
                  });
                  if (widget.onDaySelected != null) {
                    widget.onDaySelected!(DateTime.now());
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    // เปลี่ยนสีตามเงื่อนไขเดือนและปีปัจจุบัน
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

  void _showMonthYearPicker() {
    final currentYear = _focusedDay.year;
    final currentMonth = _focusedDay.month;
    final monthNames = DateFormatter.getMonthNames();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: StatefulBuilder(
          builder: (context, setState) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left, color: AppTheme.primaryPurple),
                onPressed: () {
                  setState(() => _focusedDay = DateTime(_focusedDay.year - 1, _focusedDay.month));
                },
              ),
              Text(
                '${_focusedDay.year + 543}',
                style: AppTextStyle.titleMedium(context).copyWith(
                  color: AppTheme.primaryPurple,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, color: AppTheme.primaryPurple),
                onPressed: () {
                  setState(() => _focusedDay = DateTime(_focusedDay.year + 1, _focusedDay.month));
                },
              ),
            ],
          ),
        ),
        content: Container(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 12,
            itemBuilder: (context, index) {
              final monthDate = DateTime(_focusedDay.year, index + 1);
              final isSelected = monthDate.year == currentYear &&
                               index + 1 == currentMonth;

              return InkWell(
                onTap: () {
                  setState(() {
                    _focusedDay = DateTime(_focusedDay.year, index + 1, 1);
                  });
                  _resetAnimation();
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryPurple : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    monthNames[index],
                    style: AppTextStyle.titleSmall(context).copyWith(
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'ปิด',
              style: AppTextStyle.titleSmall(context).copyWith(
                color: AppTheme.primaryPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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
      ));
  }

  Widget _buildCalendar() {
    return TableCalendar<CalorieData>(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      availableGestures: AvailableGestures.horizontalSwipe, // อนุญาตให้ปัดซ้าย-ขวาเท่านั้น
      eventLoader: (day) {
        final data = widget.calorieData[DateTime(day.year, day.month, day.day)];
        return data != null ? [data] : [];
      },
      startingDayOfWeek: StartingDayOfWeek.monday,
      locale: 'th_TH', // Thai locale
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        leftChevronIcon: Icon(Icons.chevron_left, color: Color(0xFF7C3AED)),
        rightChevronIcon: Icon(Icons.chevron_right, color: Color(0xFF7C3AED)),
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1F1F1F),
        ),
      ),
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekdayStyle: TextStyle(
          color: Color(0xFF6B7280),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        weekendStyle: TextStyle(
          color: Color(0xFF6B7280),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        weekendTextStyle: AppTextStyle.titleSmall(context).copyWith(
          color: AppTheme.textSecondary,
        ),
        holidayTextStyle: TextStyle(color: Color(0xFF1F1F1F)),
        defaultTextStyle: AppTextStyle.titleSmall(context),
        selectedTextStyle: AppTextStyle.titleSmall(context).copyWith(
          color: AppTheme.primaryPurple,
        ),
        todayTextStyle: AppTextStyle.titleSmall(context).copyWith(
          color: AppTheme.primaryPurple,
        ),
        outsideTextStyle: AppTextStyle.titleSmall(context).copyWith(
          color: AppTheme.textSecondary.withAlpha(128), // 0.5 * 255 ≈ 128
        ),
        selectedDecoration: BoxDecoration(
          color: Color(0xFF7C3AED),
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: Color(0xFF1F1F1F),
          shape: BoxShape.circle,
        ),
        markerDecoration: BoxDecoration(
          color: Colors.transparent,
        ),
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
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
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
        _resetAnimation();
        setState(() {
          _focusedDay = focusedDay;
        });
      },
    );
  }

  Widget _buildCalendarDay(DateTime date, bool isToday, bool isSelected) {
    final dayData = widget.calorieData[DateTime(date.year, date.month, date.day)];
    final bool hasData = dayData != null;
    final bool shouldShowPercent = !_isChangingMonth &&
        '${date.year}-${date.month}' == _currentMonth;

    // กำหนดสีและสไตล์ตามสถานะ
    Color backgroundColor = Colors.transparent;
    Color textColor = AppTheme.textPrimary;
    Color borderColor = Colors.transparent;
    double borderWidth = 0;
    double containerScale = 1.0; // เพิ่มตัวแปรสำหรับควบคุมขนาด

    if (isSelected) {
      backgroundColor = AppTheme.primaryPurple;
      textColor = Colors.white;
      containerScale = 0.85; // ทำให้วงกลมเล็กลงเมื่อถูกเลือก
    } else if (isToday) {
      backgroundColor = AppTheme.primaryPurple.withOpacity(0.1);
      textColor = AppTheme.primaryPurple;
      borderColor = AppTheme.primaryPurple;
      borderWidth = 1.5;
    } else if (hasData && shouldShowPercent) {
      final statusColor = _getProgressColor(dayData.status);
      backgroundColor = statusColor.withOpacity(0.08);
      textColor = statusColor;
    }

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        margin: const EdgeInsets.all(2),
        child: CircularPercentIndicator(
          key: ValueKey('${_currentMonth}_${date.day}'),
          radius: 18.0,
          lineWidth: 2.0,
          animation: true,
          animationDuration: 600,
          curve: Curves.easeInOut,
          percent: shouldShowPercent ? (hasData ? dayData.progress.clamp(0.0, 1.0) : 0) : 0,
          center: Transform.scale(
            scale: containerScale,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: borderColor,
                  width: borderWidth,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: AppTheme.primaryPurple.withOpacity(0.2),
                    blurRadius: 4,
                    spreadRadius: 1,
                  )
                ] : null,
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
            ),
          ),
          progressColor: hasData ? _getProgressColor(dayData.status).withOpacity(0.6) : Colors.transparent,
          backgroundColor: hasData
              ? _getProgressColor(dayData.status).withOpacity(0.08)
              : Colors.grey.withOpacity(0.05),
          circularStrokeCap: CircularStrokeCap.round,
        ),
      ),
    );
  }

  Color _getProgressColor(CalorieStatus status) {
    switch (status) {
      case CalorieStatus.under:
        return Color(0xFFEF4444); // Red
      case CalorieStatus.perfect:
        return Color(0xFF10B981); // Green
      case CalorieStatus.over:
        return Color(0xFFF59E0B); // Orange
      case CalorieStatus.wayOver:
        return Color(0xFFDC2626); // Dark Red
      case CalorieStatus.noData:
        return Colors.grey[400]!;
    }
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'สถานะแคลอรี่',
            style: AppTextStyle.titleMedium(context).copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildLegendItem(Color(0xFFEF4444), 'ต่ำกว่าเป้า (<85%)'),
              _buildLegendItem(Color(0xFF10B981), 'พอดี (85-110%)'),
              _buildLegendItem(Color(0xFFF59E0B), 'เกินเล็กน้อย (110-130%)'),
              _buildLegendItem(Color(0xFFDC2626), 'เกินมาก (>130%)'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyle.titleSmall(context).copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedDayInfo() {
    final dayKey = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
    final data = widget.calorieData[dayKey];

    if (data == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.backgroundLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              Icons.info_outline,
              color: AppTheme.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              'ไม่มีข้อมูลแคลอรี่',
              style: AppTextStyle.titleSmall(context).copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'วันที่ ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
              style: AppTextStyle.titleSmall(context).copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    final percentage = data.percentage;
    final statusColor = _getProgressColor(data.status);
    String statusText;

    if (percentage < 85) {
      statusText = 'ต่ำกว่าเป้าหมาย';
    } else if (percentage <= 110) {
      statusText = 'อยู่ในเกณฑ์ที่ดี';
    } else if (percentage <= 130) {
      statusText = 'เกินเล็กน้อย';
    } else {
      statusText = 'เกินมาก';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13), // 0.05 * 255 ≈ 13
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'วันที่ ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
                style: AppTextStyle.titleMedium(context).copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(25), // 0.1 * 255 ≈ 25
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  statusText,
                  style: AppTextStyle.titleSmall(context).copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.local_fire_department,
            label: 'แคลอรี่ที่บริโภค',
            value: '${data.consumedCalories.toInt()} kcal',
            color: AppTheme.primaryCoral,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.flag,
            label: 'เป้าหมายแคลอรี่',
            value: '${data.targetCalories.toInt()} kcal',
            color: AppTheme.primaryPurple,
          ),
          const SizedBox(height: 12),
          Container(
            height: 4,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: AppTheme.backgroundLight,
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: data.progress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${percentage.toStringAsFixed(1)}% ของเป้าหมาย',
            style: AppTextStyle.titleSmall(context).copyWith(
              color: statusColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha(25), // 0.1 * 255 ≈ 25
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyle.titleSmall(context).copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                value,
                style: AppTextStyle.titleMedium(context).copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDayInfo(CalorieData data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          'ข้อมูลแคลอรี่',
          style: AppTextStyle.titleLarge(context).copyWith(
            color: AppTheme.primaryPurple,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'วันที่: ${data.date.day}/${data.date.month}/${data.date.year}',
              style: AppTextStyle.titleSmall(context).copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'บริโภค: ${data.consumedCalories.toInt()} kcal',
              style: AppTextStyle.titleSmall(context).copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            Text(
              'เป้าหมาย: ${data.targetCalories.toInt()} kcal',
              style: AppTextStyle.titleSmall(context).copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'เปอร์เซ็นต์: ${data.percentage.toStringAsFixed(1)}%',
              style: AppTextStyle.titleMedium(context).copyWith(
                fontWeight: FontWeight.w600,
                color: _getProgressColor(data.status),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryPurple,
            ),
            child: Text(
              'ปิด',
              style: AppTextStyle.titleSmall(context).copyWith(
                color: AppTheme.primaryPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Extension to calculate calorie status
extension CalorieCalculator on CalorieData {
  static CalorieStatus calculateStatus(double consumed, double target) {
    final percentage = (consumed / target) * 100;

    if (percentage < 85) {
      return CalorieStatus.under;
    } else if (percentage <= 110) {
      return CalorieStatus.perfect;
    } else if (percentage <= 130) {
      return CalorieStatus.over;
    } else {
      return CalorieStatus.wayOver;
    }
  }

  static double calculateProgress(double consumed, double target) {
    return consumed / target;
  }
}

class CalorieCalendarExample extends StatefulWidget {
  const CalorieCalendarExample({super.key});

  @override
  State<CalorieCalendarExample> createState() => _CalorieCalendarExampleState();
}

class _CalorieCalendarExampleState extends State<CalorieCalendarExample> {
  late Map<DateTime, CalorieData> _calorieData;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _generateSampleData();
  }

  void _generateSampleData() {
    _calorieData = {};
    final today = DateTime.now();

    // Generate sample data for the current month
    for (int i = 1; i <= 14; i++) {
      final date = DateTime(today.year, today.month, i);
      final consumed = (1200.0 + (i * 100.0) + (i % 3 * 200.0));
      const target = 2000.0;
      final status = CalorieCalculator.calculateStatus(consumed, target);
      final progress = CalorieCalculator.calculateProgress(consumed, target);

      _calorieData[date] = CalorieData(
        date: date,
        consumedCalories: consumed,
        targetCalories: target,
        status: status,
        progress: progress,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Calorie Calendar',
          style: AppTextStyle.titleLarge(context).copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CalorieCalendarWidget(
              calorieData: _calorieData,
              selectedDay: _selectedDay,
              onDaySelected: (selectedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                });

                final dayKey = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
                final data = _calorieData[dayKey];
                if (data != null) {
                  _showDayInfoDialog(data);
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showDayInfoDialog(CalorieData data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          'ข้อมูลแคลอรี่',
          style: AppTextStyle.titleLarge(context).copyWith(
            color: AppTheme.primaryPurple,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'วันที่: ${data.date.day}/${data.date.month}/${data.date.year}',
              style: AppTextStyle.titleSmall(context).copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'บริโภค: ${data.consumedCalories.toInt()} kcal',
              style: AppTextStyle.titleSmall(context).copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            Text(
              'เป้าหมาย: ${data.targetCalories.toInt()} kcal',
              style: AppTextStyle.titleSmall(context).copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'เปอร์เซ็นต์: ${data.percentage.toStringAsFixed(1)}%',
              style: AppTextStyle.titleMedium(context).copyWith(
                fontWeight: FontWeight.w600,
                color: _getProgressColor(data.status),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryPurple,
            ),
            child: Text(
              'ปิด',
              style: AppTextStyle.titleSmall(context).copyWith(
                color: AppTheme.primaryPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(CalorieStatus status) {
    switch (status) {
      case CalorieStatus.under:
        return const Color(0xFFEF4444); // Red
      case CalorieStatus.perfect:
        return const Color(0xFF10B981); // Green
      case CalorieStatus.over:
        return const Color(0xFFF59E0B); // Orange
      case CalorieStatus.wayOver:
        return const Color(0xFFDC2626); // Dark Red
      case CalorieStatus.noData:
        return Colors.grey[400]!;
    }
  }
}
