const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const SecurityLog = sequelize.define('SecurityLog', {
  log_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  user_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'users',
      key: 'user_id',
    },
  },
  action_type: {
    type: DataTypes.STRING(100),
    allowNull: false,
  },
  ip_address: {
    type: DataTypes.STRING(45),
    allowNull: true,
  },
  device_info: {
    type: DataTypes.TEXT,
    allowNull: true,
  },
}, {
  tableName: 'security_logs',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: false,
});

module.exports = SecurityLog;
