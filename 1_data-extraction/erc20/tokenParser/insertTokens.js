const db = require('./util/db')
const tokens = require('../data/tokens.json')

const insert = db.prepare('INSERT OR IGNORE INTO Token (id, decimals, name, address) VALUES (@slug, @decimals, @name, @address)');

const insertMany = db.transaction((tokens) => {
    for (const token of tokens) {
        if (token.decimals == undefined) {
            console.error(`Token ${token.slug}: no decimals set. ommitting.`)
            continue
        }
        insert.run(token);
    }
});
console.log("inserting tokens...")
insertMany(tokens);
console.log("inserting tokens done")