const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const UserJourney = sequelize.define('UserJourney', {
  journey_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  user_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'users',
      key: 'user_id',
    },
  },
  title: {
    type: DataTypes.STRING(255),
    allowNull: false,
  },
  location_name: {
    type: DataTypes.STRING(255),
    allowNull: true,
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: true,
  },
  likes_count: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
  },
  created_date: {
    type: DataTypes.DATEONLY,
    defaultValue: DataTypes.NOW,
  },
}, {
  tableName: 'user_journeys',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: 'updated_at',
});

module.exports = UserJourney;
