


import 'dart:convert';

import '../request/DeviceInfoRequest.dart';
import '../response/AuthScreenResponse.dart';
import '../response/authLoginGoogleResponse.dart';
import 'auth_http_client.dart';

class AuthService{




  static Future<AuthLoginGoogleResponse?> googleLogin({
    required String idToken,
    required DeviceInfoRequest deviceInfo
  }) async {
    try {
      const endpoint = 'api/auth/google-login';

      // ส่ง deviceInfo ไปด้วย
      final response = await AuthHttpClient.googleLogin(
          endpoint,
          idToken,
          deviceInfo  // เพิ่มตัวนี้
      );

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }

      if (response.body.isEmpty) {
        throw Exception('Empty response body');
      }

      final Map<String, dynamic> jsonData = json.decode(response.body);

      return AuthLoginGoogleResponse.fromJson(jsonData);

    } catch (e) {
      print('Google login error: $e');
      return AuthLoginGoogleResponse(
        statusCode: -1,
        message: 'Login failed: ${e.toString()}',
        data: null,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
    }
  }
}