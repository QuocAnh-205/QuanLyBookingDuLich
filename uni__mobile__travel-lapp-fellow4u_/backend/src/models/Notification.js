const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const Notification = sequelize.define('Notification', {
    notif_id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true
    },
    user_id: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    category: {
      type: DataTypes.ENUM(
        'booking_update',
        'payment_status',
        'chat_arrival',
        'review_reminder',
        'system_alert',
        'promotion'
      ),
      allowNull: false
    },
    title: {
      type: DataTypes.STRING(255),
      allowNull: false
    },
    message: {
      type: DataTypes.TEXT,
      allowNull: false
    },
    related_entity_type: {
      type: DataTypes.STRING(50)
    },
    related_entity_id: {
      type: DataTypes.INTEGER
    },
    is_read: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    },
    read_at: {
      type: DataTypes.DATE
    },
    extra_data: {
      type: DataTypes.JSONB
    },
    created_at: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW
    }
  }, {
    tableName: 'notifications',
    timestamps: false, // Using DB defaults
    underscored: true
  });

  return Notification;
};
