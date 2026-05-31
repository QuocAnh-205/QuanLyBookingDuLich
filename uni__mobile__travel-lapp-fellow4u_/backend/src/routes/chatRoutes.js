const express = require('express');
const router = express.Router();
const chatController = require('../controllers/chatController');
const { protect } = require('../middleware/authMiddleware');

// All chat routes are protected
router.use(protect);

router.get('/', chatController.getChatRooms);
router.post('/init', chatController.getOrCreateRoom);

router.get('/:roomId', chatController.getChatMessages);
router.post('/:roomId/messages', chatController.sendMessage);
router.put('/:roomId/read', chatController.markAsRead);

module.exports = router;
