import 'package:flutter/material.dart';
import '../../data/models/payment_models.dart';
import '../../data/services/payment_service.dart';

class PaymentProvider extends ChangeNotifier {
  final PaymentService _paymentService = PaymentService();

  List<PaymentMethodModel> _paymentMethods = [];
  PaymentMethodModel? _selectedMethod;
  PaymentResult? _lastResult;
  bool _isLoading = false;
  String? _error;

  List<PaymentMethodModel> get paymentMethods => _paymentMethods;
  PaymentMethodModel? get selectedMethod => _selectedMethod;
  PaymentResult? get lastResult => _lastResult;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void selectMethod(PaymentMethodModel method) {
    _selectedMethod = method;
    notifyListeners();
  }

  Future<void> fetchPaymentMethods(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _paymentMethods = await _paymentService.getPaymentMethods(token);
      // Auto-select default method
      if (_paymentMethods.isNotEmpty && _selectedMethod == null) {
        _selectedMethod = _paymentMethods.firstWhere(
          (m) => m.isDefault,
          orElse: () => _paymentMethods.first,
        );
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<PaymentResult> processCheckout(CheckoutRequest request, String token) async {
    _isLoading = true;
    _error = null;
    _lastResult = null;
    notifyListeners();

    try {
      _lastResult = await _paymentService.checkout(request, token);
      return _lastResult!;
    } catch (e) {
      _error = e.toString();
      _lastResult = PaymentResult(success: false, message: _error!);
      return _lastResult!;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addCard({
    required String cardNumber,
    required String cardBrand,
    required int expMonth,
    required int expYear,
    required String cardholderName,
    required String token,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final method = await _paymentService.addPaymentMethod(
        cardNumber: cardNumber,
        cardBrand: cardBrand,
        expMonth: expMonth,
        expYear: expYear,
        cardholderName: cardholderName,
        token: token,
      );
      if (method != null) {
        _paymentMethods.add(method);
        _selectedMethod = method;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _lastResult = null;
    _error = null;
    _selectedMethod = null;
    notifyListeners();
  }
}
