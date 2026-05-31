import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../data/models/payment_models.dart';
import '../provider/payment_provider.dart';
import 'payment_success_screen.dart';
import 'add_card_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final int tourId;
  final String tourTitle;
  final double tourPrice;
  final int durationDays;
  final String locationName;
  final String thumbnailUrl;

  const CheckoutScreen({
    super.key,
    required this.tourId,
    required this.tourTitle,
    required this.tourPrice,
    required this.durationDays,
    required this.locationName,
    required this.thumbnailUrl,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _currentStep = 0;
  final PageController _pageController = PageController();

  // Step 1 - Booking details
  DateTime? _startDate;
  DateTime? _endDate;
  int _adultCount = 1;
  int _childCount = 0;
  final _notesController = TextEditingController();

  // Step 3 - Payment
  String _paymentType = 'full';
  bool _agreedToTerms = false;
  bool _isProcessing = false;

  static const Color _primaryColor = Color(0xFF00CEA6);

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now().add(const Duration(days: 7));
    _endDate = _startDate!.add(Duration(days: widget.durationDays));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthProvider>().token;
      if (token != null) {
        context.read<PaymentProvider>().fetchPaymentMethods(token);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  int get _totalGuests => _adultCount + _childCount;
  double get _subtotal => widget.tourPrice * _adultCount + (widget.tourPrice * 0.7 * _childCount);
  double get _serviceFee => _subtotal * 0.05;
  double get _totalPrice => _subtotal + _serviceFee;
  double get _payAmount => _paymentType == 'upfront' ? _totalPrice * 0.3 : _totalPrice;

  void _goToStep(int step) {
    setState(() => _currentStep = step);
    _pageController.animateToPage(step, duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now().add(const Duration(days: 3))),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF00CEA6)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          _endDate = picked.add(Duration(days: widget.durationDays));
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _processPayment() async {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to the terms and conditions'), backgroundColor: Colors.red),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final paymentProvider = context.read<PaymentProvider>();
    final token = authProvider.token;

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to continue'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isProcessing = true);

    final request = CheckoutRequest(
      tourId: widget.tourId,
      startDate: _startDate!.toIso8601String(),
      endDate: _endDate!.toIso8601String(),
      guests: _totalGuests,
      specialRequests: _notesController.text.isNotEmpty ? _notesController.text : null,
      paymentMethodId: paymentProvider.selectedMethod?.id,
      paymentType: _paymentType,
    );

    final result = await paymentProvider.processCheckout(request, token);

    setState(() => _isProcessing = false);

    if (!mounted) return;

    if (result.success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PaymentSuccessScreen(result: result),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: Colors.red,
          action: SnackBarAction(label: 'Retry', textColor: Colors.white, onPressed: _processPayment),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: _buildStepIndicator(),
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildStep1BookingDetails(),
          _buildStep2OrderSummary(),
          _buildStep3Payment(),
          _buildStep4Confirm(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = ['Details', 'Summary', 'Payment', 'Confirm'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: List.generate(steps.length, (index) {
          final isActive = index <= _currentStep;
          final isCurrent = index == _currentStep;
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isActive ? _primaryColor : Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isActive && !isCurrent
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : Text('${index + 1}', style: TextStyle(color: isActive ? Colors.white : Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    steps[index],
                    style: TextStyle(
                      fontSize: 11,
                      color: isActive ? _primaryColor : Colors.grey,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (index < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      color: index < _currentStep ? _primaryColor : Colors.grey.shade300,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ===================== STEP 1: Booking Details =====================
  Widget _buildStep1BookingDetails() {
    final dateFormat = DateFormat('MMM dd, yyyy');
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tour summary card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(widget.thumbnailUrl, width: 80, height: 80, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(width: 80, height: 80, color: Colors.grey.shade200, child: const Icon(Icons.landscape, color: Colors.grey)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.tourTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Row(children: [
                        const Icon(Icons.location_on, size: 14, color: Color(0xFF00CEA6)),
                        const SizedBox(width: 4),
                        Text(widget.locationName, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                      ]),
                      const SizedBox(height: 4),
                      Text('${widget.durationDays} days · \$${widget.tourPrice.toStringAsFixed(0)}/person', style: const TextStyle(color: Color(0xFF00CEA6), fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Text('Select Dates', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          // Date pickers
          Row(
            children: [
              Expanded(child: _buildDateField('Start Date', _startDate, () => _selectDate(context, true))),
              const SizedBox(width: 12),
              Expanded(child: _buildDateField('End Date', _endDate, () => _selectDate(context, false))),
            ],
          ),

          const SizedBox(height: 24),
          const Text('Guests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          // Guest counters
          _buildGuestCounter('Adults', _adultCount, (v) => setState(() => _adultCount = v), min: 1),
          const SizedBox(height: 8),
          _buildGuestCounter('Children (30% off)', _childCount, (v) => setState(() => _childCount = v)),

          const SizedBox(height: 24),
          const Text('Special Requests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'e.g., Dietary requirements, accessibility needs...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 32),
          _buildNextButton('Continue to Summary', () => _goToStep(1)),
        ],
      ),
    );
  }

  Widget _buildDateField(String label, DateTime? date, VoidCallback onTap) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Color(0xFF00CEA6)),
                const SizedBox(width: 8),
                Text(date != null ? dateFormat.format(date) : 'Select', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestCounter(String label, int value, ValueChanged<int> onChanged, {int min = 0}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
          IconButton(
            onPressed: value > min ? () => onChanged(value - 1) : null,
            icon: Icon(Icons.remove_circle_outline, color: value > min ? _primaryColor : Colors.grey.shade300),
          ),
          SizedBox(width: 32, child: Center(child: Text('$value', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))),
          IconButton(
            onPressed: value < 10 ? () => onChanged(value + 1) : null,
            icon: Icon(Icons.add_circle_outline, color: value < 10 ? _primaryColor : Colors.grey.shade300),
          ),
        ],
      ),
    );
  }

  // ===================== STEP 2: Order Summary =====================
  Widget _buildStep2OrderSummary() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Order Summary', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          // Tour info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
            child: Column(
              children: [
                _buildSummaryRow('Tour', widget.tourTitle),
                _buildSummaryRow('Location', widget.locationName),
                _buildSummaryRow('Dates', '${DateFormat('MMM dd').format(_startDate!)} - ${DateFormat('MMM dd, yyyy').format(_endDate!)}'),
                _buildSummaryRow('Duration', '${widget.durationDays} days'),
                _buildSummaryRow('Guests', '$_adultCount Adult${_adultCount > 1 ? 's' : ''}${_childCount > 0 ? ', $_childCount Child${_childCount > 1 ? 'ren' : ''}' : ''}'),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Pricing breakdown
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Price Breakdown', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildPriceRow('Adults ($_adultCount × \$${widget.tourPrice.toStringAsFixed(0)})', '\$${(widget.tourPrice * _adultCount).toStringAsFixed(2)}'),
                if (_childCount > 0)
                  _buildPriceRow('Children ($_childCount × \$${(widget.tourPrice * 0.7).toStringAsFixed(0)})', '\$${(widget.tourPrice * 0.7 * _childCount).toStringAsFixed(2)}'),
                _buildPriceRow('Service Fee (5%)', '\$${_serviceFee.toStringAsFixed(2)}'),
                const Divider(height: 24),
                _buildPriceRow('Total', '\$${_totalPrice.toStringAsFixed(2)}', isBold: true, color: _primaryColor),
              ],
            ),
          ),

          if (_notesController.text.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Special Requests', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(_notesController.text, style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            ),
          ],

          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(child: _buildBackButton(() => _goToStep(0))),
              const SizedBox(width: 12),
              Expanded(flex: 2, child: _buildNextButton('Continue to Payment', () => _goToStep(2))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 90, child: Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String amount, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isBold ? Colors.black : Colors.grey.shade600, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: isBold ? 16 : 14)),
          Text(amount, style: TextStyle(color: color ?? Colors.black, fontWeight: isBold ? FontWeight.bold : FontWeight.w500, fontSize: isBold ? 18 : 14)),
        ],
      ),
    );
  }

  // ===================== STEP 3: Payment Method =====================
  Widget _buildStep3Payment() {
    return Consumer<PaymentProvider>(
      builder: (context, provider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Payment Method', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Select how you want to pay', style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 20),

              // Payment type selection
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Payment Plan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    _buildPaymentTypeOption('full', 'Pay in Full', '\$${_totalPrice.toStringAsFixed(2)}', 'Pay the entire amount now'),
                    const SizedBox(height: 8),
                    _buildPaymentTypeOption('upfront', 'Pay Deposit (30%)', '\$${(_totalPrice * 0.3).toStringAsFixed(2)}', 'Pay the rest before the trip'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Saved cards
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Payment Card', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        TextButton.icon(
                          onPressed: () async {
                            final result = await Navigator.of(context).push<bool>(
                              MaterialPageRoute(builder: (_) => const AddCardScreen()),
                            );
                            if (result == true) {
                              // Card was added, methods are already refreshed by provider
                            }
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add Card'),
                          style: TextButton.styleFrom(foregroundColor: _primaryColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (provider.isLoading)
                      const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
                    else if (provider.paymentMethods.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.credit_card_off, size: 40, color: Colors.grey.shade400),
                            const SizedBox(height: 8),
                            Text('No saved cards', style: TextStyle(color: Colors.grey.shade600)),
                            const SizedBox(height: 4),
                            const Text('Add a card to continue', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      )
                    else
                      ...provider.paymentMethods.map((method) => _buildCardOption(method, provider)),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(child: _buildBackButton(() => _goToStep(1))),
                  const SizedBox(width: 12),
                  Expanded(flex: 2, child: _buildNextButton('Review & Confirm', () {
                    if (provider.selectedMethod == null && provider.paymentMethods.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please add a payment card'), backgroundColor: Colors.red),
                      );
                      return;
                    }
                    _goToStep(3);
                  })),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentTypeOption(String value, String title, String amount, String subtitle) {
    final isSelected = _paymentType == value;
    return GestureDetector(
      onTap: () => setState(() => _paymentType = value),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? _primaryColor : Colors.grey.shade300, width: isSelected ? 2 : 1),
          color: isSelected ? _primaryColor.withOpacity(0.05) : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: isSelected ? _primaryColor : Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? _primaryColor : Colors.black)),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ),
            Text(amount, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isSelected ? _primaryColor : Colors.black)),
          ],
        ),
      ),
    );
  }

  Widget _buildCardOption(PaymentMethodModel method, PaymentProvider provider) {
    final isSelected = provider.selectedMethod?.id == method.id;
    return GestureDetector(
      onTap: () => provider.selectMethod(method),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? _primaryColor : Colors.grey.shade300, width: isSelected ? 2 : 1),
          color: isSelected ? _primaryColor.withOpacity(0.05) : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              method.cardBrand.toLowerCase() == 'visa' ? Icons.credit_card : Icons.credit_card,
              color: isSelected ? _primaryColor : Colors.grey,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(method.displayName, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? _primaryColor : Colors.black)),
                  Text('Expires ${method.expiry}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ),
            if (method.isDefault)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: _primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: const Text('Default', style: TextStyle(fontSize: 10, color: Color(0xFF00CEA6), fontWeight: FontWeight.bold)),
              ),
            const SizedBox(width: 8),
            Icon(isSelected ? Icons.check_circle : Icons.circle_outlined, color: isSelected ? _primaryColor : Colors.grey.shade300),
          ],
        ),
      ),
    );
  }

  // ===================== STEP 4: Confirm & Pay =====================
  Widget _buildStep4Confirm() {
    return Consumer<PaymentProvider>(
      builder: (context, provider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Confirm & Pay', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              // Final summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    _buildSummaryRow('Tour', widget.tourTitle),
                    _buildSummaryRow('Dates', '${DateFormat('MMM dd').format(_startDate!)} - ${DateFormat('MMM dd, yyyy').format(_endDate!)}'),
                    _buildSummaryRow('Guests', '$_totalGuests guest${_totalGuests > 1 ? 's' : ''}'),
                    const Divider(),
                    _buildSummaryRow('Payment Plan', _paymentType == 'full' ? 'Full Payment' : 'Deposit (30%)'),
                    if (provider.selectedMethod != null)
                      _buildSummaryRow('Card', provider.selectedMethod!.displayName),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Amount to pay
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF00CEA6), Color(0xFF00B894)]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text('Amount to Pay', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text('\$${_payAmount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                    if (_paymentType == 'upfront')
                      Text('Remaining: \$${(_totalPrice - _payAmount).toStringAsFixed(2)}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Security info
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock_outline, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Your payment information is encrypted and secure.',
                        style: TextStyle(color: Colors.blue.shade700, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Terms checkbox
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _agreedToTerms,
                    onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
                    activeColor: _primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text.rich(
                          TextSpan(children: [
                            const TextSpan(text: 'I agree to the '),
                            TextSpan(text: 'Terms of Service', style: TextStyle(color: _primaryColor, fontWeight: FontWeight.w600)),
                            const TextSpan(text: ' and '),
                            TextSpan(text: 'Cancellation Policy', style: TextStyle(color: _primaryColor, fontWeight: FontWeight.w600)),
                          ]),
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(child: _buildBackButton(() => _goToStep(2))),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isProcessing ? null : _processPayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: _isProcessing
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                            : Text('Pay \$${_payAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // ===================== Common Widgets =====================
  Widget _buildNextButton(String label, VoidCallback onPressed) {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Widget _buildBackButton(VoidCallback onPressed) {
    return SizedBox(
      height: 54,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        child: const Text('Back', style: TextStyle(fontSize: 16, color: Colors.black87)),
      ),
    );
  }
}
