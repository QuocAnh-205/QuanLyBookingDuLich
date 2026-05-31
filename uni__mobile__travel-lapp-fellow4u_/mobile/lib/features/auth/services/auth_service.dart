import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class AuthService {
  final Dio _dio = ApiClient.dio;

  Future<Response> login(String email, String password) async {
    try {
      final response = await _dio.post('auth/login', data: {
        'email': email,
        'password': password,
      });
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String roleType,
  }) async {
    try {
      final response = await _dio.post('auth/register', data: {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
        'role_type': roleType,
      });
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
