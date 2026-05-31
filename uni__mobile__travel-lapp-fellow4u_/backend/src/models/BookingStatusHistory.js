const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const BookingStatusHistory = sequelize.define('BookingStatusHistory', {
  history_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  booking_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'bookings',
      key: 'booking_id',
    },
  },
  from_status: {
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
    allowNull: true,
  },
  to_status: {
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
    allowNull: false,
  },
  changed_by: {
    type: DataTypes.INTEGER,
    allowNull: true,
    references: {
      model: 'users',
      key: 'user_id',
    },
  },
  reason: {
    type: DataTypes.TEXT,
    allowNull: true,
  },
  changed_at: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
  },
}, {
  tableName: 'booking_status_history',
  timestamps: false, // Schema uses changed_at
});

module.exports = BookingStatusHistory;
