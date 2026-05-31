const express = require('express');
const router = express.Router();
const serviceController = require('../controllers/serviceController');

router.get('/tours/:id', serviceController.getTourDetail);
router.get('/experiences/:id', serviceController.getExperienceDetail);

module.exports = router;
