import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/search_models.dart';
import '../../../../core/network/api_client.dart';

class SearchService {
  final String baseUrl = '${ApiClient.dio.options.baseUrl.endsWith('/') ? ApiClient.dio.options.baseUrl.substring(0, ApiClient.dio.options.baseUrl.length - 1) : ApiClient.dio.options.baseUrl}/search';

  Future<SearchResult> search({
    String? query,
    String? type,
    double? minPrice,
    double? maxPrice,
    int? locationId,
    String? token,
  }) async {
    final Map<String, String> queryParams = {};
    if (query != null) queryParams['q'] = query;
    if (type != null) queryParams['type'] = type;
    if (minPrice != null) queryParams['min_price'] = minPrice.toString();
    if (maxPrice != null) queryParams['max_price'] = maxPrice.toString();
    if (locationId != null) queryParams['location_id'] = locationId.toString();

    final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
    
    final response = await http.get(
      uri,
      headers: token != null ? {'Authorization': 'Bearer $token'} : null,
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      return SearchResult.fromJson(decoded['data']);
    } else {
      throw Exception('Search failed');
    }
  }

  Future<List<String>> getPopularSearches() async {
    final response = await http.get(Uri.parse('$baseUrl/popular'));
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      return (decoded['data'] as List).map((e) => e['keyword'].toString()).toList();
    }
    return [];
  }

  Future<List<SearchHistoryItem>> getUserHistory(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/history'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      return (decoded['data'] as List).map((e) => SearchHistoryItem.fromJson(e)).toList();
    }
    return [];
  }
}
