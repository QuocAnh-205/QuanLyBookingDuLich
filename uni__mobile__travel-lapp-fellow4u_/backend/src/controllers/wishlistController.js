const { Wishlist, Tour, Experience } = require('../models');

exports.toggleWishlist = async (req, res) => {
  try {
    const { tour_id, exp_id } = req.body;
    const user_id = req.user.user_id;

    if (!tour_id && !exp_id) {
      return res.status(400).json({ success: false, message: 'ID is required' });
    }

    const where = { user_id };
    if (tour_id) where.tour_id = tour_id;
    if (exp_id) where.exp_id = exp_id;

    const existing = await Wishlist.findOne({ where });

    if (existing) {
      await existing.destroy();
      return res.json({ success: true, message: 'Removed from wishlist', action: 'removed' });
    } else {
      await Wishlist.create({ user_id, tour_id, exp_id });
      return res.json({ success: true, message: 'Added to wishlist', action: 'added' });
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, message: 'Operation failed' });
  }
};

exports.getWishlist = async (req, res) => {
  try {
    const user_id = req.user.user_id;
    const wishlist = await Wishlist.findAll({
      where: { user_id },
      include: [
        { model: Tour },
        { model: Experience }
      ]
    });
    res.json({ success: true, data: wishlist });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Could not fetch wishlist' });
  }
};
