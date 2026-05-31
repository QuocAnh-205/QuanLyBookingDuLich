const express = require('express');
const router = express.Router();
const {
  getMyBookings,
  getBookingDetails,
  createBooking,
  updateBookingStatus,
  submitBid,
  selectBid
} = require('../controllers/bookingController');
const { protect } = require('../middleware/authMiddleware');

// All routes are protected
router.use(protect);

router.route('/')
  .get(getMyBookings)
  .post(createBooking);

router.route('/:id')
  .get(getBookingDetails);

router.route('/:id/status')
  .patch(updateBookingStatus);

router.route('/:id/bids')
  .post(submitBid);

router.route('/:id/select-bid')
  .post(selectBid);

module.exports = router;
