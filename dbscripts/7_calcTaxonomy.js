require('log-timestamp');

const requireSQL = require('./util/requireSQL')
const init = requireSQL('dbscripts/taxonomy/pre_init.sql')
const getTimestamp = requireSQL('dbscripts/taxonomy/util_getTimestamp.sql')
const getMaxBlocknumber = requireSQL('dbscripts/taxonomy/util_getMaxBlocknumber.sql')
const getAllTaxonomyBlocknumbers = requireSQL('dbscripts/taxonomy/util_getAllTaxonomyBlocknumbers.sql')


const steps = [
    '0_updateMetadata', 
    '1_type', 
    '2_activeness', 
    '3_operator', 
    '4_profitability', 
    '5_parentschildren',
    '6_holdingSize',
    '7_numberOfTokens',
    '8_age',
    '9_tokenbalances',
    '10_store_results'
]
const sqlCommands = steps.map(s => requireSQL('dbscripts/taxonomy/'+s+".sql"))
const createTaxonomy = (blocknumber) => {
    if (blocknumber == null) {
        blocknumber = getMaxBlocknumber({}, 'get').blocknumber
        console.log(blocknumber)
    }
    const timestamp = getTimestamp({blocknumber},'get').timestamp
    const day = ""+(Math.floor(timestamp / 86400) * 86400)
    console.log(timestamp)
    sqlCommands.map(sql => sql({blocknumber, timestamp, day}))
}
init()
createTaxonomy()
/*
const maxBlocknumber = getMaxBlocknumber({}, 'get').blocknumber
const blocks = []
const existingBlocks = getAllTaxonomyBlocknumbers(undefined, 'all').map(r => r.blocknumber)
for (let i = 0; i < 18; i++) {
    blocks.push(maxBlocknumber - 172800*i)
}
const blocksToBeCreated = blocks.filter(b => !existingBlocks.includes(b))
console.log(blocksToBeCreated.length+" taxonomies to go :)")
blocksToBeCreated.forEach(block => createTaxonomy(block))
*/