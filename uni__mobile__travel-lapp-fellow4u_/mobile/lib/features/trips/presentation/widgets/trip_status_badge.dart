import 'package:flutter/material.dart';
import '../../data/models/trip_models.dart';

class TripStatusBadge extends StatelessWidget {
  final TripStatus status;

  const TripStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (status) {
      case TripStatus.waiting:
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        text = 'Waiting';
        break;
      case TripStatus.bidding:
        backgroundColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue;
        text = 'Bidding';
        break;
      case TripStatus.unpaid:
        backgroundColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        text = 'Unpaid';
        break;
      case TripStatus.paid:
        backgroundColor = const Color(0xFF00CEA6).withOpacity(0.1);
        textColor = const Color(0xFF00CEA6);
        text = 'Paid';
        break;
      case TripStatus.ongoing:
        backgroundColor = const Color(0xFF00CEA6);
        textColor = Colors.white;
        text = 'Ongoing';
        break;
      case TripStatus.completed:
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
        text = 'Completed';
        break;
      case TripStatus.cancelled:
        backgroundColor = Colors.black.withOpacity(0.1);
        textColor = Colors.black;
        text = 'Cancelled';
        break;
      case TripStatus.rejected:
        backgroundColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        text = 'Rejected';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
