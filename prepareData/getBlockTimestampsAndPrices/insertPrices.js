const {getHistoricalMarketValue} = require('./../token/crawlHistoricalMarketValues')
const requireSQL = require('../../dbscripts/util/requireSQL')
const insertIntoPricingTable = requireSQL('./prepareData/getBlockTimestampsAndPrices/insertIntoPricingTable.sql')
const insertMissingPrices = requireSQL('./prepareData/getBlockTimestampsAndPrices/insertMissingPrices.sql')
const getTokens = requireSQL('./prepareData/getBlockTimestampsAndPrices/getTokens.sql')
const createPricingTable = requireSQL('./prepareData/getBlockTimestampsAndPrices/createPricingTable.sql')
const writePrices = requireSQL('./prepareData/getBlockTimestampsAndPrices/writePrices.sql')
const moment = require('moment')

async function insertPricesForToken(token) {
    const valuesRaw = await getHistoricalMarketValue(token)
    const values = valuesRaw.map(d => ({
        date: moment(d.date).format('X'),
        price: d.close,
        token: token
    }))
    values.forEach(value => insertIntoPricingTable(value))
}
async function run() {
    try {
        createPricingTable()
        const tokens = getTokens(undefined, 'all')
        console.log(tokens.length+" tokens found")
        for (const {token} of tokens) {
            await insertPricesForToken(token)
        }
        insertMissingPrices()
        for (const {token} of tokens) {
            writePrices({token})
        }
    }
    catch (e) {
        console.error(e)
    }
}
run()
