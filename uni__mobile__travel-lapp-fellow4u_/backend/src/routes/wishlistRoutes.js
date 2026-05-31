const express = require('express');
const router = express.Router();
const wishlistController = require('../controllers/wishlistController');
const { protect } = require('../middleware/authMiddleware');

router.use(protect);

router.post('/toggle', wishlistController.toggleWishlist);
router.get('/', wishlistController.getWishlist);

module.exports = router;
