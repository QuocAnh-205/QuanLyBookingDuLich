const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Message = sequelize.define('Message', {
  message_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  room_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'chat_rooms',
      key: 'room_id',
    },
  },
  sender_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'users',
      key: 'user_id',
    },
  },
  content: {
    type: DataTypes.TEXT,
    allowNull: false,
  },
  message_type: {
    type: DataTypes.ENUM('text', 'image', 'location'),
    defaultValue: 'text',
  },
  is_read: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
  },
  read_at: {
    type: DataTypes.DATE,
    allowNull: true,
  },
  created_at: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
  },
}, {
  tableName: 'messages',
  timestamps: false,
});

module.exports = Message;
