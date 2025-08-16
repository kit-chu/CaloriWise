import 'dart:convert';
import '../../screens/NetworkErrorScreen/response/ConnectionResponse.dart';
import '../../screens/authScreen/request/AuthScreenReuest.dart';
import '../../screens/authScreen/response/AuthScreenResponse.dart';
import '../../services/api/api_service.dart';
import '../../screens/homeScreen/response/homeScreenResponse.dart';
import '../../screens/homeScreen/request/homeScreenReuest.dart';

class ApiCaller {
  static Future<HomeScreenResponse?> fetchHomeScreenItems(
      {required HomeScreenRequest request}) async {
    try {
      final queryParams = request.toQueryParams();
      final endpoint = 'api/text/items?collection=${queryParams['collection']}&version=${queryParams['version']}';

      final response = await ApiService.getData(endpoint);

      final Map<String, dynamic> jsonData = json.decode(response.body);


      return HomeScreenResponse.fromJson(jsonData);
    } catch (e) {
      return HomeScreenResponse(
        statusCode: -1,
        message: e.toString(),
        data: null,
        timestamp: DateTime
            .now()
            .millisecondsSinceEpoch,
      );
    }
  }

  static Future<AuthScreenResponse?> fetchAuthScreenItems(
      {required AuthScreenRequest request}) async {
    try {
      final queryParams = request.toQueryParams();
      final endpoint = 'api/text/items?collection=${queryParams['collection']}&version=${queryParams['version']}';
      final response = await ApiService.getData(endpoint);
      if (response.body.isEmpty) {
        throw Exception('Empty response body');
      }
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return AuthScreenResponse.fromJson(jsonData);
    } catch (e) {
      return AuthScreenResponse(
        statusCode: -1,
        message: e.toString(),
        data: null,
        timestamp: DateTime
            .now()
            .millisecondsSinceEpoch,
      );
    }
  }

  static Future<ConnectionResponse?> checkConnection() async {
    try {
      const endpoint = 'api/text/items';
      final isConnected = await ApiService.checkServerConnection(endpoint);
      return ConnectionResponse(
        statusCode: isConnected ? 200 : -1,
        message: isConnected ? 'Connection successful' : 'Connection failed',
        data: isConnected,
        timestamp: DateTime
            .now()
            .millisecondsSinceEpoch,
      );
    } catch (e) {
      return ConnectionResponse(
        statusCode: -1,
        message: e.toString(),
        data: false,
        timestamp: DateTime
            .now()
            .millisecondsSinceEpoch,
      );
    }
  }

}