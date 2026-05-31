const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const ChatRoom = sequelize.define('ChatRoom', {
  room_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  booking_id: {
    type: DataTypes.INTEGER,
    allowNull: true,
    unique: true,
    references: {
      model: 'bookings',
      key: 'booking_id',
    },
  },
  participant_one_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'users',
      key: 'user_id',
    },
  },
  participant_two_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'users',
      key: 'user_id',
    },
  },
  last_message_preview: {
    type: DataTypes.TEXT,
    allowNull: true,
  },
  last_message_at: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
  },
  created_at: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
  },
  updated_at: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
  },
}, {
  tableName: 'chat_rooms',
  timestamps: false, // Managed manually or by PostgreSQL triggers
});

module.exports = ChatRoom;
