

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../utils/api_config.dart';
import '../request/DeviceInfoRequest.dart';
import '../response/AuthScreenResponse.dart';

class AuthHttpClient{
  static const String baseUrl = ApiConfig.baseUrl;

   // static const String baseUrl = "http://10.248.108.225:8085/";
  static Future<http.Response> googleLogin(
      String endpoint,
      String token,
      DeviceInfoRequest deviceInfo
      ) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      return await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(deviceInfo.toJson())
      );
    } catch (e) {
      throw Exception('Network request failed: $e');
    }
  }

}