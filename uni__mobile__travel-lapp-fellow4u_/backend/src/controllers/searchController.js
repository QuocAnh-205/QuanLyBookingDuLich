const { Op } = require('sequelize');
const sequelize = require('../config/database');
const { Tour, GuideProfile, Location, User, SearchHistory } = require('../models');

exports.globalSearch = async (req, res) => {
  try {
    const { q, type, min_price, max_price, location_id } = req.query;
    const userId = req.user ? req.user.user_id : null;

    // Log search if keyword exists
    if (q) {
      await SearchHistory.create({
        user_id: userId,
        keyword: q,
        filters_applied: JSON.stringify(req.query)
      });
    }

    const results = {
      tours: [],
      guides: [],
      locations: []
    };

    const keywordFilter = q ? {
      [Op.or]: [
        { title: { [Op.iLike]: `%${q}%` } },
        { description: { [Op.iLike]: `%${q}%` } }
      ]
    } : {};

    const priceFilter = {};
    if (min_price) priceFilter[Op.gte] = min_price;
    if (max_price) priceFilter[Op.lte] = max_price;

    // 1. Search Tours
    if (!type || type === 'tour') {
      const tourQuery = {
        where: { ...keywordFilter },
        include: [{ model: Location }]
      };
      if (Object.keys(priceFilter).length > 0) {
        tourQuery.where.price = priceFilter;
      }
      if (location_id) tourQuery.where.location_id = location_id;
      
      results.tours = await Tour.findAll(tourQuery);
    }

    // 2. Search Guides
    if (!type || type === 'guide') {
      const guideQuery = {
        include: [
          { 
            model: User, 
            where: q ? {
              [Op.or]: [
                { first_name: { [Op.iLike]: `%${q}%` } },
                { last_name: { [Op.iLike]: `%${q}%` } }
              ]
            } : {} 
          },
          { model: Location, as: 'BaseLocation' }
        ]
      };
      if (location_id) guideQuery.where = { base_location_id: location_id };
      
      results.guides = await GuideProfile.findAll(guideQuery);
    }

    // 3. Search Locations
    if (!type || type === 'location') {
      results.locations = await Location.findAll({
        where: q ? { city_name: { [Op.iLike]: `%${q}%` } } : {}
      });
    }

    res.json({
      success: true,
      data: results
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, message: 'Search failed' });
  }
};

exports.getPopularSearches = async (req, res) => {
  try {
    const popular = await SearchHistory.findAll({
      attributes: ['keyword', [sequelize.fn('COUNT', sequelize.col('keyword')), 'search_count']],
      group: ['keyword'],
      order: [[sequelize.literal('search_count'), 'DESC']],
      limit: 10
    });
    res.json({ success: true, data: popular.map(p => p.get('keyword')) });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, message: 'Could not fetch popular searches' });
  }
};

exports.getUserSearchHistory = async (req, res) => {
  try {
    const history = await SearchHistory.findAll({
      where: { user_id: req.user.user_id },
      order: [['search_at', 'DESC']],
      limit: 20
    });
    res.json({ success: true, data: history });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, message: 'Could not fetch history' });
  }
};
