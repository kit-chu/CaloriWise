


import 'package:http/http.dart' as http;

import '../../../utils/api_config.dart';

class SplashHttpClient{
  static const String baseUrl = ApiConfig.baseUrl;
  // static const String baseUrl = "http://10.248.108.226:8085/";

  static Future<http.Response> validateToken(
      String endpoint,
      String token,
      ) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      return await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        body: '{}',
      );
    } catch (e) {
      throw Exception('Network request failed: $e');
    }
  }


}