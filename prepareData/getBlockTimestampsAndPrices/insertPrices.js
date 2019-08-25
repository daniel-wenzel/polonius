const {getHistoricalMarketValue} = require('./../token/crawlHistoricalMarketValues')
const requireSQL = require('../../dbscripts/util/requireSQL')
const insertIntoPricingTable = requireSQL('./prepareData/getBlockTimestampsAndPrices/insertIntoPricingTable.sql')
const getTokens = requireSQL('./prepareData/getBlockTimestampsAndPrices/getTokens.sql')
const createPricingTable = requireSQL('./prepareData/getBlockTimestampsAndPrices/createPricingTable.sql')
const writePrices = requireSQL('./prepareData/getBlockTimestampsAndPrices/writePrices.sql')
const moment = require('moment')

async function insertPricesForToken(token) {
    const valuesRaw = await getHistoricalMarketValue(token)
    console.log(token, valuesRaw)
    const values = valuesRaw.map(d => ({
        date: +moment(d.date).format('X'),
        price: d.close
    }))
    values.forEach(values => insertIntoPricingTable(values))
    writePrices({token})
}
async function run() {
    try {
        createPricingTable()
        const tokens = getTokens(undefined, 'all')
        console.log(tokens.length+" tokens found")
        for (const {token} of tokens) {
            await insertPricesForToken(token)
        }
    }
    catch (e) {
        console.error(e)
    }
}
run()
