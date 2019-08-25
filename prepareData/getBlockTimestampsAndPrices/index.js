const blockStep = 8640

const getBlockTimestamp = require('./getBlockTimestamp')
const requireSQL = require('../../dbscripts/util/requireSQL')
const writeTimestamp = requireSQL('./prepareData/getBlockTimestampsAndPrices/writeTimestamp.sql')
const getMinMaxBlock = requireSQL('./prepareData/getBlockTimestampsAndPrices/getMinMaxBlock.sql')
const {minBlock, maxBlock} = getMinMaxBlock(null, 'get')
async function run() {
    let prevTime = await getBlockTimestamp(minBlock)
    for (let block=minBlock + blockStep; block <= maxBlock; block+=blockStep) {
        const curTime = await getBlockTimestamp(block)
        for (let blockMinor=block - blockStep; blockMinor<=block; blockMinor++) {
            let blockPercentage = (blockMinor - block + blockStep) / blockStep
            let time = Math.round((curTime - prevTime) * blockPercentage + prevTime)

            console.log(blockMinor +" "+time)
        }
        break
        
    }

}
console.log(minBlock, maxBlock)
//run()

