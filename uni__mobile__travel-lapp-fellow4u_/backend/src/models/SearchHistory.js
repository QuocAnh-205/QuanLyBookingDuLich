const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const SearchHistory = sequelize.define('SearchHistory', {
  log_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  user_id: {
    type: DataTypes.INTEGER,
    allowNull: true
  },
  keyword: {
    type: DataTypes.STRING(255)
  },
  filters_applied: {
    type: DataTypes.JSONB
  },
  search_at: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW
  }
}, {
  tableName: 'search_history',
  timestamps: false
});

module.exports = SearchHistory;
