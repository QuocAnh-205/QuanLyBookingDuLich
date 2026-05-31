const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const TourSchedule = sequelize.define('TourSchedule', {
  schedule_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  tour_id: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  day_number: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  start_time: {
    type: DataTypes.TIME,
    allowNull: false
  },
  activity_title: {
    type: DataTypes.STRING(255),
    allowNull: false
  },
  description: {
    type: DataTypes.TEXT
  },
  attraction_id: {
    type: DataTypes.INTEGER,
    allowNull: true
  }
}, {
  tableName: 'tour_schedules',
  timestamps: false
});

module.exports = TourSchedule;
