import 'package:dio/dio.dart';

class ApiClient {
  static final Dio _dio = Dio(
    BaseOptions(
      // http://localhost:3000/api/ dành cho Web/iOS Simulator
      // http://10.0.2.2:3000/api/ dành cho Android Emulator
      baseUrl: 'http://localhost:3000/api/', 
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  static Dio get dio => _dio;

  static Options getOptionsWithToken(String token) {
    return Options(
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }
}
