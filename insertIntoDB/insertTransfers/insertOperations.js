const db = require('../util/db')
const insertTransfers = db.prepare('INSERT OR IGNORE INTO Transfer (`from`, `to`, `token`, `blocknumber`) VALUES (@from, @to, @slug, @blockNumber)');
const insertAccounts = db.prepare('INSERT OR IGNORE INTO Account (address) VALUES (?)');


module.exports.insertTransfers = db.transaction(transfers => {
    transfers.forEach(t => {
        insertTransfers.run(t)
    })
})

module.exports.insertAccounts = db.transaction(accounts => {
    accounts.forEach(a => {
        insertAccounts.run(a)
    })
})