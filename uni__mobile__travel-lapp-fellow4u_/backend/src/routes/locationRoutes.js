const express = require('express');
const router = express.Router();
const locationController = require('../controllers/locationController');

router.get('/:id', locationController.getLocationDetail);

module.exports = router;
