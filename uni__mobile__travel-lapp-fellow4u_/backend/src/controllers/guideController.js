const { GuideProfile, User, Location, Language, GuidePricing, Review, PortfolioMedia } = require('../models');

exports.getGuideDetail = async (req, res) => {
  try {
    const { id } = req.params;
    const guide = await GuideProfile.findByPk(id, {
      include: [
        { 
          model: User, 
          attributes: ['first_name', 'last_name', 'avatar_url', 'bio', 'cover_url'] 
        },
        { model: Location, as: 'BaseLocation' },
        { model: Language, through: { attributes: [] } },
        { model: GuidePricing, as: 'Pricings' },
        { 
          model: Review, 
          as: 'Reviews',
          include: [{ model: User, as: 'Author', attributes: ['first_name', 'last_name', 'avatar_url'] }]
        },
        { model: PortfolioMedia, as: 'Portfolio' }
      ]
    });

    if (!guide) {
      return res.status(404).json({ message: 'Guide not found' });
    }

    // Deduplicate associations to prevent duplicates from multiple joins
    const result = guide.toJSON();
    
    if (result.Pricings) {
      const seen = new Set();
      result.Pricings = result.Pricings.filter(p => {
        const key = `${p.min_travelers}-${p.max_travelers}-${p.price_per_hour}`;
        if (seen.has(key)) return false;
        seen.add(key);
        return true;
      });
    }

    if (result.Reviews) {
      const seen = new Set();
      result.Reviews = result.Reviews.filter(r => {
        // Use author_id and comment to deduplicate actual duplicate records
        const key = `${r.author_id}-${r.comment}-${r.rating}`;
        if (seen.has(key)) return false;
        seen.add(key);
        return true;
      });
    }

    if (result.Portfolio) {
      const seen = new Set();
      result.Portfolio = result.Portfolio.filter(m => {
        if (seen.has(m.media_url)) return false;
        seen.add(m.media_url);
        return true;
      });
    }

    if (result.Attractions) {
      const seen = new Set();
      result.Attractions = result.Attractions.filter(a => {
        // Deduplicate by name and description
        const key = `${a.name}-${a.description}`;
        if (seen.has(key)) return false;
        seen.add(key);
        return true;
      });
    }

    res.status(200).json(result);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching guide detail', error: error.message });
  }
};
