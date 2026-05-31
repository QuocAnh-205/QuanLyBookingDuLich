import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final _storage = const FlutterSecureStorage();
  
  bool _isLoading = false;
  String? _token;
  int? _userId;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get token => _token;
  int? get userId => _userId;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _token != null;

  Future<void> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final response = await _authService.login(email, password);
      _token = response.data['token'];
      _userId = response.data['user']['user_id'];
      
      await _storage.write(key: 'jwt_token', value: _token);
      await _storage.write(key: 'user_id', value: _userId.toString());
      
      notifyListeners();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout || 
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        _errorMessage = 'Server is unreachable. Please check your connection.';
      } else {
        _errorMessage = e.response?.data['message'] ?? 'Login failed';
      }
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String roleType,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _authService.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        roleType: roleType,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout || 
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        _errorMessage = 'Server is unreachable. Please check your connection.';
      } else {
        _errorMessage = e.response?.data['message'] ?? 'Registration failed';
      }
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> tryAutoLogin() async {
    _token = await _storage.read(key: 'jwt_token');
    final userIdStr = await _storage.read(key: 'user_id');
    if (userIdStr != null) {
      _userId = int.tryParse(userIdStr);
    }
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: 'user_id');
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
