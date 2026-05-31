const { Location, Attraction, Country, Tour, Experience } = require('../models');

exports.getLocationDetail = async (req, res) => {
  try {
    const { id } = req.params;
    const location = await Location.findByPk(id, {
      include: [
        { model: Country },
        { model: Attraction, as: 'Attractions' },
        { model: Tour, limit: 5 },
        { model: Experience, limit: 5 }
      ]
    });

    if (!location) {
      return res.status(404).json({ message: 'Location not found' });
    }

    // Deduplicate associations
    const result = location.toJSON();
    if (result.Attractions) {
      const seen = new Set();
      result.Attractions = result.Attractions.filter(a => {
        const key = `${a.name}-${a.description}`;
        if (seen.has(key)) return false;
        seen.add(key);
        return true;
      });
    }

    if (result.Tours) {
      const seen = new Set();
      result.Tours = result.Tours.filter(t => {
        if (seen.has(t.tour_id)) return false;
        seen.add(t.tour_id);
        return true;
      });
    }

    if (result.Experiences) {
      const seen = new Set();
      result.Experiences = result.Experiences.filter(e => {
        if (seen.has(e.exp_id)) return false;
        seen.add(e.exp_id);
        return true;
      });
    }

    res.status(200).json(result);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching location detail', error: error.message });
  }
};
