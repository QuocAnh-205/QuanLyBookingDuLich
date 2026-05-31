const { Booking, BookingBid, BookingStatusHistory, User, GuideProfile, Tour, Location } = require('../models');
const { Op } = require('sequelize');

// @desc    Get user's bookings (filtered by type for tabs)
// @route   GET /api/bookings
// @access  Private
const getMyBookings = async (req, res) => {
  try {
    const { type } = req.query; // next, current, past
    const userId = req.user.user_id;
    const userRole = req.user.role;

    let statusFilter = [];
    if (type === 'next') {
      statusFilter = ['waiting', 'bidding', 'unpaid', 'paid'];
    } else if (type === 'current') {
      statusFilter = ['ongoing'];
    } else if (type === 'past') {
      statusFilter = ['completed', 'cancelled', 'rejected'];
    }

    const whereClause = {
      status: { [Op.in]: statusFilter },
    };

    if (userRole === 'Traveler') {
      whereClause.traveler_id = userId;
    } else {
      // For Guide, they must be assigned or there must be a bid (this is simplified)
      whereClause.guide_id = userId;
    }

    const bookings = await Booking.findAll({
      where: whereClause,
      include: [
        {
          model: GuideProfile,
          as: 'Guide',
          include: [{ model: User, attributes: ['first_name', 'last_name', 'avatar_url'] }]
        },
        {
          model: Tour,
          include: [{ model: Location, attributes: ['city_name'] }]
        },
        {
          model: BookingBid,
          as: 'Bids',
          attributes: ['bid_id', 'offered_price'],
          limit: 3 // Preview bids
        }
      ],
      order: [['start_date', 'ASC']]
    });

    res.json({
      success: true,
      count: bookings.length,
      data: bookings
    });
  } catch (error) {
    console.error('Get My Bookings Error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Get booking details
// @route   GET /api/bookings/:id
// @access  Private
const getBookingDetails = async (req, res) => {
  try {
    const booking = await Booking.findByPk(req.params.id, {
      include: [
        {
          model: User,
          as: 'Traveler',
          attributes: ['first_name', 'last_name', 'avatar_url']
        },
        {
          model: GuideProfile,
          as: 'Guide',
          include: [{ model: User, attributes: ['first_name', 'last_name', 'avatar_url'] }]
        },
        {
          model: Tour,
          include: [{ model: Location, attributes: ['city_name'] }]
        },
        {
          model: BookingBid,
          as: 'Bids',
          include: [
            {
              model: GuideProfile,
              as: 'Guide',
              include: [{ model: User, attributes: ['first_name', 'last_name', 'avatar_url'] }]
            }
          ]
        },
        {
          model: BookingStatusHistory,
          as: 'StatusHistory',
          order: [['changed_at', 'DESC']]
        }
      ]
    });

    if (!booking) {
      return res.status(404).json({ success: false, message: 'Booking not found' });
    }

    // Check authorization
    if (req.user.role === 'Traveler' && booking.traveler_id !== req.user.user_id) {
      return res.status(403).json({ success: false, message: 'Not authorized' });
    }

    res.json({
      success: true,
      data: booking
    });
  } catch (error) {
    console.error('Get Booking Details Error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Create a new booking request
// @route   POST /api/bookings
// @access  Private
const createBooking = async (req, res) => {
  try {
    const { tour_id, guide_id, start_date, end_date, meeting_point, special_requests, total_price } = req.body;

    // Initial status is 'waiting' if guide_id is provided, or 'bidding' if not
    const status = guide_id ? 'waiting' : 'bidding';

    const booking = await Booking.create({
      traveler_id: req.user.user_id,
      guide_id,
      tour_id,
      start_date,
      end_date,
      meeting_point,
      special_requests,
      total_price,
      status
    });

    res.status(201).json({
      success: true,
      data: booking
    });
  } catch (error) {
    console.error('Create Booking Error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Update booking status
// @route   PATCH /api/bookings/:id/status
// @access  Private
const updateBookingStatus = async (req, res) => {
  try {
    const { status, reason } = req.body;
    const booking = await Booking.findByPk(req.params.id);

    if (!booking) {
      return res.status(404).json({ success: false, message: 'Booking not found' });
    }

    // Logic for who can update what status
    // For now, allow simple updates
    const oldStatus = booking.status;
    booking.status = status;
    await booking.save();

    // Log status change (though the trigger handles it, we can also do it manually for extra info)
    await BookingStatusHistory.create({
      booking_id: booking.booking_id,
      from_status: oldStatus,
      to_status: status,
      changed_by: req.user.user_id,
      reason
    });

    res.json({
      success: true,
      data: booking
    });
  } catch (error) {
    console.error('Update Booking Status Error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Submit a bid for a booking
// @route   POST /api/bookings/:id/bids
// @access  Private (Guide only)
const submitBid = async (req, res) => {
  try {
    if (req.user.role !== 'Guide') {
      return res.status(403).json({ success: false, message: 'Only guides can submit bids' });
    }

    const { offered_price, message } = req.body;
    const bookingId = req.params.id;

    const booking = await Booking.findByPk(bookingId);
    if (!booking || booking.status !== 'bidding') {
      return res.status(400).json({ success: false, message: 'Booking is not open for bidding' });
    }

    const bid = await BookingBid.create({
      booking_id: bookingId,
      guide_id: req.user.user_id,
      offered_price,
      message
    });

    res.status(201).json({
      success: true,
      data: bid
    });
  } catch (error) {
    console.error('Submit Bid Error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Select a bid
// @route   POST /api/bookings/:id/select-bid
// @access  Private (Traveler only)
const selectBid = async (req, res) => {
  try {
    const { bid_id } = req.body;
    const booking = await Booking.findByPk(req.params.id);

    if (!booking || booking.traveler_id !== req.user.user_id) {
      return res.status(403).json({ success: false, message: 'Not authorized' });
    }

    const bid = await BookingBid.findByPk(bid_id);
    if (!bid || bid.booking_id !== booking.booking_id) {
      return res.status(404).json({ success: false, message: 'Bid not found' });
    }

    // Update booking
    booking.guide_id = bid.guide_id;
    booking.total_price = bid.offered_price;
    booking.status = 'unpaid';
    await booking.save();

    // Mark bid as selected
    bid.is_selected = true;
    await bid.save();

    res.json({
      success: true,
      message: 'Bid selected successfully',
      data: booking
    });
  } catch (error) {
    console.error('Select Bid Error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};

module.exports = {
  getMyBookings,
  getBookingDetails,
  createBooking,
  updateBookingStatus,
  submitBid,
  selectBid
};
