const { Sequelize } = require('sequelize');
require('dotenv').config();

// Validation for environment variables
const dbName = process.env.DB_NAME;
const dbUser = process.env.DB_USER;
const dbPass = process.env.DB_PASS;
const dbHost = process.env.DB_HOST || 'localhost';
const dbPort = process.env.DB_PORT || 5432;

if (!dbPass) {
  console.warn('⚠️  Warning: DB_PASS is not defined in environment variables. This may cause connection failures.');
}

const sequelize = new Sequelize(
  dbName,
  dbUser,
  dbPass,
  {
    host: dbHost,
    port: dbPort,
    dialect: 'postgres',
    logging: false,
    dialectOptions: (process.env.DB_SSL === 'true' || process.env.RENDER === 'true' || process.env.NODE_ENV === 'production') ? {
      ssl: {
        require: true,
        rejectUnauthorized: false
      }
    } : {},
    define: {
      timestamps: true,
      underscored: true,
    },
  }
);

module.exports = sequelize;
