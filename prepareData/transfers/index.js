const fs       = require('fs');
const folders = ['./data/individual', './data/ordered']

folders.forEach(f => fs.mkdirSync(f, { recursive: true }))

// 1. parse raw events
// 2. splitByToken
// 3. parse individual tokens