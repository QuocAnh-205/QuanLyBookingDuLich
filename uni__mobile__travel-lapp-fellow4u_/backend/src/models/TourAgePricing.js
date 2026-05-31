const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const TourAgePricing = sequelize.define('TourAgePricing', {
  price_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  tour_id: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  age_group_label: {
    type: DataTypes.STRING(50),
    allowNull: false
  },
  price: {
    type: DataTypes.DECIMAL(12, 2),
    allowNull: false,
    defaultValue: 0.0
  },
  currency: {
    type: DataTypes.STRING(10),
    defaultValue: 'USD'
  }
}, {
  tableName: 'tour_age_pricing',
  timestamps: false
});

module.exports = TourAgePricing;
