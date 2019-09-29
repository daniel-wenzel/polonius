const fs       = require('fs');
const folders = ['./data/individual', './data/ordered']

folders.filter(f => !fs.existsSync(f)).forEach(f => fs.mkdirSync(f, { recursive: true }))

async function run() {
    await require('./parseRawEvents')()
    await require('./splitByToken')()
    await require('./parseIndividualTokens')()
    require('./insertTransfers')
}
run().catch(err => console.error(err))