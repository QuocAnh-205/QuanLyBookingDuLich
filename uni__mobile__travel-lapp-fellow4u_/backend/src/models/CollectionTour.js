const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const CollectionTour = sequelize.define('CollectionTour', {
  collection_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
  },
  tour_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
  },
  sort_order: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  }
}, {
  tableName: 'collection_tours',
  timestamps: false
});

module.exports = CollectionTour;
