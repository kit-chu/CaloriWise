import '../models/macro_data.dart';
import '../models/food_log.dart';
import '../widgets/calorie_calendar_widget.dart';

class DataCacheService {
  static final DataCacheService _instance = DataCacheService._internal();
  factory DataCacheService() => _instance;
  DataCacheService._internal();

  // Cache for calorie data by date
  final Map<String, CalorieData> _calorieCache = {};

  // Cache for macro data by date
  final Map<String, MacroData> _macroCache = {};

  // Cache for food logs by date
  final Map<String, List<FoodLog>> _foodLogsCache = {};

  // Cache for popular foods (rarely changes)
  List<Map<String, dynamic>>? _popularFoodsCache;

  // Cache for user favorites
  List<Map<String, dynamic>>? _favoriteFoodsCache;

  // Last data update timestamp
  DateTime? _lastDataUpdate;

  // Cache expiry duration (5 minutes)
  static const Duration _cacheExpiry = Duration(minutes: 5);

  // Generate cache key from date
  String _generateDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Check if cache is expired
  bool _isCacheExpired() {
    if (_lastDataUpdate == null) return true;
    return DateTime.now().difference(_lastDataUpdate!) > _cacheExpiry;
  }

  // ===== CALORIE DATA CACHING =====

  CalorieData? getCachedCalorieData(DateTime date) {
    final key = _generateDateKey(date);
    return _calorieCache[key];
  }

  void setCachedCalorieData(DateTime date, CalorieData data) {
    final key = _generateDateKey(date);
    _calorieCache[key] = data;
    _lastDataUpdate = DateTime.now();
  }

  Map<DateTime, CalorieData> getCachedCalorieDataRange(DateTime startDate, DateTime endDate) {
    final Map<DateTime, CalorieData> result = {};

    DateTime current = startDate;
    while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
      final cached = getCachedCalorieData(current);
      if (cached != null) {
        result[current] = cached;
      }
      current = current.add(const Duration(days: 1));
    }

    return result;
  }

  void setCachedCalorieDataRange(Map<DateTime, CalorieData> data) {
    data.forEach((date, calorieData) {
      setCachedCalorieData(date, calorieData);
    });
  }

  // ===== MACRO DATA CACHING =====

  MacroData? getCachedMacroData(DateTime date) {
    final key = _generateDateKey(date);
    return _macroCache[key];
  }

  void setCachedMacroData(DateTime date, MacroData data) {
    final key = _generateDateKey(date);
    _macroCache[key] = data;
    _lastDataUpdate = DateTime.now();
  }

  // ===== FOOD LOGS CACHING =====

  List<FoodLog>? getCachedFoodLogs(DateTime date) {
    final key = _generateDateKey(date);
    return _foodLogsCache[key];
  }

  void setCachedFoodLogs(DateTime date, List<FoodLog> logs) {
    final key = _generateDateKey(date);
    _foodLogsCache[key] = List.from(logs); // Create a copy to avoid reference issues
    _lastDataUpdate = DateTime.now();
  }

  void addFoodLogToCache(DateTime date, FoodLog newLog) {
    final key = _generateDateKey(date);
    final currentLogs = _foodLogsCache[key] ?? [];
    currentLogs.insert(0, newLog); // Add to beginning for recent-first order
    _foodLogsCache[key] = currentLogs;
    _lastDataUpdate = DateTime.now();
  }

  // ===== POPULAR FOODS CACHING =====

  List<Map<String, dynamic>>? getCachedPopularFoods() {
    return _popularFoodsCache;
  }

  void setCachedPopularFoods(List<Map<String, dynamic>> foods) {
    _popularFoodsCache = List.from(foods);
  }

  // ===== FAVORITE FOODS CACHING =====

  List<Map<String, dynamic>>? getCachedFavoriteFoods() {
    return _favoriteFoodsCache;
  }

  void setCachedFavoriteFoods(List<Map<String, dynamic>> favorites) {
    _favoriteFoodsCache = List.from(favorites);
  }

  void addFavoriteFood(Map<String, dynamic> food) {
    _favoriteFoodsCache ??= [];
    _favoriteFoodsCache!.add(Map.from(food));
  }

  void removeFavoriteFood(String foodName) {
    _favoriteFoodsCache?.removeWhere((food) => food['name'] == foodName);
  }

  // ===== CACHE MANAGEMENT =====

  void invalidateCache({DateTime? specificDate}) {
    if (specificDate != null) {
      final key = _generateDateKey(specificDate);
      _calorieCache.remove(key);
      _macroCache.remove(key);
      _foodLogsCache.remove(key);
    } else {
      _calorieCache.clear();
      _macroCache.clear();
      _foodLogsCache.clear();
      _popularFoodsCache = null;
      _favoriteFoodsCache = null;
    }
    _lastDataUpdate = null;
  }

  void clearExpiredCache() {
    if (_isCacheExpired()) {
      invalidateCache();
    }
  }

  // ===== UTILITY METHODS =====

  bool hasDataForDate(DateTime date) {
    final key = _generateDateKey(date);
    return _calorieCache.containsKey(key) &&
           _macroCache.containsKey(key) &&
           _foodLogsCache.containsKey(key);
  }

  Map<String, dynamic> getCacheStats() {
    return {
      'calorieDataCount': _calorieCache.length,
      'macroDataCount': _macroCache.length,
      'foodLogsCount': _foodLogsCache.length,
      'popularFoodsCount': _popularFoodsCache?.length ?? 0,
      'favoriteFoodsCount': _favoriteFoodsCache?.length ?? 0,
      'lastUpdate': _lastDataUpdate?.toIso8601String(),
      'isExpired': _isCacheExpired(),
    };
  }
}

// Helper class for calorie calculations
class CalorieCalculator {
  static CalorieStatus calculateStatus(double consumed, double target) {
    final percentage = consumed / target;

    if (percentage < 0.8) return CalorieStatus.under;
    if (percentage <= 1.1) return CalorieStatus.perfect;
    if (percentage <= 1.3) return CalorieStatus.over;
    return CalorieStatus.wayOver;
  }

  static double calculateProgress(double consumed, double target) {
    return (consumed / target).clamp(0.0, 1.5);
  }
}
