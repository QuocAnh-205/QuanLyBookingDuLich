const { Payment, UserPaymentMethod, RefundRequest, Booking, BookingStatusHistory, Tour, User, Location } = require('../models');
const crypto = require('crypto');

// Helper: Generate a fake transaction reference
const generateTransactionRef = () => {
  return 'txn_' + crypto.randomBytes(12).toString('hex');
};

// Helper: Simulate payment gateway processing
const simulatePaymentGateway = (paymentMethod) => {
  // Simulate: card ending in 0002 always fails (for testing)
  if (paymentMethod && paymentMethod.last_4 === '0002') {
    return {
      success: false,
      error_code: 'card_declined',
      message: 'Your card was declined. Insufficient funds.',
    };
  }
  // All other cards succeed
  return {
    success: true,
    authorization_code: 'auth_' + crypto.randomBytes(6).toString('hex'),
    message: 'Payment processed successfully.',
  };
};

// @desc    Full checkout: Create booking + process payment
// @route   POST /api/payments/checkout
// @access  Private
const checkout = async (req, res) => {
  try {
    const {
      tour_id,
      start_date,
      end_date,
      guests = 1,
      special_requests,
      payment_method_id,
      payment_type = 'full', // 'full' or 'upfront'
    } = req.body;

    const userId = req.user.user_id;

    // 1. Validate tour exists
    const tour = await Tour.findByPk(tour_id, {
      include: [{ model: Location, attributes: ['city_name'] }]
    });
    if (!tour) {
      return res.status(404).json({ success: false, message: 'Tour not found' });
    }

    // 2. Validate payment method
    let paymentMethod = null;
    if (payment_method_id) {
      paymentMethod = await UserPaymentMethod.findOne({
        where: { method_id: payment_method_id, user_id: userId }
      });
      if (!paymentMethod) {
        return res.status(404).json({ success: false, message: 'Payment method not found' });
      }
    }

    // 3. Calculate total price
    const basePrice = parseFloat(tour.price);
    const totalPrice = basePrice * guests;
    const depositRate = 0.3; // 30% deposit for upfront
    const payAmount = payment_type === 'upfront' ? totalPrice * depositRate : totalPrice;

    // 4. Create booking
    const booking = await Booking.create({
      traveler_id: userId,
      tour_id,
      start_date,
      end_date,
      total_price: totalPrice,
      deposit_amount: payment_type === 'upfront' ? payAmount : 0,
      special_requests,
      status: 'unpaid',
    });

    // 5. Log booking creation in status history
    await BookingStatusHistory.create({
      booking_id: booking.booking_id,
      from_status: null,
      to_status: 'unpaid',
      changed_by: userId,
      reason: 'Booking created via checkout',
    });

    // 6. Simulate payment gateway
    const gatewayResult = simulatePaymentGateway(paymentMethod);
    const transactionRef = generateTransactionRef();

    // 7. Create payment record
    const payment = await Payment.create({
      booking_id: booking.booking_id,
      user_id: userId,
      amount: payAmount,
      currency: 'USD',
      type: payment_type,
      status: gatewayResult.success ? 'success' : 'failed',
      transaction_ref: transactionRef,
      gateway_response: gatewayResult,
      paid_at: gatewayResult.success ? new Date() : null,
    });

    // 8. If payment succeeded, update booking status to 'paid'
    if (gatewayResult.success) {
      booking.status = 'paid';
      await booking.save();

      await BookingStatusHistory.create({
        booking_id: booking.booking_id,
        from_status: 'unpaid',
        to_status: 'paid',
        changed_by: userId,
        reason: `Payment successful: ${transactionRef}`,
      });
    }

    res.status(201).json({
      success: gatewayResult.success,
      message: gatewayResult.success
        ? 'Payment processed successfully!'
        : 'Payment failed. Please try again.',
      data: {
        booking: {
          booking_id: booking.booking_id,
          tour_title: tour.title,
          location: tour.Location?.city_name || '',
          start_date: booking.start_date,
          end_date: booking.end_date,
          guests,
          total_price: totalPrice,
          status: booking.status,
        },
        payment: {
          payment_id: payment.payment_id,
          amount: payAmount,
          currency: payment.currency,
          type: payment.type,
          status: payment.status,
          transaction_ref: transactionRef,
          paid_at: payment.paid_at,
        },
      },
    });
  } catch (error) {
    console.error('Checkout Error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Get user's payment methods (saved cards)
// @route   GET /api/payments/methods
// @access  Private
const getPaymentMethods = async (req, res) => {
  try {
    const methods = await UserPaymentMethod.findAll({
      where: { user_id: req.user.user_id },
      order: [['is_default', 'DESC'], ['created_at', 'DESC']],
    });

    res.json({
      success: true,
      data: methods,
    });
  } catch (error) {
    console.error('Get Payment Methods Error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Add a new payment method (save card)
// @route   POST /api/payments/methods
// @access  Private
const addPaymentMethod = async (req, res) => {
  try {
    const { card_number, card_brand, exp_month, exp_year, cardholder_name } = req.body;
    const userId = req.user.user_id;

    // Extract last 4 digits
    const last4 = card_number ? card_number.slice(-4) : '0000';

    // Generate a simulated token
    const paymentToken = 'tok_' + crypto.randomBytes(8).toString('hex');
    const gatewayCustomerId = 'cus_' + crypto.randomBytes(8).toString('hex');

    // If this is the first card, make it default
    const existingCount = await UserPaymentMethod.count({ where: { user_id: userId } });
    const isDefault = existingCount === 0;

    const method = await UserPaymentMethod.create({
      user_id: userId,
      gateway_customer_id: gatewayCustomerId,
      payment_token: paymentToken,
      card_brand: card_brand || 'Visa',
      last_4: last4,
      exp_month,
      exp_year,
      is_default: isDefault,
    });

    res.status(201).json({
      success: true,
      message: 'Card added successfully',
      data: method,
    });
  } catch (error) {
    console.error('Add Payment Method Error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Get payment history for user
// @route   GET /api/payments/history
// @access  Private
const getPaymentHistory = async (req, res) => {
  try {
    const payments = await Payment.findAll({
      where: { user_id: req.user.user_id },
      include: [
        {
          model: Booking,
          include: [
            {
              model: Tour,
              attributes: ['title', 'thumbnail_url'],
              include: [{ model: Location, attributes: ['city_name'] }],
            },
          ],
        },
      ],
      order: [['created_at', 'DESC']],
    });

    res.json({
      success: true,
      count: payments.length,
      data: payments,
    });
  } catch (error) {
    console.error('Get Payment History Error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Get single payment detail
// @route   GET /api/payments/:id
// @access  Private
const getPaymentDetail = async (req, res) => {
  try {
    const payment = await Payment.findOne({
      where: { payment_id: req.params.id, user_id: req.user.user_id },
      include: [
        {
          model: Booking,
          include: [
            {
              model: Tour,
              attributes: ['title', 'thumbnail_url', 'duration_days'],
              include: [{ model: Location, attributes: ['city_name'] }],
            },
          ],
        },
        {
          model: RefundRequest,
          as: 'Refunds',
        },
      ],
    });

    if (!payment) {
      return res.status(404).json({ success: false, message: 'Payment not found' });
    }

    res.json({
      success: true,
      data: payment,
    });
  } catch (error) {
    console.error('Get Payment Detail Error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Request a refund
// @route   POST /api/payments/:id/refund
// @access  Private
const requestRefund = async (req, res) => {
  try {
    const { reason } = req.body;
    const payment = await Payment.findOne({
      where: { payment_id: req.params.id, user_id: req.user.user_id },
    });

    if (!payment) {
      return res.status(404).json({ success: false, message: 'Payment not found' });
    }

    if (payment.status !== 'success') {
      return res.status(400).json({ success: false, message: 'Only successful payments can be refunded' });
    }

    // Create refund request
    const refund = await RefundRequest.create({
      payment_id: payment.payment_id,
      amount: payment.amount,
      reason: reason || 'Customer requested refund',
      status: 'pending',
    });

    // Auto-process refund (simulated)
    refund.status = 'success';
    refund.processed_at = new Date();
    await refund.save();

    // Update payment status
    payment.status = 'refunded';
    await payment.save();

    // Update booking status to cancelled
    const booking = await Booking.findByPk(payment.booking_id);
    if (booking) {
      const oldStatus = booking.status;
      booking.status = 'cancelled';
      await booking.save();

      await BookingStatusHistory.create({
        booking_id: booking.booking_id,
        from_status: oldStatus,
        to_status: 'cancelled',
        changed_by: req.user.user_id,
        reason: `Refund processed: ${reason || 'Customer request'}`,
      });
    }

    res.json({
      success: true,
      message: 'Refund processed successfully',
      data: refund,
    });
  } catch (error) {
    console.error('Request Refund Error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};

module.exports = {
  checkout,
  getPaymentMethods,
  addPaymentMethod,
  getPaymentHistory,
  getPaymentDetail,
  requestRefund,
};
