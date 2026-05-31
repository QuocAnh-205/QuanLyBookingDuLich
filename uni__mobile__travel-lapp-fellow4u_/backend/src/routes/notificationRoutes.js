const express = require('express');
const router = express.Router();
const notificationController = require('../controllers/notificationController');
const { protect } = require('../middleware/authMiddleware');

// All notification routes are protected
router.use(protect);

router.get('/', notificationController.getNotifications);
router.get('/unread-count', notificationController.getUnreadCount);
router.put('/read-all', notificationController.markAllAsRead);
router.put('/:id/read', notificationController.markAsRead);
router.get('/:id/action', notificationController.getNotificationAction);
router.delete('/:id', notificationController.deleteNotification);

module.exports = router;
