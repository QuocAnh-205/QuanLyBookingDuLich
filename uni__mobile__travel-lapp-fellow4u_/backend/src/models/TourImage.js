const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const TourImage = sequelize.define('TourImage', {
  image_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  tour_id: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  image_url: {
    type: DataTypes.TEXT,
    allowNull: false
  },
  display_order: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  caption: {
    type: DataTypes.STRING(255)
  }
}, {
  tableName: 'tour_images',
  timestamps: false
});

module.exports = TourImage;
