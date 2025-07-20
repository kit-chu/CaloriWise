import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../services/api/api_service.dart';
import '../../screens/homeScreen/response/homeScreenResponse.dart';
import '../../screens/homeScreen/request/homeScreenReuest.dart';

class ApiCaller {
  static Future<HomeScreenResponse?> fetchHomeScreenItems({required HomeScreenRequest request}) async {
    try {
      final queryParams = request.toQueryParams();
      final endpoint = 'api/text/items?collection=${queryParams['collection']}&version=${queryParams['version']}';

      print('Calling endpoint: $endpoint'); // Debug

      final response = await ApiService.getData(endpoint);

      // Debug: ดู response
      print('Status Code: ${response.statusCode}');
      print('Response body type: ${response.body.runtimeType}');
      print('Response body length: ${response.body.length}');
      print('Response body (first 200 chars): ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');

      // ตรวจสอบว่า response.body เป็น valid JSON หรือไม่
      if (response.body.isEmpty) {
        throw Exception('Empty response body');
      }

      final Map<String, dynamic> jsonData = json.decode(response.body);

      print('Parsed JSON: $jsonData'); // Debug

      return HomeScreenResponse.fromJson(jsonData);
    } catch (e) {
      print('Error in fetchHomeScreenItems: $e');
      print('Stack trace: ${StackTrace.current}');
      return HomeScreenResponse(
        statusCode: -1,
        message: e.toString(),
        data: null,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
    }
  }
}