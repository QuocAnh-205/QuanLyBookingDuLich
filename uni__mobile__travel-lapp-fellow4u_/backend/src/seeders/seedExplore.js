const { sequelize, Location, Tour, GuideProfile, Experience, TravelNews, User, Country } = require('../models');

const seed = async () => {
  try {
    await sequelize.authenticate();
    console.log('Connection established for seeding.');

    // Sync models to ensure tables exist
    await sequelize.sync();
    console.log('Database synced.');

    // 1. Ensure a country exists
    let country = await Country.findOne({ where: { country_code: 'VN' } });
    if (!country) {
      country = await Country.create({ country_name: 'Vietnam', country_code: 'VN' });
    }

    // 2. Create Locations
    const locations = await Location.bulkCreate([
      { country_id: country.country_id, city_name: 'Da Nang', is_popular: true, description: 'City of bridges' },
      { country_id: country.country_id, city_name: 'Hoi An', is_popular: true, description: 'Ancient town' },
      { country_id: country.country_id, city_name: 'Ho Chi Minh', is_popular: true, description: 'Economic hub' },
    ], { returning: true });

    // 3. Create a Guide (User + Profile)
    let guideUser = await User.findOne({ where: { email: 'guide@example.com' } });
    if (!guideUser) {
      guideUser = await User.create({
        first_name: 'John',
        last_name: 'Doe',
        email: 'guide@example.com',
        password_hash: 'hashed_password', // In real case, use bcrypt
        role_type: 'Guide',
        country_id: country.country_id,
      });
    }

    await GuideProfile.findOrCreate({
      where: { guide_id: guideUser.user_id },
      defaults: {
        bio: 'Experienced local guide in Da Nang.',
        base_location_id: locations[0].location_id,
        rating_avg: 4.8,
        total_reviews: 120,
        is_verified: true,
      }
    });

    // 4. Create Tours
    await Tour.bulkCreate([
      {
        title: 'Da Nang City Tour',
        location_id: locations[0].location_id,
        price: 50.00,
        duration_days: 1,
        is_featured: true,
        description: 'Explore the best of Da Nang in one day.'
      },
      {
        title: 'Hoi An Ancient Town Walk',
        location_id: locations[1].location_id,
        price: 30.00,
        duration_days: 1,
        is_featured: true,
        description: 'A peaceful walk through Hoi An.'
      }
    ]);

    // 5. Create Experiences
    await Experience.create({
      guide_id: guideUser.user_id,
      title: 'Night Street Food Tour',
      location_id: locations[0].location_id,
      price: 25.00,
      duration_hours: 3.0,
    });

    // 6. Create Travel News
    await TravelNews.create({
      title: 'Top 10 things to do in Da Nang',
      content: 'Da Nang is a beautiful city with many attractions...',
      metadata: { tags: ['Da Nang', 'Travel'], read_time: '5 min' },
    });

    console.log('✅ Seeding completed successfully.');
    process.exit();
  } catch (error) {
    console.error('❌ Seeding failed:', error);
    process.exit(1);
  }
};

seed();
