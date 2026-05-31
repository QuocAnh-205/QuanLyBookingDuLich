const { Location, Tour, GuideProfile, Experience, TravelNews, Wishlist, User } = require('../models');
const { Op } = require('sequelize');

exports.getExploreData = async (req, res) => {
  try {
    const popularLocations = await Location.findAll({
      where: { is_popular: true },
      limit: 5,
    });

    const featuredTours = await Tour.findAll({
      where: { is_featured: true },
      include: [Location],
      limit: 5,
    });

    const bestGuides = await GuideProfile.findAll({
      include: [{ model: User, attributes: ['first_name', 'last_name', 'avatar_url'] }, { model: Location, as: 'BaseLocation' }],
      order: [['rating_avg', 'DESC']],
      limit: 5,
    });

    const topExperiences = await Experience.findAll({
      include: [Location, { model: GuideProfile, include: [User] }],
      limit: 5,
    });

    const travelNews = await TravelNews.findAll({
      where: { is_published: true },
      limit: 5,
      order: [['published_at', 'DESC']],
    });

    res.json({
      locations: popularLocations,
      tours: featuredTours,
      guides: bestGuides,
      experiences: topExperiences,
      news: travelNews,
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getLocations = async (req, res) => {
  try {
    const locations = await Location.findAll();
    res.json(locations);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getTours = async (req, res) => {
  try {
    const { location_id, min_price, max_price, search, is_featured } = req.query;
    const where = {};
    if (location_id) where.location_id = location_id;
    if (is_featured) where.is_featured = is_featured === 'true';
    if (search) {
      where.title = { [Op.iLike]: `%${search}%` };
    }
    if (min_price || max_price) {
      where.price = {};
      if (min_price) where.price[Op.gte] = min_price;
      if (max_price) where.price[Op.lte] = max_price;
    }

    const tours = await Tour.findAll({ 
      where, 
      include: [{ model: Location, attributes: ['city_name'] }],
      order: [['created_at', 'DESC']]
    });
    res.json(tours);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getGuides = async (req, res) => {
  try {
    const { base_location_id, search } = req.query;
    const where = {};
    if (base_location_id) where.base_location_id = base_location_id;
    
    const userInclude = { model: User, attributes: ['first_name', 'last_name', 'avatar_url'] };
    if (search) {
      userInclude.where = {
        [Op.or]: [
          { first_name: { [Op.iLike]: `%${search}%` } },
          { last_name: { [Op.iLike]: `%${search}%` } },
        ],
      };
    }

    const guides = await GuideProfile.findAll({
      where,
      include: [
        userInclude, 
        { model: Location, as: 'BaseLocation', attributes: ['city_name'] }
      ],
      order: [['rating_avg', 'DESC']],
    });
    res.json(guides);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getNewsDetails = async (req, res) => {
  try {
    const { id } = req.params;
    const news = await TravelNews.findByPk(id);
    if (!news) return res.status(404).json({ message: 'News not found' });
    res.json(news);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.updateGuideProfile = async (req, res) => {
  try {
    const { bio, base_location_id } = req.body;
    const guide_id = req.user.user_id;

    let profile = await GuideProfile.findByPk(guide_id);
    if (!profile) {
      profile = await GuideProfile.create({ guide_id, bio, base_location_id });
    } else {
      await profile.update({ bio, base_location_id });
    }

    res.json({ message: 'Profile updated successfully', profile });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.toggleWishlist = async (req, res) => {
  try {
    const { tour_id, exp_id } = req.body;
    const user_id = req.user.user_id;

    const existing = await Wishlist.findOne({
      where: {
        user_id,
        [Op.or]: [
          tour_id ? { tour_id } : null,
          exp_id ? { exp_id } : null,
        ].filter(Boolean),
      },
    });

    if (existing) {
      await existing.destroy();
      return res.json({ message: 'Removed from wishlist', action: 'removed' });
    } else {
      const newItem = await Wishlist.create({ user_id, tour_id, exp_id });
      return res.status(201).json({ message: 'Added to wishlist', item: newItem, action: 'added' });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getWishlist = async (req, res) => {
  try {
    const user_id = req.user.user_id;
    const wishlist = await Wishlist.findAll({
      where: { user_id },
      include: [
        { model: Tour, include: [Location] },
        { model: Experience, include: [Location] },
      ],
    });
    res.json(wishlist);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
