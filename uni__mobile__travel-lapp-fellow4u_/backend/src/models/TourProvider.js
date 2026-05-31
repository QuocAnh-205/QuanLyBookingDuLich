const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const TourProvider = sequelize.define('TourProvider', {
  provider_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  name: {
    type: DataTypes.STRING(255),
    allowNull: false
  },
  website_url: {
    type: DataTypes.TEXT
  },
  logo_url: {
    type: DataTypes.TEXT
  },
  rating_avg: {
    type: DataTypes.FLOAT,
    defaultValue: 0.0
  },
  description: {
    type: DataTypes.TEXT
  }
}, {
  tableName: 'tour_providers',
  timestamps: false
});

module.exports = TourProvider;
