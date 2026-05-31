import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/payment_models.dart';

class PaymentService {
  final Dio _dio = ApiClient.dio;

  // Full checkout: create booking + process payment
  Future<PaymentResult> checkout(CheckoutRequest request, String token) async {
    try {
      final response = await _dio.post(
        'payments/checkout',
        data: request.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return PaymentResult.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        return PaymentResult(
          success: false,
          message: e.response?.data['message'] ?? 'Checkout failed',
        );
      }
      throw 'Network error. Please check your connection.';
    }
  }

  // Get saved payment methods
  Future<List<PaymentMethodModel>> getPaymentMethods(String token) async {
    try {
      final response = await _dio.get(
        'payments/methods',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.data['success']) {
        return (response.data['data'] as List)
            .map((json) => PaymentMethodModel.fromJson(json))
            .toList();
      }
      return [];
    } on DioException {
      return [];
    }
  }

  // Add a new payment method (card)
  Future<PaymentMethodModel?> addPaymentMethod({
    required String cardNumber,
    required String cardBrand,
    required int expMonth,
    required int expYear,
    required String cardholderName,
    required String token,
  }) async {
    try {
      final response = await _dio.post(
        'payments/methods',
        data: {
          'card_number': cardNumber,
          'card_brand': cardBrand,
          'exp_month': expMonth,
          'exp_year': expYear,
          'cardholder_name': cardholderName,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.data['success']) {
        return PaymentMethodModel.fromJson(response.data['data']);
      }
      return null;
    } on DioException {
      return null;
    }
  }
}
