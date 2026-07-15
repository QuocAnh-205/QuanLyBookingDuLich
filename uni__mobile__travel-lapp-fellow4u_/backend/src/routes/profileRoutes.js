const express = require('express');
const router = express.Router();
const { 
  getProfile, 
  updateProfile, 
  changePassword,
  getSettings, 
  updateSettings,
  getJourneys,
  createJourney,
  deleteJourney,
  getPhotos,
  uploadPhoto,
  deletePhoto,
  getPublicProfile,
  getSecurityLogs
} = require('../controllers/profileController');
const { protect } = require('../middleware/authMiddleware');

router.use(protect);

router.route('/')
  .get(getProfile)
  .put(updateProfile);

router.put('/change-password', changePassword);

router.get('/security-logs', getSecurityLogs);

router.route('/settings')
  .get(getSettings)
  .put(updateSettings);

router.route('/journeys')
  .get(getJourneys)
  .post(createJourney);

router.delete('/journeys/:id', deleteJourney);

router.route('/photos')
  .get(getPhotos)
  .post(uploadPhoto);

router.delete('/photos/:id', deletePhoto);

router.get('/:id', getPublicProfile);

module.exports = router;
