const requireSQL = require('./util/requireSQL')
const calculateEmptiedAddresses = requireSQL('dbscripts/calculateDepositAddresses/calculateEmptiedAddresses.sql')
const calculateDepositAddresses = requireSQL('dbscripts/calculateDepositAddresses/calculateDepositAddresses.sql')
const success = requireSQL('dbscripts/calculateDepositAddresses/exp_determineSuccess.sql')

const fs = require('fs');
let writeStream = fs.createWriteStream('expOutput.csv');

blockDelays = [180, 360, 4320, 8640, 17280, 60480]
percentages = [0.1, 0.2, 0.25, 0.33, 0.5, 0.75]
writeStream.write('numBlocks,percentage,numCappReceivers,numDepositAddresses,numFalsePositives\n')
for (let numBlocks of blockDelays) {
    for (let percentage of percentages) {
        console.log(`numBlocks: ${numBlocks} percentage: ${percentage}`)
        calculateEmptiedAddresses({numBlocks: numBlocks})
        calculateDepositAddresses({minPercentageBehavedLikeDepositAddress: percentage})
        const ans = success(undefined, 'get')
        console.log(ans)
        writeStream.write([numBlocks,percentage].concat(Object.values(ans)).join(',')+"\n")
    }
}
writeStream.end()