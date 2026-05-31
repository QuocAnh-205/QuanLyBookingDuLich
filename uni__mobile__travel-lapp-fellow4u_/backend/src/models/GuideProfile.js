const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const GuideProfile = sequelize.define('GuideProfile', {
  guide_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
  },
  bio: {
    type: DataTypes.TEXT,
  },
  base_location_id: {
    type: DataTypes.INTEGER,
  },
  rating_avg: {
    type: DataTypes.FLOAT,
    defaultValue: 0.0,
  },
  total_reviews: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
  },
  is_verified: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
  },
}, {
  tableName: 'guide_profiles',
  timestamps: true,
  createdAt: false,
  updatedAt: 'updated_at',
});

module.exports = GuideProfile;
