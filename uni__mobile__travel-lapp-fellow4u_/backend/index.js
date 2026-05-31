const express = require('express');
const cors = require('cors');
require('dotenv').config();
const { sequelize } = require('./src/models');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.get('/', (req, res) => {
  res.json({ message: 'Welcome to Fellow4U API' });
});

app.use('/api/auth', require('./src/routes/authRoutes'));
app.use('/api/explore', require('./src/routes/exploreRoutes'));
app.use('/api/services', require('./src/routes/serviceRoutes'));
app.use('/api/guides', require('./src/routes/guideRoutes'));
app.use('/api/locations', require('./src/routes/locationRoutes'));
app.use('/api/search', require('./src/routes/searchRoutes'));
app.use('/api/categories', require('./src/routes/categoryRoutes'));
app.use('/api/wishlist', require('./src/routes/wishlistRoutes'));
app.use('/api/bookings', require('./src/routes/bookingRoutes'));
app.use('/api/chats', require('./src/routes/chatRoutes'));
app.use('/api/notifications', require('./src/routes/notificationRoutes'));
app.use('/api/profile', require('./src/routes/profileRoutes'));

// Database Connection & Server Start
const startServer = async () => {
  try {
    await sequelize.authenticate();
    console.log('✅ Connection to PostgreSQL has been established successfully.');
    
    app.listen(PORT, () => {
      console.log(`🚀 Server is running on http://localhost:${PORT}`);
    });
  } catch (error) {
    console.error('❌ Unable to connect to the database:', error);
  }
};

startServer();
