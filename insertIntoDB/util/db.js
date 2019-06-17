const Database = require('better-sqlite3');
const db = new Database('./db/test', { verbose: null });

module.exports = db