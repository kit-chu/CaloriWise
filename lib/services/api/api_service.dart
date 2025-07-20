import "package:http/http.dart" as http show Response, get, post;
import '../../utils/api_config.dart';

class ApiService {
  static const String baseUrl = ApiConfig.baseUrl;

  static Future<http.Response> getData(String endpoint) async {
    final url = Uri.parse(baseUrl + endpoint);
    return await http.get(url);
  }

  static Future<http.Response> postData(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse(baseUrl + endpoint);
    return await http.post(url, body: body);
  }
}
