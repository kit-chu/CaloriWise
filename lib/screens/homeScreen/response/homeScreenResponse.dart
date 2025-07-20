




class HomeScreenResponse {
  int? statusCode;
  String? message;
  Data? data;
  String? errorData;
  int? timestamp;

  HomeScreenResponse({this.statusCode, this.message, this.data, this.errorData, this.timestamp});

  HomeScreenResponse.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    message = json['message'];

    // ตรวจสอบว่า data เป็น Map หรือ String
    if (json['data'] != null) {
      if (json['data'] is Map<String, dynamic>) {
        data = Data.fromJson(json['data']);
      } else if (json['data'] is String) {
        errorData = json['data'];
      }
    }

    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['statusCode'] = this.statusCode;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    } else if (this.errorData != null) {
      data['data'] = this.errorData;
    }
    data['timestamp'] = this.timestamp;
    return data;
  }
}

class Data {
  double? version;
  String? screen;
  List<Items>? items;

  Data({this.version, this.screen, this.items});

  Data.fromJson(Map<String, dynamic> json) {
    version = json['version'];
    screen = json['screen'];
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(new Items.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['version'] = this.version;
    data['screen'] = this.screen;
    if (this.items != null) {
      data['items'] = this.items!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Items {
  String? table;
  String? th;
  String? en;

  Items({this.table, this.th, this.en});

  Items.fromJson(Map<String, dynamic> json) {
    table = json['table'];
    th = json['th'];
    en = json['en'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['table'] = this.table;
    data['th'] = this.th;
    data['en'] = this.en;
    return data;
  }
}


// text_keys.dart
class TextKeys {
  // Navigation & Tabs
  static const String overview = 'overview';
  static const String nutrition = 'nutrition';
  static const String foodLog = 'food_log';

  // Common Actions
  static const String addFood = 'add_food';
  static const String seeAll = 'see_all';
  static const String connectDevice = 'connect_device';

  // User Interface
  static const String welcome = 'welcome';
  static const String today = 'today';
  static const String userName = 'user_name';
  static const String from = 'from';
  static const String remaining = 'remaining';
  static const String burned = 'burned';
  static const String items = 'items';
  static const String ago = 'ago';

  // Nutrition & Food
  static const String protein = 'protein';
  static const String carbs = 'carbs';
  static const String fat = 'fat';
  static const String kcal = 'kcal';
  static const String recentFood = 'recent_food';
  static const String foodLogList = 'food_log_list';

  // Health & Fitness
  static const String heartRate = 'heart_rate';
  static const String noHeartRateData = 'no_heart_rate_data';
  static const String healthMetrics = 'health_metrics';
  static const String weight = 'weight';
  static const String bmi = 'bmi';
}

class TextHomeScreen {
  static Map<String, String> _thaiTexts = {};
  static Map<String, String> _englishTexts = {};
  static bool _isEnglish = false; // default ไทย

  static void setLabels(List<Items>? items) {
    _thaiTexts.clear();
    _englishTexts.clear();

    if (items != null) {
      for (final item in items) {
        if (item.table != null) {
          if (item.th != null) {
            _thaiTexts[item.table!] = item.th!;
          }
          if (item.en != null) {
            _englishTexts[item.table!] = item.en!;
          }
        }
      }
    }
  }

  // สลับภาษา
  static void setLanguage(bool isEnglish) {
    _isEnglish = isEnglish;
  }

  static bool get isEnglish => _isEnglish;
  static bool get isThai => !_isEnglish;

  static String getText(String tableKey) {
    final texts = _isEnglish ? _englishTexts : _thaiTexts;
    return texts[tableKey] ?? '';
  }

  static String get welcome => getText('welcome');
  static String get today => getText('today');
  static String get userName => getText('user_name');
  static String get overview => getText('overview');
  static String get nutrition => getText('nutrition');
  static String get foodLog => getText('food_log');
  static String get addFood => getText('add_food');
  static String get seeAll => getText('see_all');
  static String get recentFood => getText('recent_food');
  static String get foodLogList => getText('food_log_list');
  static String get remaining => getText('remaining');
  static String get burned => getText('burned');
  static String get heartRate => getText('heart_rate');
  static String get noHeartRateData => getText('no_heart_rate_data');
  static String get connectDevice => getText('connect_device');
  static String get healthMetrics => getText('health_metrics');
  static String get weight => getText('weight');
  static String get protein => getText('protein');
  static String get carbs => getText('carbs');
  static String get fat => getText('fat');
  static String get from => getText('from');
  static String get kcal => getText('kcal');
  static String get items => getText('items');
  static String get bmi => getText('bmi');
  static String get ago => getText('ago');
  static String get dailyCalories => getText('daily_calories');

  static void clear() {
    _thaiTexts.clear();
    _englishTexts.clear();
  }

  static Map<String, String> getCurrentTexts() {
    return Map.from(_isEnglish ? _englishTexts : _thaiTexts);
  }
}