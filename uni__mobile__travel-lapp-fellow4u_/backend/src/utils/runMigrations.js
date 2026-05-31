const fs = require('fs');
const path = require('path');
const { sequelize } = require('../models');

/**
 * Script to run all SQL migrations in order from the database/ directory.
 */
const runMigrations = async () => {
  const dbDir = path.join(__dirname, '../../../docker/database');
  const files = fs.readdirSync(dbDir)
    .filter(file => file.endsWith('.sql'))
    .sort(); // Ensure order V1, V2, ...

  console.log('🚀 Starting Migrations...');

  for (const file of files) {
    console.log(`Running: ${file}`);
    const filePath = path.join(dbDir, file);
    const sql = fs.readFileSync(filePath, 'utf8');

    try {
      // Execute the entire SQL file
      await sequelize.query(sql);
      console.log(`✅ Success: ${file}`);
    } catch (error) {
      console.error(`❌ Error in ${file}:`, error.message);
      // We continue to next file unless it's a critical failure
    }
  }

  console.log('🏁 All migrations processed.');
  process.exit(0);
};

runMigrations();
