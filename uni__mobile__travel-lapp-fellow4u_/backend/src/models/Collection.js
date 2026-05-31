const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Collection = sequelize.define('Collection', {
  collection_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  name: {
    type: DataTypes.STRING(100),
    allowNull: false
  },
  slug: {
    type: DataTypes.STRING(100),
    unique: true,
    allowNull: false
  },
  description: {
    type: DataTypes.TEXT
  },
  item_type: {
    type: DataTypes.ENUM('guide', 'tour'),
    allowNull: false
  },
  is_public: {
    type: DataTypes.BOOLEAN,
    defaultValue: true
  }
}, {
  tableName: 'collections',
  timestamps: false
});

module.exports = Collection;
