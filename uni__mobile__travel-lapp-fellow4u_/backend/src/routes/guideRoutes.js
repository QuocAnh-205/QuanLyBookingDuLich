const express = require('express');
const router = express.Router();
const guideController = require('../controllers/guideController');

router.get('/:id', guideController.getGuideDetail);

module.exports = router;
