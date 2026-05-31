const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const PasswordReset = sequelize.define('PasswordReset', {
  email: {
    type: DataTypes.STRING(100),
    primaryKey: true,
  },
  token: {
    type: DataTypes.STRING(255),
    primaryKey: true,
  },
  expires_at: {
    type: DataTypes.DATE,
    allowNull: false,
  },
}, {
  tableName: 'password_resets',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: false,
});

module.exports = PasswordReset;
