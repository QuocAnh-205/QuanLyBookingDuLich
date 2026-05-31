const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Location = sequelize.define('Location', {
  location_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  country_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  city_name: {
    type: DataTypes.STRING(100),
    allowNull: false,
  },
  description: {
    type: DataTypes.TEXT,
  },
  thumbnail_url: {
    type: DataTypes.TEXT,
  },
  is_popular: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
  },
  search_count: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
  },
}, {
  tableName: 'locations',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: false,
});

module.exports = Location;
