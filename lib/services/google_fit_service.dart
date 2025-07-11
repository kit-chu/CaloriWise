import 'dart:async';
import 'dart:io';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoogleFitService {
  static final GoogleFitService _instance = GoogleFitService._internal();

  factory GoogleFitService() => _instance;

  GoogleFitService._internal();

  final Health _health = Health();
  bool _isConnected = false;

  static const List<HealthDataType> _dataTypes = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.DISTANCE_DELTA,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.WEIGHT,
  ];

  static const List<HealthDataAccess> _permissions = [
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
  ];

  Future<bool> initialize() async {
    try {
      await _requestPermissions();

      // Configure Health - new version returns void
      await _health.configure();

      // Request authorization with latest API
      _isConnected = await _health.requestAuthorization(_dataTypes, permissions: _permissions);

      // Save connection status
      if (_isConnected) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('google_fit_connected', true);
      }

      return _isConnected;
    } catch (e) {
      print('Error initializing Google Fit: $e');
      return false;
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      await Permission.activityRecognition.request();
      await Permission.sensors.request();
    }
  }

  /// Get today's health data
  Future<Map<String, dynamic>> getTodayHealthData() async {
    if (!_isConnected) return _getDefaultHealthData();

    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      return await fetchHealthData(startOfDay, endOfDay);
    } catch (e) {
      print('Error fetching today\'s health data: $e');
      return _getDefaultHealthData();
    }
  }

  /// Get health data for a specific date range
  Future<Map<String, dynamic>> fetchHealthData(DateTime start, DateTime end) async {
    if (!_isConnected) return _getDefaultHealthData();

    try {
      final data = await _health.getHealthDataFromTypes(
        types: _dataTypes,
        startTime: start,
        endTime: end,
      );

      return _processHealthData(data);
    } catch (e) {
      print('Error fetching health data: $e');
      return _getDefaultHealthData();
    }
  }

  /// Get health data for the past week
  Future<Map<String, dynamic>> getWeeklyHealthData() async {
    if (!_isConnected) return _getDefaultHealthData();

    try {
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));

      return await fetchHealthData(weekAgo, now);
    } catch (e) {
      print('Error fetching weekly health data: $e');
      return _getDefaultHealthData();
    }
  }

  /// Get health data for the past month
  Future<Map<String, dynamic>> getMonthlyHealthData() async {
    if (!_isConnected) return _getDefaultHealthData();

    try {
      final now = DateTime.now();
      final monthAgo = DateTime(now.year, now.month - 1, now.day);

      return await fetchHealthData(monthAgo, now);
    } catch (e) {
      print('Error fetching monthly health data: $e');
      return _getDefaultHealthData();
    }
  }

  /// Process raw health data points into a structured format
  Map<String, dynamic> _processHealthData(List<HealthDataPoint> data) {
    final result = {
      'steps': 0,
      'heartRate': 0,
      'distance': 0.0,
      'calories': 0.0,
      'weight': 0.0,
    };

    if (data.isEmpty) return result;

    // Group data by type for better processing
    final groupedData = <HealthDataType, List<HealthDataPoint>>{};
    for (var point in data) {
      groupedData.putIfAbsent(point.type, () => []).add(point);
    }

    // Process each data type
    for (var entry in groupedData.entries) {
      switch (entry.key) {
        case HealthDataType.STEPS:
        // Sum all steps for the period
          result['steps'] = entry.value
              .map((point) => _extractNumericValue(point.value))
              .fold(0.0, (sum, steps) => sum + steps)
              .toInt();
          break;

        case HealthDataType.HEART_RATE:
        // Get the most recent heart rate
          if (entry.value.isNotEmpty) {
            entry.value.sort((a, b) => b.dateFrom.compareTo(a.dateFrom));
            result['heartRate'] = _extractNumericValue(entry.value.first.value).toInt();
          }
          break;

        case HealthDataType.DISTANCE_DELTA:
        // Sum all distances (convert to km)
          final totalMeters = entry.value
              .map((point) => _extractNumericValue(point.value))
              .fold(0.0, (sum, distance) => sum + distance);
          result['distance'] = totalMeters / 1000; // Convert to km
          break;

        case HealthDataType.ACTIVE_ENERGY_BURNED:
        // Sum all calories burned
          result['calories'] = entry.value
              .map((point) => _extractNumericValue(point.value))
              .fold(0.0, (sum, calories) => sum + calories);
          break;

        case HealthDataType.WEIGHT:
        // Get the most recent weight
          if (entry.value.isNotEmpty) {
            entry.value.sort((a, b) => b.dateFrom.compareTo(a.dateFrom));
            result['weight'] = _extractNumericValue(entry.value.first.value);
          }
          break;

        default:
          break;
      }
    }

    return result;
  }

  /// Extract numeric value from HealthValue (works with both old and new versions)
  double _extractNumericValue(HealthValue? healthValue) {
    if (healthValue == null) return 0.0;

    try {
      // For new version with NumericHealthValue
      if (healthValue is NumericHealthValue) {
        return healthValue.numericValue.toDouble();
      }

      // Try casting dynamically and converting
      final dynamicValue = healthValue as dynamic;

      if (dynamicValue is num) {
        return dynamicValue.toDouble();
      }

      if (dynamicValue is String) {
        return double.tryParse(dynamicValue) ?? 0.0;
      }

      return double.tryParse(dynamicValue.toString()) ?? 0.0;
    } catch (e) {
      print('Error extracting numeric value from HealthValue: $e');
      return 0.0;
    }
  }

  /// Get default/mock health data when service is not connected
  Map<String, dynamic> _getDefaultHealthData() {
    return {
      'steps': 0,
      'heartRate': 0,
      'distance': 0.0,
      'calories': 0.0,
      'weight': 0.0,
    };
  }

  /// Write health data (for future use)
  Future<bool> writeHealthData({
    int? steps,
    int? heartRate,
    double? distance,
    double? calories,
    double? weight,
  }) async {
    if (!_isConnected) return false;

    try {
      final now = DateTime.now();
      bool success = true;

      // Write steps data
      if (steps != null) {
        final result = await _health.writeHealthData(
          value: steps.toDouble(),
          type: HealthDataType.STEPS,
          startTime: now.subtract(const Duration(hours: 1)),
          endTime: now,
        );
        success = success && result;
      }

      // Write heart rate data
      if (heartRate != null) {
        final result = await _health.writeHealthData(
          value: heartRate.toDouble(),
          type: HealthDataType.HEART_RATE,
          startTime: now,
          endTime: now,
        );
        success = success && result;
      }

      // Write distance data
      if (distance != null) {
        final result = await _health.writeHealthData(
          value: distance * 1000, // Convert km to meters
          type: HealthDataType.DISTANCE_DELTA,
          startTime: now.subtract(const Duration(hours: 1)),
          endTime: now,
        );
        success = success && result;
      }

      // Write calories data
      if (calories != null) {
        final result = await _health.writeHealthData(
          value: calories,
          type: HealthDataType.ACTIVE_ENERGY_BURNED,
          startTime: now.subtract(const Duration(hours: 1)),
          endTime: now,
        );
        success = success && result;
      }

      // Write weight data
      if (weight != null) {
        final result = await _health.writeHealthData(
          value: weight,
          type: HealthDataType.WEIGHT,
          startTime: now,
          endTime: now,
        );
        success = success && result;
      }

      return success;
    } catch (e) {
      print('Error writing health data: $e');
      return false;
    }
  }

  /// Check if specific health data permissions are granted
  Future<bool> hasPermissions() async {
    try {
      return await _health.hasPermissions(_dataTypes, permissions: _permissions) ?? false;
    } catch (e) {
      print('Error checking permissions: $e');
      return false;
    }
  }

  /// Request specific permissions if not already granted
  Future<bool> requestPermissions() async {
    try {
      return await _health.requestAuthorization(_dataTypes, permissions: _permissions);
    } catch (e) {
      print('Error requesting permissions: $e');
      return false;
    }
  }

  /// Get available health data types on this device
  Future<List<HealthDataType>> getAvailableDataTypes() async {
    try {
      final availableTypes = <HealthDataType>[];

      for (var type in _dataTypes) {
        final hasPermission = await _health.hasPermissions([type]);
        if (hasPermission == true) {
          availableTypes.add(type);
        }
      }

      return availableTypes;
    } catch (e) {
      print('Error getting available data types: $e');
      return [];
    }
  }

  /// Disconnect from health services
  Future<void> disconnect() async {
    _isConnected = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('google_fit_connected', false);
  }

  /// Reconnect to health services
  Future<bool> reconnect() async {
    return await initialize();
  }

  /// Check if the service is currently connected
  bool get isConnected => _isConnected;

  /// Get stored connection status from SharedPreferences
  Future<bool> getConnectionStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('google_fit_connected') ?? false;
    } catch (e) {
      print('Error getting connection status: $e');
      return false;
    }
  }

  /// Get health platform information (simplified without deprecated API)
  Future<String> getPlatformInfo() async {
    try {
      await _health.configure();
      if (Platform.isAndroid) {
        return 'Android Health Services';
      } else if (Platform.isIOS) {
        return 'iOS HealthKit';
      } else {
        return 'Unknown Platform';
      }
    } catch (e) {
      print('Error getting platform info: $e');
      return 'Platform Detection Failed';
    }
  }

  /// Check if Health Connect is available (Android)
  Future<bool> isHealthConnectAvailable() async {
    try {
      if (Platform.isAndroid) {
        // Configure returns void, so just call it and assume success if no exception
        await _health.configure();
        return true;
      }
      return false;
    } catch (e) {
      print('Error checking Health Connect availability: $e');
      return false;
    }
  }

  /// Check if health data is available
  Future<bool> isHealthDataAvailable() async {
    try {
      await _health.configure();
      return await _health.hasPermissions(_dataTypes, permissions: _permissions) ?? false;
    } catch (e) {
      print('Error checking health data availability: $e');
      return false;
    }
  }


}