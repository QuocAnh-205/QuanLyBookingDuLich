import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/models/trip_models.dart';
import '../provider/trips_provider.dart';
import 'package:mobile/features/auth/providers/auth_provider.dart';

class PaymentScreen extends StatefulWidget {
  final Trip trip;

  const PaymentScreen({super.key, required this.trip});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _currentStep = 0; // 0 for Payment Method, 1 for Preview & Check out
  final _formKey = GlobalKey<FormState>();

  Future<void> _handleCheckout() async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;
    
    final provider = context.read<TripsProvider>();
    final success = await provider.updateStatus(widget.trip.id, 'paid', token);
    
    if (mounted) {
      if (success) {
        // Show success and go back to trips screen or replace with trips screen
        Navigator.pop(context, true); // true indicates success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.error ?? 'Payment failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Payment',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildTabs(),
          Expanded(
            child: _currentStep == 0 ? _buildPaymentMethod() : _buildPreviewCheckout(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTabItem(0, 'Payment Method'),
          Container(width: 40, height: 1, color: Colors.grey[300]),
          _buildTabItem(1, 'Preview & Check out'),
        ],
      ),
    );
  }

  Widget _buildTabItem(int step, String title) {
    final isActive = _currentStep == step;
    return GestureDetector(
      onTap: () => setState(() => _currentStep = step),
      child: Column(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? const Color(0xFF00CEA6) : Colors.grey[300],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: isActive ? const Color(0xFF00CEA6) : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.credit_card, color: Colors.black54),
                const SizedBox(width: 8),
                const Text(
                  'Card Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildTextField('Card Holder\'s Name', 'Card Holder\'s Name'),
            const SizedBox(height: 24),
            _buildTextField('Card Number', '0000 0000 0000 0000', keyboardType: TextInputType.number),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildTextField('Expiration Date', 'mm/yy')),
                const SizedBox(width: 24),
                Expanded(child: _buildTextField('CVV', '000', keyboardType: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    setState(() => _currentStep = 1);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00CEA6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('NEXT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        TextFormField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00CEA6))),
          ),
          keyboardType: keyboardType,
          validator: (value) => value == null || value.isEmpty ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildPreviewCheckout() {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('HH:mm');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trip Card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.network(
                        widget.trip.tour?.thumbnailUrl ?? 'https://images.unsplash.com/photo-1501785888041-af3ef285b470',
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            widget.trip.meetingPoint ?? 'Vietnam',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    if (widget.trip.guide != null)
                      Positioned(
                        bottom: -20,
                        right: 16,
                        child: CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 22,
                            backgroundImage: NetworkImage(widget.trip.guide!.avatarUrl),
                          ),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 24, left: 16, right: 16, bottom: 16),
                  child: Column(
                    children: [
                      _buildDetailRow('Date', dateFormat.format(widget.trip.startDate)),
                      _buildDetailRow('Time', '${timeFormat.format(widget.trip.startDate)} - ${timeFormat.format(widget.trip.endDate)}'),
                      if (widget.trip.guide != null)
                        _buildDetailRow('Guide', widget.trip.guide!.name, valueColor: const Color(0xFF00CEA6)),
                      _buildDetailRow('Number of Travelers', '2'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('\$${widget.trip.totalPrice.toStringAsFixed(2)}', 
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF00CEA6))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('50% payment', style: TextStyle(color: Colors.grey)),
              Text('\$${widget.trip.depositAmount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 4),
          const Text('(You just need to pay upfront 50%)', style: TextStyle(color: Colors.grey, fontSize: 12)),
          
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: context.watch<TripsProvider>().isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _handleCheckout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00CEA6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('CHECK OUT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: valueColor ?? Colors.black),
          ),
        ],
      ),
    );
  }
}
