const fs = require('fs');

const readPath = "../../data/tokens.json"
const writePath = 'data/tokens.json'
const cmcOverview = require(readPath).filter(a => a.address !== undefined)

const fetch = require("../util/fetch")
const getAllAttributesBySelector = require("../util/getAllAttributesBySelector")
const getAllTextBySelector = require("../util/getAllTextBySelector")
const moment = require('moment')
let numUnsavedEntries = 0;


async function run() {
    for (token of cmcOverview) {
        try {
            //TODO: in the future to update newer data this needs to be changed
            if (token.historicalData === undefined) {
                token.historicalData = await getHistoricalData(token.slug)
                numUnsavedEntries ++
            }
            else {
                console.log('omitting '+token.slug)
            }

            if (numUnsavedEntries > 5) {
                save()
                numUnsavedEntries = 0
            }
        }
        catch (e) {
            console.error(e)
        }
    }
}
async function getHistoricalData(slug) {
    const $ = await fetch(`https://coinmarketcap.com/currencies/${slug}/historical-data/?start=20130428&end=20190523`)
    const dates = getAllTextBySelector($, '#historical-data tbody .text-left')
    const values = getAllAttributesBySelector($, '#historical-data tbody [data-format-value]', 'data-format-value').map(i => +i)

    let iValue = 0
    const results = []
    for (let i=0; i<dates.length; i++) {
        const date = moment.utc(dates[i], 'MMM DD, YYYY')
        results.push({
            date: date.format(),
            dateReadable: date.format('YYYY-MM-DD'),
            open: values[iValue++],
            high: values[iValue++],
            low: values[iValue++],
            close: values[iValue++],
            volume: values[iValue++],
            marketCap: values[iValue++]
        })
    }
    console.log(`${slug}: found ${results.length} dates`)
    return results
}

function save() {
    fs.writeFile(writePath, JSON.stringify(cmcOverview, 0, 2), (err) => {
        if (err) {
            console.error(err)
            process.exit(1)
        }
    })
    console.log('saved!')
}

module.exports = run