const requireSQL = require('./util/requireSQL')
const init = requireSQL('dbscripts/taxonomy/pre_init.sql')
const getTimestamp = requireSQL('dbscripts/taxonomy/util_getTimestamp.sql')
const getMaxBlocknumber = requireSQL('dbscripts/taxonomy/util_getMaxBlocknumber.sql')


const steps = ['0_updateMetadata.sql', '1_type', '2_activness', '3_operator', '4_profitability']
const sqlCommands = steps.map(s => requireSQL('dbscripts/taxonomy/'+s+".sql"))
const createTaxonomy = (blocknumber) => {
    if (blocknumber == null) {
        blocknumber = getMaxBlocknumber({}, 'get')
    }
    const timestamp = getTimestamp({blocknumber},'get')
    sqlCommands.map(sql => sql({blocknumber, timestamp}))
}
init()
createTaxonomy()
