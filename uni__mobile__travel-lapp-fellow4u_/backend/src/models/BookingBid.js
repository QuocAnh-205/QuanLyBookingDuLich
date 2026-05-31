const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const BookingBid = sequelize.define('BookingBid', {
  bid_id: {
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
  guide_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'guide_profiles',
      key: 'guide_id',
    },
  },
  offered_price: {
    type: DataTypes.DECIMAL(12, 2),
    allowNull: false,
  },
  message: {
    type: DataTypes.TEXT,
    allowNull: true,
  },
  is_selected: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
  },
}, {
  tableName: 'booking_bids',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: false, // Schema doesn't have updated_at for bids
});

module.exports = BookingBid;
