const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const UserPhoto = sequelize.define('UserPhoto', {
  photo_id: {
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
  image_url: {
    type: DataTypes.TEXT,
    allowNull: false,
  },
  storage_provider: {
    type: DataTypes.STRING(50),
    defaultValue: 'local',
  },
  width: {
    type: DataTypes.INTEGER,
    allowNull: true,
  },
  height: {
    type: DataTypes.INTEGER,
    allowNull: true,
  },
  is_public: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
  },
}, {
  tableName: 'user_photos',
  timestamps: true,
  createdAt: 'uploaded_at',
  updatedAt: false,
});

module.exports = UserPhoto;
