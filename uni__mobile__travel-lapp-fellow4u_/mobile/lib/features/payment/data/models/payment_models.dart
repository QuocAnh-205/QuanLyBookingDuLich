class PaymentMethodModel {
  final int id;
  final String cardBrand;
  final String last4;
  final int expMonth;
  final int expYear;
  final bool isDefault;

  PaymentMethodModel({
    required this.id,
    required this.cardBrand,
    required this.last4,
    required this.expMonth,
    required this.expYear,
    this.isDefault = false,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['method_id'] ?? 0,
      cardBrand: json['card_brand'] ?? 'Visa',
      last4: json['last_4'] ?? '****',
      expMonth: json['exp_month'] ?? 1,
      expYear: json['exp_year'] ?? 2025,
      isDefault: json['is_default'] ?? false,
    );
  }

  String get displayName => '$cardBrand •••• $last4';
  String get expiry => '${expMonth.toString().padLeft(2, '0')}/${expYear.toString().substring(2)}';
}

class CheckoutRequest {
  final int tourId;
  final String startDate;
  final String endDate;
  final int guests;
  final String? specialRequests;
  final int? paymentMethodId;
  final String paymentType; // 'full' or 'upfront'

  CheckoutRequest({
    required this.tourId,
    required this.startDate,
    required this.endDate,
    this.guests = 1,
    this.specialRequests,
    this.paymentMethodId,
    this.paymentType = 'full',
  });

  Map<String, dynamic> toJson() {
    return {
      'tour_id': tourId,
      'start_date': startDate,
      'end_date': endDate,
      'guests': guests,
      'special_requests': specialRequests,
      'payment_method_id': paymentMethodId,
      'payment_type': paymentType,
    };
  }
}

class PaymentResult {
  final bool success;
  final String message;
  final BookingResult? booking;
  final PaymentInfo? payment;

  PaymentResult({
    required this.success,
    required this.message,
    this.booking,
    this.payment,
  });

  factory PaymentResult.fromJson(Map<String, dynamic> json) {
    return PaymentResult(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      booking: json['data']?['booking'] != null
          ? BookingResult.fromJson(json['data']['booking'])
          : null,
      payment: json['data']?['payment'] != null
          ? PaymentInfo.fromJson(json['data']['payment'])
          : null,
    );
  }
}

class BookingResult {
  final int bookingId;
  final String tourTitle;
  final String location;
  final String startDate;
  final String endDate;
  final int guests;
  final double totalPrice;
  final String status;

  BookingResult({
    required this.bookingId,
    required this.tourTitle,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.guests,
    required this.totalPrice,
    required this.status,
  });

  factory BookingResult.fromJson(Map<String, dynamic> json) {
    return BookingResult(
      bookingId: json['booking_id'] ?? 0,
      tourTitle: json['tour_title'] ?? '',
      location: json['location'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      guests: json['guests'] ?? 1,
      totalPrice: double.parse(json['total_price']?.toString() ?? '0'),
      status: json['status'] ?? '',
    );
  }
}

class PaymentInfo {
  final int paymentId;
  final double amount;
  final String currency;
  final String type;
  final String status;
  final String transactionRef;
  final String? paidAt;

  PaymentInfo({
    required this.paymentId,
    required this.amount,
    required this.currency,
    required this.type,
    required this.status,
    required this.transactionRef,
    this.paidAt,
  });

  factory PaymentInfo.fromJson(Map<String, dynamic> json) {
    return PaymentInfo(
      paymentId: json['payment_id'] ?? 0,
      amount: double.parse(json['amount']?.toString() ?? '0'),
      currency: json['currency'] ?? 'USD',
      type: json['type'] ?? 'full',
      status: json['status'] ?? 'pending',
      transactionRef: json['transaction_ref'] ?? '',
      paidAt: json['paid_at'],
    );
  }
}
