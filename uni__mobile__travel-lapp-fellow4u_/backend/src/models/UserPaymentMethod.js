const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const UserPaymentMethod = sequelize.define('UserPaymentMethod', {
  method_id: {
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
  gateway_customer_id: {
    type: DataTypes.STRING(255),
    allowNull: true,
  },
  payment_token: {
    type: DataTypes.STRING(255),
    allowNull: false,
  },
  card_brand: {
    type: DataTypes.STRING(50),
    allowNull: true,
  },
  last_4: {
    type: DataTypes.CHAR(4),
    allowNull: true,
  },
  exp_month: {
    type: DataTypes.INTEGER,
    allowNull: true,
  },
  exp_year: {
    type: DataTypes.INTEGER,
    allowNull: true,
  },
  is_default: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
  },
}, {
  tableName: 'user_payment_methods',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: false,
});

module.exports = UserPaymentMethod;
