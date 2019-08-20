const db = require('../insertIntoDB/util/db')
const requireSQL = require('./util/requireSQL')

const init = requireSQL('dbscripts/calculateDepositAddresses/init.sql')
const calculateBalancesStep = requireSQL('dbscripts/calculateDepositAddresses/calculateBalancesStep.sql')
const calculateEmptiedAddresses = requireSQL('dbscripts/calculateDepositAddresses/calculateEmptiedAddresses.sql')
const calculateDepositAddresses = requireSQL('dbscripts/calculateDepositAddresses/calculateDepositAddresses.sql')
const calculateOtherExchangeAddresses = requireSQL('dbscripts/calculateDepositAddresses/calculateOtherExchangeAddresses.sql')
const labelTransfers = requireSQL('dbscripts/calculateDepositAddresses/labelTransfers.sql')

const maxDegreeToCalculateBalances = 500
const numBlocksDelayForDepositAddresses = 8640 // 1 day at 10 seconds blocktime 
const minPercentageBehavedLikeDepositAddress = 0.25

/*init({maxDegree: maxDegreeToCalculateBalances})

for (let i=0; i<maxDegreeToCalculateBalances; i++) {
    calculateBalancesStep()
    if (i % 1 == 0) {
        console.log(i+" done")
    }
}
calculateEmptiedAddresses({numBlocks: numBlocksDelayForDepositAddresses})
calculateDepositAddresses({minPercentageBehavedLikeDepositAddress})*/
calculateOtherExchangeAddresses()
//labelTransfers()