import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';

class TripService {
  final Dio _dio = ApiClient.dio;

  Future<List<dynamic>> fetchMyBookings(String type, String token) async {
    try {
      final response = await _dio.get(
        'bookings',
        queryParameters: {'type': type},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.data['success']) {
        return response.data['data'];
      } else {
        throw response.data['message'] ?? 'Failed to load bookings';
      }
    } on DioException catch (e) {
      throw e.message ?? 'Failed to load bookings';
    }
  }

  Future<Map<String, dynamic>> fetchBookingDetail(int id, String token) async {
    try {
      final response = await _dio.get(
        'bookings/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.data['success']) {
        return response.data['data'];
      } else {
        throw response.data['message'] ?? 'Failed to load booking detail';
      }
    } on DioException catch (e) {
      throw e.message ?? 'Failed to load booking detail';
    }
  }

  Future<Map<String, dynamic>> updateBookingStatus(int id, String status, String token, {String? reason}) async {
    try {
      final response = await _dio.patch(
        'bookings/$id/status',
        data: {
          'status': status,
          if (reason != null) 'reason': reason,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } on DioException catch (e) {
      throw e.message ?? 'Failed to update booking status';
    }
  }

  Future<Map<String, dynamic>> selectBid(int bookingId, int bidId, String token) async {
    try {
      final response = await _dio.post(
        'bookings/$bookingId/select-bid',
        data: {'bid_id': bidId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } on DioException catch (e) {
      throw e.message ?? 'Failed to select bid';
    }
  }
}
