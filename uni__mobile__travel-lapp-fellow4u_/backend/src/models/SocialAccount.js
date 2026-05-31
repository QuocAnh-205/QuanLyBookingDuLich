const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const SocialAccount = sequelize.define('SocialAccount', {
  social_id: {
    type: DataTypes.STRING(255),
    primaryKey: true,
  },
  user_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  provider: {
    type: DataTypes.ENUM('FB', 'Kakao', 'Line'),
    allowNull: false,
  },
}, {
  tableName: 'social_accounts',
  timestamps: true,
  createdAt: 'linked_at',
  updatedAt: false,
});

module.exports = SocialAccount;
