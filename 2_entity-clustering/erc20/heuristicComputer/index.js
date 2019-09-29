const db = require('../../../util/db')
const requireSQL = require('../../../util/requireSQL')

const init = requireSQL('2_entity-clustering/erc20/heuristicComputer/sql/init.sql')
const calculateBalancesStep = requireSQL('2_entity-clustering/erc20/heuristicComputer/sql/calculateBalancesStep.sql')
const calculateEmptiedAddresses = requireSQL('2_entity-clustering/erc20/heuristicComputer/sql/calculateEmptiedAddresses.sql')
const calculateDepositAddresses = requireSQL('2_entity-clustering/erc20/heuristicComputer/sql/calculateDepositAddresses.sql')
const calculateOtherExchangeAddresses = requireSQL('2_entity-clustering/erc20/heuristicComputer/sql/calculateOtherExchangeAddresses.sql')
const labelTransfers = requireSQL('2_entity-clustering/erc20/heuristicComputer/sql/labelTransfers.sql')

const maxDegreeToCalculateBalances = 500
const numBlocksDelayForDepositAddresses = 8640 // 1 day at 10 seconds blocktime 
const minPercentageBehavedLikeDepositAddress = 0.25

init({maxDegree: maxDegreeToCalculateBalances})

for (let i=0; i<maxDegreeToCalculateBalances; i++) {
    calculateBalancesStep()
    if (i % 1 == 0) {
        console.log(i+" done")
    }
}
calculateEmptiedAddresses({numBlocks: numBlocksDelayForDepositAddresses})
calculateDepositAddresses({minPercentageBehavedLikeDepositAddress})
calculateOtherExchangeAddresses()
labelTransfers()