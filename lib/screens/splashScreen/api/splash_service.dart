


import 'dart:convert';

import 'package:calori_wise_app/screens/splashScreen/api/splash_http_client.dart';

import '../response/validateTokenResponse.dart';

class SplashService{

  static Future<validateTokenResponse?> validateToken({
    required String idToken,
  }) async {
    try {
      const endpoint = 'api/auth/validate-token';

      // ส่ง deviceInfo ไปด้วย
      final response = await SplashHttpClient.validateToken(
          endpoint,
          idToken,
      );

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }

      if (response.body.isEmpty) {
        throw Exception('Empty response body');
      }

      final Map<String, dynamic> jsonData = json.decode(response.body);

      return validateTokenResponse.fromJson(jsonData);

    } catch (e) {
      return validateTokenResponse(
        statusCode: -1,
        message: 'Login failed: ${e.toString()}',
        data: null,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
    }
  }




}