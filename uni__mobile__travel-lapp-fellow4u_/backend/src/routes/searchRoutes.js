const express = require('express');
const router = express.Router();
const searchController = require('../controllers/searchController');
const { protect, optionalAuth } = require('../middleware/authMiddleware');

// Global search (supports optional authentication to log history)
router.get('/', optionalAuth, searchController.globalSearch);

// Trending/Popular searches
router.get('/popular', searchController.getPopularSearches);

// User specific search history
router.get('/history', protect, searchController.getUserSearchHistory);

module.exports = router;
