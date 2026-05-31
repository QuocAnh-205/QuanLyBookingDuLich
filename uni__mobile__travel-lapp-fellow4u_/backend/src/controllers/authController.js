const { User, Country } = require('../models');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const register = async (req, res) => {
  try {
    const { first_name, last_name, email, password, role_type, country_id } = req.body;

    // Check if user exists
    const existingUser = await User.findOne({ where: { email } });
    if (existingUser) {
      return res.status(400).json({ message: 'Email already registered' });
    }

    // Hash password
    const salt = await bcrypt.genSalt(10);
    const password_hash = await bcrypt.hash(password, salt);

    // Create user
    const newUser = await User.create({
      first_name,
      last_name,
      email,
      password_hash,
      role: role_type || 'Traveler',
      country_id,
    });

    res.status(201).json({
      message: 'User registered successfully',
      user: {
        user_id: newUser.user_id,
        email: newUser.email,
        role: newUser.role,
      },
    });
  } catch (error) {
    console.error('Registration Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};

const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Find user
    const user = await User.findOne({ where: { email } });
    if (!user) {
      return res.status(401).json({ message: 'Invalid email or password' });
    }

    // Check password
    const isMatch = await bcrypt.compare(password, user.password_hash);
    if (!isMatch) {
      return res.status(401).json({ message: 'Invalid email or password' });
    }

    // Generate JWT
    const token = jwt.sign(
      { user_id: user.user_id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: '24h' }
    );

    res.json({
      message: 'Login successful',
      token,
      user: {
        user_id: user.user_id,
        email: user.email,
        role: user.role,
      },
    });
  } catch (error) {
    console.error('Login Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};

module.exports = {
  register,
  login,
};
