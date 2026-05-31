const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Tour = sequelize.define('Tour', {
  tour_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  title: {
    type: DataTypes.STRING(255),
    allowNull: false,
  },
  location_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  price: {
    type: DataTypes.DECIMAL(12, 2),
    allowNull: false,
    validate: {
      min: 0,
    },
  },
  duration_days: {
    type: DataTypes.INTEGER,
    defaultValue: 1,
    validate: {
      min: 1,
    },
  },
  thumbnail_url: {
    type: DataTypes.TEXT,
  },
  description: {
    type: DataTypes.TEXT,
  },
  is_featured: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
  },
  provider_id: {
    type: DataTypes.INTEGER,
    allowNull: true,
  },
  pickup_point: {
    type: DataTypes.TEXT,
  },
}, {
  tableName: 'tours',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: 'updated_at',
});

module.exports = Tour;
