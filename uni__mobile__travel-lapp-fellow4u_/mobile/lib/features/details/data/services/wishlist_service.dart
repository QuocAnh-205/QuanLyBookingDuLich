import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../features/explore/data/models/explore_models.dart';
import '../../../../core/network/api_client.dart';

class WishlistService {
  final String baseUrl = '${ApiClient.dio.options.baseUrl.endsWith('/') ? ApiClient.dio.options.baseUrl.substring(0, ApiClient.dio.options.baseUrl.length - 1) : ApiClient.dio.options.baseUrl}/wishlist';

  Future<Map<String, dynamic>> toggleWishlist({
    int? tourId,
    int? expId,
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/toggle'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        if (tourId != null) 'tour_id': tourId,
        if (expId != null) 'exp_id': expId,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to toggle wishlist');
    }
  }

  Future<Map<String, List<int>>> getWishlistIds(String token) async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List data = decoded['data'];
      List<int> tourIds = [];
      List<int> expIds = [];
      for (var item in data) {
        if (item['tour_id'] != null) tourIds.add(item['tour_id']);
        if (item['exp_id'] != null) expIds.add(item['exp_id']);
      }
      return {'tours': tourIds, 'experiences': expIds};
    }
    return {'tours': [], 'experiences': []};
  }

  Future<Map<String, List<dynamic>>> getWishlistItems(String token) async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List data = decoded['data'];
      List<Tour> tours = [];
      List<Experience> experiences = [];
      for (var item in data) {
        if (item['Tour'] != null) {
          tours.add(Tour.fromJson(item['Tour']));
        }
        if (item['Experience'] != null) {
          experiences.add(Experience.fromJson(item['Experience']));
        }
      }
      return {'tours': tours, 'experiences': experiences};
    }
    return {'tours': [], 'experiences': []};
  }
}
