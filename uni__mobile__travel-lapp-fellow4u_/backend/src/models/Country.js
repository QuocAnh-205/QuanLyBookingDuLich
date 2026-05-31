const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Country = sequelize.define('Country', {
  country_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  country_name: {
    type: DataTypes.STRING(100),
    allowNull: false,
  },
  country_code: {
    type: DataTypes.STRING(10),
    allowNull: false,
    unique: true,
  },
  flag_url: {
    type: DataTypes.TEXT,
    allowNull: true,
  },
}, {
  tableName: 'countries',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: false, // Schema không có updated_at cho bảng này
});

module.exports = Country;
