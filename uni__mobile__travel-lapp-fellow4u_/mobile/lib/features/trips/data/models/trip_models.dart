import 'package:mobile/features/explore/data/models/explore_models.dart';

enum TripStatus {
  waiting,
  bidding,
  unpaid,
  paid,
  ongoing,
  completed,
  cancelled,
  rejected
}

class BookingBid {
  final int id;
  final int bookingId;
  final Guide guide;
  final double offeredPrice;
  final String? message;
  final bool isSelected;

  BookingBid({
    required this.id,
    required this.bookingId,
    required this.guide,
    required this.offeredPrice,
    this.message,
    this.isSelected = false,
  });

  factory BookingBid.fromJson(Map<String, dynamic> json) {
    return BookingBid(
      id: json['bid_id'] ?? 0,
      bookingId: json['booking_id'] ?? 0,
      guide: json['Guide'] != null
          ? Guide.fromJson(json['Guide'])
          : Guide(
              id: 0,
              name: 'Unknown Guide',
              avatarUrl: 'https://i.pravatar.cc/150?u=unknown_guide',
              rating: 0.0,
              totalReviews: 0,
              locationName: '',
            ),
      offeredPrice: double.parse(json['offered_price']?.toString() ?? '0.0'),
      message: json['message'],
      isSelected: json['is_selected'] ?? false,
    );
  }
}

class BookingStatusHistory {
  final int id;
  final TripStatus? fromStatus;
  final TripStatus toStatus;
  final String? reason;
  final DateTime changedAt;

  BookingStatusHistory({
    required this.id,
    this.fromStatus,
    required this.toStatus,
    this.reason,
    required this.changedAt,
  });

  factory BookingStatusHistory.fromJson(Map<String, dynamic> json) {
    return BookingStatusHistory(
      id: json['history_id'] ?? 0,
      fromStatus: json['from_status'] != null
          ? TripStatus.values.firstWhere(
              (e) => e.name.toLowerCase() == json['from_status'].toString().toLowerCase(),
              orElse: () => TripStatus.waiting,
            )
          : null,
      toStatus: TripStatus.values.firstWhere(
        (e) => e.name.toLowerCase() == json['to_status'].toString().toLowerCase(),
        orElse: () => TripStatus.waiting,
      ),
      reason: json['reason'],
      changedAt: json['changed_at'] != null ? DateTime.parse(json['changed_at']) : DateTime.now(),
    );
  }
}

class Trip {
  final int id;
  final int travelerId;
  final Guide? guide;
  final Tour? tour;
  final DateTime startDate;
  final DateTime endDate;
  final TripStatus status;
  final double totalPrice;
  final double depositAmount;
  final String? meetingPoint;
  final String? specialRequests;
  final List<BookingBid> bids;
  final List<BookingStatusHistory> statusHistory;

  Trip({
    required this.id,
    required this.travelerId,
    this.guide,
    this.tour,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.totalPrice,
    required this.depositAmount,
    this.meetingPoint,
    this.specialRequests,
    this.bids = const [],
    this.statusHistory = const [],
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['booking_id'] ?? 0,
      travelerId: json['traveler_id'] ?? 0,
      guide: json['Guide'] != null ? Guide.fromJson(json['Guide']) : null,
      tour: json['Tour'] != null ? Tour.fromJson(json['Tour']) : null,
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date']) : DateTime.now(),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : DateTime.now(),
      status: TripStatus.values.firstWhere(
        (e) => e.name.toLowerCase() == json['status'].toString().toLowerCase(),
        orElse: () => TripStatus.waiting,
      ),
      totalPrice: double.parse(json['total_price']?.toString() ?? '0.0'),
      depositAmount: double.parse(json['deposit_amount']?.toString() ?? '0.0'),
      meetingPoint: json['meeting_point'],
      specialRequests: json['special_requests'],
      bids: (json['Bids'] as List?)
              ?.where((i) => i != null)
              .map((i) => BookingBid.fromJson(i))
              .toList() ??
          [],
      statusHistory: (json['StatusHistory'] as List?)
              ?.where((i) => i != null)
              .map((i) => BookingStatusHistory.fromJson(i))
              .toList() ??
          [],
    );
  }
}
