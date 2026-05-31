const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const UserSetting = sequelize.define('UserSetting', {
  user_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    references: {
      model: 'users',
      key: 'user_id',
    },
  },
  preferred_language: {
    type: DataTypes.STRING(10),
    defaultValue: 'en',
  },
  preferred_currency: {
    type: DataTypes.CHAR(3),
    defaultValue: 'USD',
  },
  enable_push_notifications: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
  },
  enable_email_notifications: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
  },
  theme_mode: {
    type: DataTypes.STRING(20),
    defaultValue: 'light',
  },
}, {
  tableName: 'user_settings',
  timestamps: true,
  updatedAt: 'updated_at',
  createdAt: false,
});

module.exports = UserSetting;
