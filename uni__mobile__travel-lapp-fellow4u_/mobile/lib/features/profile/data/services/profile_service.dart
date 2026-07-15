import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';

class ProfileService {
  final Dio _dio = ApiClient.dio;

  Future<Map<String, dynamic>> fetchProfile(String token) async {
    try {
      final response = await _dio.get(
        'profile',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.data['success']) {
        return response.data['data'];
      } else {
        throw response.data['message'] ?? 'Failed to load profile';
      }
    } on DioException catch (e) {
      throw e.message ?? 'Failed to load profile';
    }
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data, String token) async {
    try {
      final response = await _dio.put(
        'profile',
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.data['success']) {
        return response.data['data'];
      } else {
        throw response.data['message'] ?? 'Failed to update profile';
      }
    } on DioException catch (e) {
      throw e.message ?? 'Failed to update profile';
    }
  }

  Future<Map<String, dynamic>> updateSettings(Map<String, dynamic> data, String token) async {
    try {
      final response = await _dio.put(
        'profile/settings',
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.data['success']) {
        return response.data['data'];
      } else {
        throw response.data['message'] ?? 'Failed to update settings';
      }
    } on DioException catch (e) {
      throw e.message ?? 'Failed to update settings';
    }
  }

  Future<List<dynamic>> fetchJourneys(String token) async {
    try {
      final response = await _dio.get(
        'profile/journeys',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.data['success']) {
        return response.data['data'];
      } else {
        throw response.data['message'] ?? 'Failed to load journeys';
      }
    } on DioException catch (e) {
      throw e.message ?? 'Failed to load journeys';
    }
  }

  Future<void> deletePhoto(int id, String token) async {
    try {
      final response = await _dio.delete(
        'profile/photos/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (!response.data['success']) {
        throw response.data['message'] ?? 'Failed to delete photo';
      }
    } on DioException catch (e) {
      throw e.message ?? 'Failed to delete photo';
    }
  }

  Future<void> deleteJourney(int id, String token) async {
    try {
      final response = await _dio.delete(
        'profile/journeys/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (!response.data['success']) {
        throw response.data['message'] ?? 'Failed to delete journey';
      }
    } on DioException catch (e) {
      throw e.message ?? 'Failed to delete journey';
    }
  }

  Future<Map<String, dynamic>> uploadPhoto(Map<String, dynamic> data, String token) async {
    try {
      final response = await _dio.post(
        'profile/photos',
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.data['success']) {
        return response.data['data'];
      } else {
        throw response.data['message'] ?? 'Failed to upload photo';
      }
    } on DioException catch (e) {
      throw e.message ?? 'Failed to upload photo';
    }
  }

  Future<List<dynamic>> fetchPhotos(String token) async {
    try {
      final response = await _dio.get(
        'profile/photos',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.data['success']) {
        return response.data['data'];
      } else {
        throw response.data['message'] ?? 'Failed to load photos';
      }
    } on DioException catch (e) {
      throw e.message ?? 'Failed to load photos';
    }
  }

  Future<Map<String, dynamic>> createJourney(Map<String, dynamic> data, String token) async {
    try {
      final response = await _dio.post(
        'profile/journeys',
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.data['success']) {
        return response.data['data'];
      } else {
        throw response.data['message'] ?? 'Failed to create journey';
      }
    } on DioException catch (e) {
      throw e.message ?? 'Failed to create journey';
    }
  }

  Future<void> changePassword(Map<String, dynamic> data, String token) async {
    try {
      final response = await _dio.put(
        'profile/change-password',
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (!response.data['success']) {
        throw response.data['message'] ?? 'Failed to change password';
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        throw e.response?.data['message'] ?? 'Failed to change password';
      }
      throw e.message ?? 'Failed to change password';
    }
  }
}
