import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';

class ExploreService {
  final Dio _dio = ApiClient.dio;

  Future<Map<String, dynamic>> getExploreOverview() async {
    try {
      final response = await _dio.get('explore/overview');
      return response.data;
    } on DioException catch (e) {
      throw e.message ?? 'Failed to load explore data';
    }
  }

  Future<List<dynamic>> getTours({int? locationId, bool? isFeatured}) async {
    try {
      final response = await _dio.get('explore/tours', queryParameters: {
        if (locationId != null) 'location_id': locationId,
        if (isFeatured != null) 'is_featured': isFeatured,
      });
      return response.data;
    } on DioException catch (e) {
      throw e.message ?? 'Failed to load tours';
    }
  }

  Future<Map<String, dynamic>> toggleWishlist(int? tourId, int? expId, String token) async {
    try {
      final response = await _dio.post(
        'explore/wishlist',
        data: {
          if (tourId != null) 'tour_id': tourId,
          if (expId != null) 'exp_id': expId,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } on DioException catch (e) {
      throw e.message ?? 'Failed to update wishlist';
    }
  }
}
