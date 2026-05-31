const { Notification } = require('../models');

// @desc    Get all notifications for current user
// @route   GET /api/notifications
// @access  Private
const getNotifications = async (req, res) => {
  try {
    const userId = req.user.user_id;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const offset = (page - 1) * limit;

    const { count, rows } = await Notification.findAndCountAll({
      where: { user_id: userId },
      order: [['created_at', 'DESC']],
      limit,
      offset
    });

    res.json({
      success: true,
      data: rows,
      pagination: {
        totalItems: count,
        totalPages: Math.ceil(count / limit),
        currentPage: page
      }
    });
  } catch (error) {
    console.error('Get Notifications Error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Mark a notification as read
// @route   PUT /api/notifications/:id/read
// @access  Private
const markAsRead = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.user_id;

    const notification = await Notification.findOne({
      where: { notif_id: id, user_id: userId }
    });

    if (!notification) {
      return res.status(404).json({ success: false, message: 'Notification not found' });
    }

    await notification.update({
      is_read: true,
      read_at: new Date()
    });

    res.json({ success: true, message: 'Notification marked as read' });
  } catch (error) {
    console.error('Mark As Read Error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Mark all notifications as read
// @route   PUT /api/notifications/read-all
// @access  Private
const markAllAsRead = async (req, res) => {
  try {
    const userId = req.user.user_id;

    await Notification.update(
      { is_read: true, read_at: new Date() },
      { where: { user_id: userId, is_read: false } }
    );

    res.json({ success: true, message: 'All notifications marked as read' });
  } catch (error) {
    console.error('Mark All As Read Error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Get unread notification count
// @route   GET /api/notifications/unread-count
// @access  Private
const getUnreadCount = async (req, res) => {
  try {
    const userId = req.user.user_id;

    const count = await Notification.count({
      where: { user_id: userId, is_read: false }
    });

    res.json({ success: true, unread_count: count });
  } catch (error) {
    console.error('Get Unread Count Error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Delete a notification
// @route   DELETE /api/notifications/:id
// @access  Private
const deleteNotification = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.user_id;

    const notification = await Notification.findOne({
      where: { notif_id: id, user_id: userId }
    });

    if (!notification) {
      return res.status(404).json({ success: false, message: 'Notification not found' });
    }

    await notification.destroy();

    res.json({ success: true, message: 'Notification deleted' });
  } catch (error) {
    console.error('Delete Notification Error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Get notification action (mark as read & get target route)
// @route   GET /api/notifications/:id/action
// @access  Private
const getNotificationAction = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.user_id;

    const notification = await Notification.findOne({
      where: { notif_id: id, user_id: userId }
    });

    if (!notification) {
      return res.status(404).json({ success: false, message: 'Notification not found' });
    }

    // Mark as read if not already read
    if (!notification.is_read) {
      await notification.update({
        is_read: true,
        read_at: new Date()
      });
    }

    let action_route = null;
    switch (notification.related_entity_type) {
      case 'booking':
        action_route = '/booking/details';
        break;
      case 'chat':
        action_route = '/chat/room';
        break;
      case 'review':
        action_route = '/review/write';
        break;
      case 'promotion':
        action_route = '/promotion/details';
        break;
      case 'service':
        action_route = '/service/details';
        break;
      default:
        action_route = '/'; // Default fallback
    }

    res.json({
      success: true,
      data: {
        notif_id: notification.notif_id,
        related_entity_type: notification.related_entity_type,
        related_entity_id: notification.related_entity_id,
        action_route: action_route,
        extra_data: notification.extra_data
      }
    });
  } catch (error) {
    console.error('Get Notification Action Error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};

module.exports = {
  getNotifications,
  markAsRead,
  markAllAsRead,
  getUnreadCount,
  deleteNotification,
  getNotificationAction
};
