const fs       = require('fs');
const folders = ['./data/individual', './data/ordered']

folders.forEach(f => fs.mkdirSync(f, { recursive: true }))