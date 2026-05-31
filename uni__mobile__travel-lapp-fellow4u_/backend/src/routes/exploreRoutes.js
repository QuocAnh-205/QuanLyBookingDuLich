const express = require('express');
const router = express.Router();
const exploreController = require('../controllers/exploreController');
const { protect, authorize } = require('../middleware/authMiddleware');

// Public routes
router.get('/overview', exploreController.getExploreData);
router.get('/locations', exploreController.getLocations);
router.get('/tours', exploreController.getTours);
router.get('/guides', exploreController.getGuides);
router.get('/news/:id', exploreController.getNewsDetails);

// Protected routes (require login)
router.post('/wishlist', protect, exploreController.toggleWishlist);
router.get('/wishlist', protect, exploreController.getWishlist);
router.put('/profile', protect, authorize('Guide'), exploreController.updateGuideProfile);

module.exports = router;
