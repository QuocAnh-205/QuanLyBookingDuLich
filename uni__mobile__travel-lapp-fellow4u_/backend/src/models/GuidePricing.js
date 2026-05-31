const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const GuidePricing = sequelize.define('GuidePricing', {
  price_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  guide_id: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  min_travelers: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 1
  },
  max_travelers: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  price_per_hour: {
    type: DataTypes.DECIMAL(12, 2),
    allowNull: false
  }
}, {
  tableName: 'guide_pricing',
  timestamps: false
});

module.exports = GuidePricing;
