require('log-timestamp');

const requireSQL = require('./util/requireSQL')
const init = requireSQL('dbscripts/taxonomy/pre_init.sql')
const getTimestamp = requireSQL('dbscripts/taxonomy/util_getTimestamp.sql')
const getMaxBlocknumber = requireSQL('dbscripts/taxonomy/util_getMaxBlocknumber.sql')


const steps = [
    //'0_updateMetadata', 
    '1_type', 
    '2_activeness', 
    '3_operator', 
    '4_profitability', 
    '5_parentschildren',
    '6_holdingSize',
    '7_numberOfTokens'
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
