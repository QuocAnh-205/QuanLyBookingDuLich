const express = require('express');
const router = express.Router();
const categoryController = require('../controllers/categoryController');

// Banner routes
router.get('/banners', categoryController.getBanners);

// Collection routes
router.get('/collections', categoryController.getCollections);
router.get('/collections/:slug', categoryController.getCollectionDetails);

module.exports = router;
