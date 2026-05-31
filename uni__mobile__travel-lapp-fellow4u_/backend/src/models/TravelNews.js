const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const TravelNews = sequelize.define('TravelNews', {
  news_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  title: {
    type: DataTypes.STRING(255),
    allowNull: false,
  },
  content: {
    type: DataTypes.TEXT,
  },
  metadata: {
    type: DataTypes.JSONB,
  },
  image_url: {
    type: DataTypes.TEXT,
  },
  is_published: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
  },
  published_at: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
  },
}, {
  tableName: 'travel_news',
  timestamps: false,
});

module.exports = TravelNews;
