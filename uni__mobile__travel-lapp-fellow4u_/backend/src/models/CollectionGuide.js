const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const CollectionGuide = sequelize.define('CollectionGuide', {
  collection_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
  },
  guide_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
  },
  sort_order: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  }
}, {
  tableName: 'collection_guides',
  timestamps: false
});

module.exports = CollectionGuide;
