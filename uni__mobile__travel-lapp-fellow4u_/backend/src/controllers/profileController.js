const { User, UserPhoto, UserJourney, UserSetting, SecurityLog, JourneyMedia } = require('../models');
const bcrypt = require('bcryptjs');

// @desc    Get user profile
// @route   GET /api/profile
// @access  Private
const getProfile = async (req, res) => {
  try {
    const user = await User.findByPk(req.user.user_id, {
      attributes: { exclude: ['password_hash'] },
      include: [
        { model: UserSetting, as: 'Settings' },
        { model: UserPhoto, as: 'Photos', limit: 10 },
        { model: UserJourney, as: 'Journeys', limit: 5 }
      ]
    });

    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    res.json({ success: true, data: user });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Update user profile
// @route   PUT /api/profile
// @access  Private
const updateProfile = async (req, res) => {
  try {
    const { first_name, last_name, bio, avatar_url, cover_url, date_of_birth, gender } = req.body;
    
    const user = await User.findByPk(req.user.user_id);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    await user.update({
      first_name: first_name || user.first_name,
      last_name: last_name || user.last_name,
      bio,
      avatar_url,
      cover_url,
      date_of_birth,
      gender
    });

    // Log security action
    await SecurityLog.create({
      user_id: req.user.user_id,
      action_type: 'PROFILE_UPDATE',
      ip_address: req.ip,
      device_info: req.headers['user-agent']
    });

    res.json({ success: true, data: user });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Change user password
// @route   PUT /api/profile/change-password
// @access  Private
const changePassword = async (req, res) => {
  try {
    const { current_password, new_password } = req.body;
    
    const user = await User.findByPk(req.user.user_id);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    // Verify current password
    const isMatch = await bcrypt.compare(current_password, user.password_hash);
    if (!isMatch) {
      return res.status(401).json({ success: false, message: 'Invalid current password' });
    }

    // Hash new password
    const salt = await bcrypt.genSalt(10);
    user.password_hash = await bcrypt.hash(new_password, salt);
    await user.save();

    // Log security action
    await SecurityLog.create({
      user_id: req.user.user_id,
      action_type: 'PASSWORD_CHANGE',
      ip_address: req.ip,
      device_info: req.headers['user-agent']
    });

    res.json({ success: true, message: 'Password changed successfully' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Get user settings
// @route   GET /api/profile/settings
// @access  Private
const getSettings = async (req, res) => {
  try {
    let settings = await UserSetting.findOne({ where: { user_id: req.user.user_id } });
    
    if (!settings) {
      // Create default settings if not exists
      settings = await UserSetting.create({ user_id: req.user.user_id });
    }

    res.json({ success: true, data: settings });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Update user settings
// @route   PUT /api/profile/settings
// @access  Private
const updateSettings = async (req, res) => {
  try {
    const settings = await UserSetting.findOne({ where: { user_id: req.user.user_id } });
    if (!settings) {
      return res.status(404).json({ success: false, message: 'Settings not found' });
    }

    await settings.update(req.body);
    res.json({ success: true, data: settings });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Get user journeys
// @route   GET /api/profile/journeys
// @access  Private
const getJourneys = async (req, res) => {
  try {
    const journeys = await UserJourney.findAll({
      where: { user_id: req.user.user_id },
      include: [{ model: UserPhoto, as: 'Media', through: { attributes: [] } }],
      order: [['created_at', 'DESC']]
    });
    res.json({ success: true, data: journeys });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Create user journey
// @route   POST /api/profile/journeys
// @access  Private
const createJourney = async (req, res) => {
  try {
    const { title, location_name, description, photo_ids } = req.body;
    
    const journey = await UserJourney.create({
      user_id: req.user.user_id,
      title,
      location_name,
      description
    });

    if (photo_ids && photo_ids.length > 0) {
      await journey.addMedia(photo_ids);
    }

    const fullJourney = await UserJourney.findByPk(journey.journey_id, {
      include: [{ model: UserPhoto, as: 'Media', through: { attributes: [] } }]
    });

    res.status(201).json({ success: true, data: fullJourney });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Upload user photo record
// @route   POST /api/profile/photos
// @access  Private
const uploadPhoto = async (req, res) => {
  try {
    const { image_url, width, height, is_public } = req.body;
    const photo = await UserPhoto.create({
      user_id: req.user.user_id,
      image_url,
      width,
      height,
      is_public
    });
    res.status(201).json({ success: true, data: photo });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Delete user photo
// @route   DELETE /api/profile/photos/:id
// @access  Private
const deletePhoto = async (req, res) => {
  try {
    const photo = await UserPhoto.findOne({
      where: { photo_id: req.params.id, user_id: req.user.user_id }
    });
    
    if (!photo) {
      return res.status(404).json({ success: false, message: 'Photo not found or not authorized' });
    }

    await photo.destroy();
    res.json({ success: true, message: 'Photo deleted successfully' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Delete user journey
// @route   DELETE /api/profile/journeys/:id
// @access  Private
const deleteJourney = async (req, res) => {
  try {
    const journey = await UserJourney.findOne({
      where: { journey_id: req.params.id, user_id: req.user.user_id }
    });
    
    if (!journey) {
      return res.status(404).json({ success: false, message: 'Journey not found or not authorized' });
    }

    await journey.destroy();
    res.json({ success: true, message: 'Journey deleted successfully' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Get public profile of another user
// @route   GET /api/profile/:id
// @access  Private
const getPublicProfile = async (req, res) => {
  try {
    const user = await User.findByPk(req.params.id, {
      attributes: ['user_id', 'first_name', 'last_name', 'avatar_url', 'cover_url', 'bio', 'role'],
      include: [
        { 
          model: UserPhoto, 
          as: 'Photos', 
          where: { is_public: true },
          required: false,
          limit: 12 
        },
        { 
          model: UserJourney, 
          as: 'Journeys', 
          limit: 5,
          include: [{ model: UserPhoto, as: 'Media', through: { attributes: [] } }]
        }
      ]
    });

    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    res.json({ success: true, data: user });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Get security logs
// @route   GET /api/profile/security-logs
// @access  Private
const getSecurityLogs = async (req, res) => {
  try {
    const logs = await SecurityLog.findAll({
      where: { user_id: req.user.user_id },
      order: [['created_at', 'DESC']],
      limit: 20
    });
    res.json({ success: true, data: logs });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

module.exports = {
  getProfile,
  updateProfile,
  changePassword,
  getSettings,
  updateSettings,
  getJourneys,
  createJourney,
  deleteJourney,
  uploadPhoto,
  deletePhoto,
  getPublicProfile,
  getSecurityLogs
};
