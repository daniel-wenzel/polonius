const Big = require('big.js');
const moment = require('moment')

module.exports = (token) => {
    token.historicalData.forEach(e => e.momentDate = moment.utc(e.date))
    const todaysValueHigh = new Big(token.historicalData[0].high)
    const todaysValueLow = new Big(token.historicalData[0].low)
    return (line) => {
        const entries = line.split(',')
        const day = moment.utc(entries[5], 'X')
        const amount = new Big(entries[4])
        const oneToken = Big(10).pow(token.decimals)
        const amountInTokens = amount.div(oneToken)
        //console.log(day.format('YYYY-MM-DD'))

        const amountInUSDCurrentHigh = round(amountInTokens.mul(todaysValueHigh))
        const amountInUSDCurrentLow = round(amountInTokens.mul(todaysValueLow))

        line += ','+token.slug+','+round(amountInTokens, 5)+','+amountInUSDCurrentHigh+','+amountInUSDCurrentLow
        // we rewind the list chronological to avoid costly list searches for every entry
        let tradingInfo = token.historicalData[token.historicalData.length -1]
        while (tradingInfo.momentDate.isBefore(day, 'day')) {
            //console.log("pop day! "+tradingInfo.dateReadable)
            token.historicalData.pop()
            tradingInfo = token.historicalData[token.historicalData.length -1]
        }
        if (tradingInfo.momentDate.isSame(day, 'day')) {
            //console.log("got trading info!")
            const amountInUSDHigh = round(amountInTokens.mul(Big(tradingInfo.high)))
            const amountInUSDLow = round(amountInTokens.mul(Big(tradingInfo.low)))
            line += ','+amountInUSDHigh+','+amountInUSDLow
        }
        return line
    }
}

function round(n, precision = 2) {
    const denom = Math.pow(10, precision)
    return Math.round(+n.toString()*denom)/denom
}