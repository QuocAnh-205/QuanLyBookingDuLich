const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const PortfolioMedia = sequelize.define('PortfolioMedia', {
  media_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  guide_id: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  media_url: {
    type: DataTypes.TEXT,
    allowNull: false
  },
  media_type: {
    type: DataTypes.ENUM('image', 'video'),
    defaultValue: 'image'
  },
  title: {
    type: DataTypes.STRING(100)
  },
  display_order: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  }
}, {
  tableName: 'guide_portfolio_media',
  timestamps: false
});

module.exports = PortfolioMedia;
