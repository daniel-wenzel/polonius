const Database = require('better-sqlite3');
const db = new Database('./db/baltasar.db', { verbose: null });

module.exports = db