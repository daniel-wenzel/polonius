const db = require('../util/db')
const insertTransfers = db.prepare('INSERT OR IGNORE INTO Transfer (`from`, `to`, `token`, `blocknumber`, amount, timestamp, amountInTokens, amountInUSDCurrent) VALUES (@from, @to, @slug, @blockNumber, @amount, null, @amountInTokens, @amountInUSD)');
const insertAccounts = db.prepare('INSERT OR IGNORE INTO Address (address) VALUES (?)');


module.exports.insertTransfers = db.transaction(transfers => {
    transfers.forEach(t => {
        try {
            insertTransfers.run(t)
        }
        catch (e){
            console.error(e)
            console.log(t)
            process.exit(1)
        }
    })
})

module.exports.insertAccounts = db.transaction(accounts => {
    accounts.forEach(a => {
        insertAccounts.run(a)
    })
})