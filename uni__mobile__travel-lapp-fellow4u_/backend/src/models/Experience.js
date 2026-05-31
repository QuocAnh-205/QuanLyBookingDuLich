const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Experience = sequelize.define('Experience', {
  exp_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  guide_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
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
  duration_hours: {
    type: DataTypes.FLOAT,
    defaultValue: 1.0,
    validate: {
      min: 0.1,
    },
  },
  thumbnail_url: {
    type: DataTypes.TEXT,
  },
}, {
  tableName: 'experiences',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: false,
});

module.exports = Experience;
