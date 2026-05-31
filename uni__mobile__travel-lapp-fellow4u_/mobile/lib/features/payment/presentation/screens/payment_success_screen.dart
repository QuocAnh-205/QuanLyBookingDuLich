import 'package:flutter/material.dart';
import '../../data/models/payment_models.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final PaymentResult result;

  const PaymentSuccessScreen({super.key, required this.result});

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> with TickerProviderStateMixin {
  late AnimationController _checkController;
  late AnimationController _fadeController;
  late Animation<double> _checkAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  static const Color _primaryColor = Color(0xFF00CEA6);

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

    _checkAnimation = CurvedAnimation(parent: _checkController, curve: Curves.elasticOut);
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _checkController, curve: Curves.elasticOut));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _checkController.forward().then((_) => _fadeController.forward());
  }

  @override
  void dispose() {
    _checkController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.result.booking;
    final payment = widget.result.payment;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Animated check icon
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(colors: [Color(0xFF00CEA6), Color(0xFF00B894)]),
                    boxShadow: [BoxShadow(color: _primaryColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
                  ),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 52),
                ),
              ),

              const SizedBox(height: 28),

              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    const Text('Payment Successful!', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Your booking has been confirmed', style: TextStyle(fontSize: 15, color: Colors.grey.shade600)),

                    const SizedBox(height: 32),

                    // Booking details card
                    if (booking != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.confirmation_number_outlined, color: Color(0xFF00CEA6), size: 20),
                                const SizedBox(width: 8),
                                Text('Booking #${booking.bookingId}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                            const Divider(height: 24),
                            _buildDetailRow(Icons.tour, 'Tour', booking.tourTitle),
                            _buildDetailRow(Icons.location_on, 'Location', booking.location),
                            _buildDetailRow(Icons.calendar_today, 'Start', _formatDate(booking.startDate)),
                            _buildDetailRow(Icons.calendar_today, 'End', _formatDate(booking.endDate)),
                            _buildDetailRow(Icons.people, 'Guests', '${booking.guests}'),
                            _buildDetailRow(Icons.attach_money, 'Total', '\$${booking.totalPrice.toStringAsFixed(2)}'),
                          ],
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Payment info card
                    if (payment != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.receipt_long, color: Color(0xFF00CEA6), size: 20),
                                const SizedBox(width: 8),
                                const Text('Payment Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                            const Divider(height: 24),
                            _buildDetailRow(Icons.payment, 'Amount Paid', '\$${payment.amount.toStringAsFixed(2)} ${payment.currency}'),
                            _buildDetailRow(Icons.category, 'Type', payment.type == 'full' ? 'Full Payment' : 'Deposit (30%)'),
                            _buildDetailRow(Icons.tag, 'Transaction', payment.transactionRef),
                            _buildDetailRow(Icons.check_circle, 'Status', payment.status.toUpperCase()),
                          ],
                        ),
                      ),

                    const SizedBox(height: 32),

                    // Actions
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                          Navigator.of(context).pushReplacementNamed('/explore');
                        },
                        icon: const Icon(Icons.explore, color: Colors.white),
                        label: const Text('View My Trips', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                          Navigator.of(context).pushReplacementNamed('/explore');
                        },
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: const Text('Back to Explore', style: TextStyle(fontSize: 16, color: Colors.black87)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade500),
          const SizedBox(width: 10),
          SizedBox(width: 80, child: Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
