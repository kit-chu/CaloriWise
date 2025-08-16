class AuthScreenResponse {
  int? statusCode;
  String? message;
  Data? data;
  String? errorData;
  int? timestamp;

  AuthScreenResponse({this.statusCode, this.message, this.data, this.errorData, this.timestamp});

  AuthScreenResponse.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    message = json['message'];

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
  List<ItemsAuth>? items;

  Data({this.version, this.screen, this.items});

  Data.fromJson(Map<String, dynamic> json) {
    version = json['version'];
    screen = json['screen'];
    if (json['items'] != null) {
      items = <ItemsAuth>[];
      json['items'].forEach((v) {
        items!.add(new ItemsAuth.fromJson(v));
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

class ItemsAuth {
  String? table;
  String? th;
  String? en;

  ItemsAuth({this.table, this.th, this.en});

  ItemsAuth.fromJson(Map<String, dynamic> json) {
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

// ==========================================

class TextKeysAuth {
  static const String authScreen = 'AuthScreen';      // app title
  static const String authSubtitle = 'auth_subtitle';
  static const String googleSignIn = 'google_sign_in';
  static const String signingIn = 'signing_in';
  static const String loginFailed = 'login_failed';
  static const String termsPrivacy = 'terms_privacy';
}

class TextAuthScreen {
  static Map<String, String> _thaiTexts = {};
  static Map<String, String> _englishTexts = {};
  static bool _isEnglish = false; // default ไทย

  static void setLabels(List<ItemsAuth>? items) {
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

  static void setLanguage(bool isEnglish) {
    _isEnglish = isEnglish;
  }

  static bool get isEnglish => _isEnglish;
  static bool get isThai => !_isEnglish;

  static String getText(String tableKey) {
    final texts = _isEnglish ? _englishTexts : _thaiTexts;
    return texts[tableKey] ?? '';
  }

  // AuthScreen specific getters
  static String get appTitle => getText('AuthScreen');
  static String get subtitle => getText('auth_subtitle');
  static String get googleSignIn => getText('google_sign_in');
  static String get signingIn => getText('signing_in');
  static String get loginFailed => getText('login_failed');
  static String get termsPrivacy => getText('terms_privacy');

  static void clear() {
    _thaiTexts.clear();
    _englishTexts.clear();
  }

  static Map<String, String> getCurrentTexts() {
    return Map.from(_isEnglish ? _englishTexts : _thaiTexts);
  }

  // Check if translations are loaded
  static bool get hasTranslations => _thaiTexts.isNotEmpty || _englishTexts.isNotEmpty;
}

