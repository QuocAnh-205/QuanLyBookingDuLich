const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const NotificationTemplate = sequelize.define('NotificationTemplate', {
    template_id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true
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
    template_key: {
      type: DataTypes.STRING(50),
      unique: true,
      allowNull: false
    },
    title_pattern: {
      type: DataTypes.TEXT,
      allowNull: false
    },
    body_pattern: {
      type: DataTypes.TEXT,
      allowNull: false
    },
    created_at: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW
    }
  }, {
    tableName: 'notification_templates',
    timestamps: false,
    underscored: true
  });

  return NotificationTemplate;
};
