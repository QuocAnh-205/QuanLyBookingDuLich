const { AppBanner, Collection, Tour, GuideProfile, Location, User } = require('../models');

exports.getBanners = async (req, res) => {
  try {
    const { page_type } = req.query;
    const where = { is_active: true };
    if (page_type) where.page_type = page_type;

    const banners = await AppBanner.findAll({ where });
    res.json({ success: true, data: banners });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Could not fetch banners' });
  }
};

exports.getCollections = async (req, res) => {
  try {
    const { item_type } = req.query;
    const where = { is_public: true };
    if (item_type) where.item_type = item_type;

    const collections = await Collection.findAll({ where });
    res.json({ success: true, data: collections });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Could not fetch collections' });
  }
};

exports.getCollectionDetails = async (req, res) => {
  try {
    const { slug } = req.params;
    const collection = await Collection.findOne({
      where: { slug, is_public: true },
      include: [
        {
          model: Tour,
          as: 'Tours',
          include: [{ model: Location }]
        },
        {
          model: GuideProfile,
          as: 'Guides',
          include: [
            { model: User },
            { model: Location, as: 'BaseLocation' }
          ]
        }
      ]
    });

    if (!collection) {
      return res.status(404).json({ success: false, message: 'Collection not found' });
    }

    res.json({ success: true, data: collection });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Could not fetch collection details' });
  }
};
