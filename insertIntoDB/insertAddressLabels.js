const db = require('./util/db')
const labels = Object.values(require('../data/etherscanLabels/addresses.json'))
labels.forEach(t => {
    t.isExchange = t.tags.includes('exchange')? 1:0
    t.name = t.name || null
    t.url = t.url || null
})
const tokens = require('../data/tokens.json')
const insert = db.prepare('REPLACE INTO Address (address, name, url, isExchange) VALUES (@address, @name, @url, @isExchange)');
const insertTokenLabels = db.prepare('REPLACE INTO Address (address, name, url) VALUES (@address, @slug, @website)')

const insertTokenLabelsTX = db.transaction(() => {
    for (token of tokens) {
        token.website = token.website.length? token.website[0]: null
        token.historicalData = null
        insertTokenLabels.run(token)
    }
})
const insertEtherscanLabels = db.transaction(() => {
    for (const label of labels) {
        insert.run(label);
    }
});
console.log("inserting labels...")
insertTokenLabelsTX();
insertEtherscanLabels();
console.log("inserting labels done")