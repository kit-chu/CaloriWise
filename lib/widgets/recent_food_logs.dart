import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/food_log.dart';
import '../theme/app_theme.dart';
import '../theme/text_style.dart';

class RecentFoodLogs extends StatefulWidget {
  final List<FoodLog> logs;
  final double height;

  const RecentFoodLogs({
    super.key,
    required this.logs,
    this.height = 570,
  });

  @override
  State<RecentFoodLogs> createState() => _RecentFoodLogsState();
}

class _RecentFoodLogsState extends State<RecentFoodLogs> {
  static const _itemsPerPage = 3;
  PageController? _pageController;
  int _currentPage = 0;
  String _selectedTimeFilter = 'All';

  final List<({String label, String value, IconData icon})> _timeFilters = [
    (label: 'All', value: 'All', icon: Icons.access_time),
    (label: 'Morning', value: 'Morning', icon: Icons.wb_sunny),
    (label: 'Afternoon', value: 'Afternoon', icon: Icons.wb_cloudy),
    (label: 'Evening', value: 'Evening', icon: Icons.nights_stay),
    (label: 'Night', value: 'Night', icon: Icons.dark_mode),
  ];

  @override
  void initState() {
    super.initState();
    _initializePageController();
  }

  @override
  void didUpdateWidget(RecentFoodLogs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.logs != widget.logs) {
      _resetPageController();
    }
  }

  void _initializePageController() {
    _pageController?.dispose();
    _pageController = PageController(initialPage: _currentPage);
  }

  void _resetPageController() {
    setState(() {
      _currentPage = 0;
      _initializePageController();
    });
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  List<FoodLog> get _filteredLogs {
    switch (_selectedTimeFilter) {
      case 'Morning':
        return widget.logs.where((log) {
          final hour = log.timestamp.hour;
          return hour >= 5 && hour < 12;
        }).toList();
      case 'Afternoon':
        return widget.logs.where((log) {
          final hour = log.timestamp.hour;
          return hour >= 12 && hour < 17;
        }).toList();
      case 'Evening':
        return widget.logs.where((log) {
          final hour = log.timestamp.hour;
          return hour >= 17 && hour < 21;
        }).toList();
      case 'Night':
        return widget.logs.where((log) {
          final hour = log.timestamp.hour;
          return hour >= 21 || hour < 5;
        }).toList();
      case 'All':
      default:
        return widget.logs;
    }
  }

  List<List<FoodLog>> get _paginatedLogs {
    if (_filteredLogs.isEmpty) return [];

    final List<List<FoodLog>> pages = [];
    for (var i = 0; i < _filteredLogs.length; i += _itemsPerPage) {
      final end = (i + _itemsPerPage < _filteredLogs.length)
          ? i + _itemsPerPage
          : _filteredLogs.length;
      pages.add(_filteredLogs.sublist(i, end));
    }
    return pages;
  }

  void _onPageChanged(int page) {
    if (mounted) {
      setState(() => _currentPage = page);
    }
  }

  void _handleTimeFilterChange(String value) {
    if (_selectedTimeFilter == value) return;

    setState(() {
      _selectedTimeFilter = value;
      _currentPage = 0;
    });

    _resetPageController();
  }

  @override
  Widget build(BuildContext context) {
    final paginatedLogs = _paginatedLogs;
    final hasLogs = paginatedLogs.isNotEmpty;
    final controller = _pageController;

    if (controller == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: widget.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recently Logged',
                  style: AppTextStyle.titleMedium(context).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 70, // เพิ่มความสูงจาก 40 เป็น 60
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _timeFilters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final filter = _timeFilters[index];
                      final isSelected = _selectedTimeFilter == filter.value;
                      return _TimeFilterButton(
                        label: filter.label,
                        icon: filter.icon,
                        isSelected: isSelected,
                        onTap: () => _handleTimeFilterChange(filter.value),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: !hasLogs
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.no_food,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No food logs for ${_selectedTimeFilter.toLowerCase()}',
                          style: AppTextStyle.titleSmall(context).copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: PageView.builder(
                          key: ValueKey(_selectedTimeFilter),
                          controller: controller,
                          onPageChanged: _onPageChanged,
                          itemCount: paginatedLogs.length,
                          itemBuilder: (context, pageIndex) {
                            final pageItems = paginatedLogs[pageIndex];
                            return ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: pageItems.length,
                              itemBuilder: (context, index) {
                                final log = pageItems[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _FoodLogCard(log: log),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      if (paginatedLogs.length > 1)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(paginatedLogs.length, (index) {
                              return Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _currentPage == index
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey[300],
                                ),
                              );
                            }),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _TimeFilterButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TimeFilterButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  String get _timeRange {
    switch (label) {
      case 'Morning':
        return '5:00 - 11:59 AM';
      case 'Afternoon':
        return '12:00 - 4:59 PM';
      case 'Evening':
        return '5:00 - 8:59 PM';
      case 'Night':
        return '9:00 PM - 4:59 AM';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showTimeRange = label != 'All';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryPurple
                : AppTheme.primaryPurple.withAlpha(25),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : AppTheme.primaryPurple.withAlpha(51),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: isSelected ? Colors.white : AppTheme.primaryPurple,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: AppTextStyle.labelMedium(context).copyWith(
                      color: isSelected ? Colors.white : AppTheme.primaryPurple,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              if (showTimeRange) ...[
                const SizedBox(height: 2),
                Text(
                  _timeRange,
                  style: AppTextStyle.labelSmall(context).copyWith(
                    color: isSelected
                        ? Colors.white.withAlpha(200)
                        : AppTheme.primaryPurple.withAlpha(180),
                    fontSize: 9,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FoodLogCard extends StatelessWidget {
  final FoodLog log;

  const _FoodLogCard({
    required this.log,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          log.name,
                          style: AppTextStyle.titleMedium(context).copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '${log.calories} Kcal',
                              style: AppTextStyle.titleSmall(context).copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat('h:mm a').format(log.timestamp),
                              style: AppTextStyle.labelMedium(context).copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: log.imageUrl.isNotEmpty
                        ? Image.network(
                            log.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[100],
                                child: Icon(
                                  Icons.fastfood,
                                  color: Colors.grey[400],
                                  size: 24,
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey[100],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey[100],
                            child: Icon(
                              Icons.fastfood,
                              color: Colors.grey[400],
                              size: 24,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _MacroIndicator(
                  value: log.protein,
                  unit: 'g',
                  label: 'Protein',
                  color: const Color(0xFF4C9EEB),
                ),
                _MacroIndicator(
                  value: log.carbs,
                  unit: 'g',
                  label: 'Carbs',
                  color: const Color(0xFF2ECC71),
                ),
                _MacroIndicator(
                  value: log.fat,
                  unit: 'g',
                  label: 'Fat',
                  color: const Color(0xFFF1C40F),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroIndicator extends StatelessWidget {
  final double value;
  final String unit;
  final String label;
  final Color color;

  const _MacroIndicator({
    required this.value,
    required this.unit,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value.toStringAsFixed(1),
                style: AppTextStyle.titleSmall(context).copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextSpan(
                text: unit,
                style: AppTextStyle.labelMedium(context).copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyle.labelSmall(context).copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
