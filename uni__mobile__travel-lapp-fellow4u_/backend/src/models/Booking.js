const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Booking = sequelize.define('Booking', {
  booking_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  traveler_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'users',
      key: 'user_id',
    },
  },
  guide_id: {
    type: DataTypes.INTEGER,
    allowNull: true,
    references: {
      model: 'guide_profiles',
      key: 'guide_id',
    },
  },
  tour_id: {
    type: DataTypes.INTEGER,
    allowNull: true,
    references: {
      model: 'tours',
      key: 'tour_id',
    },
  },
  start_date: {
    type: DataTypes.DATE,
    allowNull: false,
  },
  end_date: {
    type: DataTypes.DATE,
    allowNull: false,
  },
  status: {
    type: DataTypes.ENUM(
      'waiting',
      'bidding',
      'unpaid',
      'paid',
      'ongoing',
      'completed',
      'cancelled',
      'rejected'
    ),
    defaultValue: 'waiting',
  },
  total_price: {
    type: DataTypes.DECIMAL(12, 2),
    defaultValue: 0.00,
  },
  deposit_amount: {
    type: DataTypes.DECIMAL(12, 2),
    defaultValue: 0.00,
  },
  meeting_point: {
    type: DataTypes.TEXT,
    allowNull: true,
  },
  special_requests: {
    type: DataTypes.TEXT,
    allowNull: true,
  },
}, {
  tableName: 'bookings',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: 'updated_at',
});

module.exports = Booking;
