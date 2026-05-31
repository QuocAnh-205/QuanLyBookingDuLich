const express = require('express');
const router = express.Router();
const {
  checkout,
  getPaymentMethods,
  addPaymentMethod,
  getPaymentHistory,
  getPaymentDetail,
  requestRefund,
} = require('../controllers/paymentController');
const { protect } = require('../middleware/authMiddleware');

// All routes are protected
router.use(protect);

// Checkout - create booking + payment
router.post('/checkout', checkout);

// Payment methods (saved cards)
router.route('/methods')
  .get(getPaymentMethods)
  .post(addPaymentMethod);

// Payment history
router.get('/history', getPaymentHistory);

// Single payment detail
router.get('/:id', getPaymentDetail);

// Request refund
router.post('/:id/refund', requestRefund);

module.exports = router;
