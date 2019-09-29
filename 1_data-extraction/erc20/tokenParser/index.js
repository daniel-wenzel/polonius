const crawlCoinMarketCap = require('./crawlCoinMarketCap')
const crawlHistoricalMarketValues = require('./crawlHistoricalMarketValues')
const getDecimals = require('./getDecimals')

//require('./schema') // create schema

async function run() {
    await crawlCoinMarketCap()
    await new Promise(res => setTimeout(res, 2500))
    await crawlHistoricalMarketValues()
    await new Promise(res => setTimeout(res, 2500))
    await getDecimals()
    require('./insertTokens') // sync
}

run().catch(err => console.error(err))