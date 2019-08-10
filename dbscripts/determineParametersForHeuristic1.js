const requireSQL = require('./util/requireSQL')
const calculateEmptiedAddresses = requireSQL('dbscripts/calculateDepositAddresses/calculateEmptiedAddresses.sql')
const calculateDepositAddresses = requireSQL('dbscripts/calculateDepositAddresses/calculateDepositAddresses.sql')
const success = requireSQL('dbscripts/calculateDepositAddresses/exp_determineSuccess.sql')

blockDelays = [180, 360, 4320, 8640, 17280, 60480]
percentages = [0.1, 0.2, 0.25, 0.33, 0.5, 0.75]

for (let numBlocks of blockDelays) {
    for (let percentage of percentages) {
        console.log(`numBlocks: ${numBlocks} percentage: ${percentage}`)
        //calculateEmptiedAddresses({numBlocks: numBlocks})
        //calculateDepositAddresses({minPercentageBehavedLikeDepositAddress: percentage})
        console.log(success(undefined, 'get')[0])
    }
}
