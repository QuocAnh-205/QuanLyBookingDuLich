const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const JourneyMedia = sequelize.define('JourneyMedia', {
  journey_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    references: {
      model: 'user_journeys',
      key: 'journey_id',
    },
  },
  photo_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    references: {
      model: 'user_photos',
      key: 'photo_id',
    },
  },
  display_order: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
  },
}, {
  tableName: 'journey_media',
  timestamps: false,
});

module.exports = JourneyMedia;
