const fs = require('fs');

const readPath = "../../data/tokens.json"
const writePath = 'data/tokens.json'

const cmcOverview = require(readPath).filter(a => a.address !== undefined)
let numUnsavedEntries = 0;

const rp = require('request-promise')

async function run() {
    for (token of cmcOverview) {

        //TODO: in the future to update newer data this needs to be changed
        if (token.decimals == undefined) {
            token.address = token.address.substring(0, 42)
            token.decimals = await getDecimals(token.address)
            console.log("got decimals for "+token.slug)
            console.log(token.decimals)
            await new Promise(res => setTimeout(res, 2000))
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
    save()
}
async function getDecimals(address) {
    const data = await rp.get(`http://api.ethplorer.io/getTokenInfo/${address}?apiKey=freekey`, {json:true})
    return +data.decimals
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