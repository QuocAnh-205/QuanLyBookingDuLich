const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Attraction = sequelize.define('Attraction', {
  attraction_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  location_id: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  name: {
    type: DataTypes.STRING(255),
    allowNull: false
  },
  address: {
    type: DataTypes.TEXT
  },
  description: {
    type: DataTypes.TEXT
  },
  image_url: {
    type: DataTypes.TEXT
  },
  latitude: {
    type: DataTypes.DECIMAL(9, 6)
  },
  longitude: {
    type: DataTypes.DECIMAL(9, 6)
  }
}, {
  tableName: 'attractions',
  timestamps: false
});

module.exports = Attraction;
