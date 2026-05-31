const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const AppBanner = sequelize.define('AppBanner', {
  banner_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  page_type: {
    type: DataTypes.ENUM('Guides_More', 'Tours_More'),
    allowNull: false
  },
  title_text: {
    type: DataTypes.STRING(255),
    allowNull: false
  },
  subtitle_text: {
    type: DataTypes.TEXT
  },
  image_url: {
    type: DataTypes.TEXT,
    allowNull: false
  },
  is_active: {
    type: DataTypes.BOOLEAN,
    defaultValue: true
  }
}, {
  tableName: 'app_banners',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: 'updated_at'
});

module.exports = AppBanner;
