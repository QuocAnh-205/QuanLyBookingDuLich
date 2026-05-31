const { DataTypes, Op } = require('sequelize');
const sequelize = require('../config/database');

const Wishlist = sequelize.define('Wishlist', {
  wish_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  user_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  tour_id: {
    type: DataTypes.INTEGER,
  },
  exp_id: {
    type: DataTypes.INTEGER,
  },
}, {
  tableName: 'wishlist',
  timestamps: true,
  createdAt: 'added_at',
  updatedAt: false,
  indexes: [
    {
      unique: true,
      fields: ['user_id', 'tour_id'],
      where: {
        tour_id: { [Op.ne]: null }
      }
    },
    {
      unique: true,
      fields: ['user_id', 'exp_id'],
      where: {
        exp_id: { [Op.ne]: null }
      }
    }
  ],
  validate: {
    atLeastOne() {
      if (!this.tour_id && !this.exp_id) {
        throw new Error('Wishlist item must have either a tour_id or an exp_id');
      }
    }
  }
});

module.exports = Wishlist;
