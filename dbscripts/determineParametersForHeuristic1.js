const requireSQL = require('./util/requireSQL')
const recalc = requireSQL('dbscripts/calculateDepositAddresses/exp_calculate.sql')
const success = requireSQL('dbscripts/calculateDepositAddresses/exp_determineSuccess.sql')

const fs = require('fs');

blockDelays = [180, 360, 4320, 8640, 17280, 25920, 34560, 43200, 51840, 60480]
percentages = [0.1, 0.2, 0.25, 0.33, 0.4, 0.45, 0.5, 0.6, 0.75]

writeHorriblyInefficient('numBlocks,percentage,numCappReceivers,numDepositAddresses,numFalsePositives,fps')
for (let numBlocks of blockDelays) {
    for (let percentage of percentages)
        console.log(`numBlocks: ${numBlocks} percentage: ${percentage}`)
        recalc({ minPercentageBehavedLikeDepositAddress: percentage, numBlocks })
        const ans = success(undefined, 'get')
        console.log(ans)
        writeHorriblyInefficient([numBlocks, percentage].concat(Object.values(ans)).join(','))
}

function writeHorriblyInefficient(line) {
    let writeStream = fs.createWriteStream('expOutput_v2.csv', {'flags': 'a'});
    writeStream.write(line+"\n")
    writeStream.end()
}