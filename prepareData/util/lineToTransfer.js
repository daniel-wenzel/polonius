const fields = ['tokenAddress', 'blockNumber', 'from', 'to', 'amount', 'timestamp', 'slug', 'amountInTokens', 'amountInUSDCurrentHigh', 'amountInUSDCurrentLow', 'amountInUSDHigh', 'amountInUSDLow']
const numberFields = ['blockNumber', 'amountInTokens', 'amountInUSDCurrentHigh', 'amountInUSDCurrentLow', 'amountInUSDHigh', 'amountInUSDLow']
const dateFields = ['timestamp']
const moment = require('moment')
module.exports = (line) => {
    const entries = line.split(',')
    const result = {}
    for (let i=0; i< entries.length; i++) {
        result[fields[i]] = entries[i]
    }
    Object.keys(result).forEach(k => {
        if (numberFields.includes(k)) {
            result[k] = +result[k]
        }
        if (dateFields.includes(k)) {
            result[k] = moment.utc(result[k], 'X').toISOString()
        }
    })
    return result
}