const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const GuideAvailability = sequelize.define('GuideAvailability', {
  avail_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  guide_id: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  available_date: {
    type: DataTypes.DATEONLY,
    allowNull: false
  },
  status: {
    type: DataTypes.ENUM('available', 'booked', 'off'),
    defaultValue: 'available'
  },
  note: {
    type: DataTypes.TEXT
  }
}, {
  tableName: 'guide_availability',
  timestamps: false
});

module.exports = GuideAvailability;
