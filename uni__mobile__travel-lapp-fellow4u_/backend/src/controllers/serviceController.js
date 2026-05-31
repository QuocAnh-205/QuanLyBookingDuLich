const { Tour, Experience, Location, GuideProfile, User, Review, TourProvider, TourImage, TourSchedule, TourAgePricing, Attraction } = require('../models');

exports.getTourDetail = async (req, res) => {
  try {
    const { id } = req.params;
    const tour = await Tour.findByPk(id, {
      include: [
        { model: Location },
        { model: TourProvider, as: 'Provider' },
        { model: TourImage, as: 'Images' },
        { 
          model: TourSchedule, 
          as: 'Schedules',
          include: [{ model: Attraction }]
        },
        { model: TourAgePricing, as: 'AgePricings' }
      ]
    });

    if (!tour) {
      return res.status(404).json({ message: 'Tour not found' });
    }

    // Deduplicate associations to prevent duplicates from multiple joins
    const result = tour.toJSON();
    
    if (result.Schedules) {
      const seen = new Set();
      result.Schedules = result.Schedules.filter(s => {
        const key = `${s.day_number}-${s.start_time}-${s.activity_title}`;
        if (seen.has(key)) return false;
        seen.add(key);
        return true;
      });
    }

    if (result.Images) {
      const seen = new Set();
      result.Images = result.Images.filter(img => {
        if (seen.has(img.image_url)) return false;
        seen.add(img.image_url);
        return true;
      });
    }

    if (result.AgePricings) {
      const seen = new Set();
      result.AgePricings = result.AgePricings.filter(p => {
        const key = `${p.age_group_label}-${p.price}`;
        if (seen.has(key)) return false;
        seen.add(key);
        return true;
      });
    }

    res.status(200).json(result);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching tour detail', error: error.message });
  }
};

exports.getExperienceDetail = async (req, res) => {
  try {
    const { id } = req.params;
    const experience = await Experience.findByPk(id, {
      include: [
        { model: Location },
        { 
          model: GuideProfile,
          include: [{ model: User, attributes: ['first_name', 'last_name', 'avatar_url'] }]
        }
      ]
    });

    if (!experience) {
      return res.status(404).json({ message: 'Experience not found' });
    }

    res.status(200).json(experience);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching experience detail', error: error.message });
  }
};
