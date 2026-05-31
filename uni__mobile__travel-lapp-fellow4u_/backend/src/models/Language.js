const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Language = sequelize.define('Language', {
  lang_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  lang_name: {
    type: DataTypes.STRING(50),
    unique: true,
    allowNull: false
  },
  lang_code: {
    type: DataTypes.CHAR(2)
  }
}, {
  tableName: 'languages',
  timestamps: false
});

module.exports = Language;
