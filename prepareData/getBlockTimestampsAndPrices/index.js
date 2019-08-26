const blockStep = 86400

const getBlockTimestamp = require('./getBlockTimestamp')
const requireSQL = require('../../dbscripts/util/requireSQL')
const writeTimestamp = requireSQL('./prepareData/getBlockTimestampsAndPrices/writeTimestamp.sql')
const getMinMaxBlock = requireSQL('./prepareData/getBlockTimestampsAndPrices/getMinMaxBlock.sql')
const {minBlock, maxBlock} = getMinMaxBlock(null, 'get')
async function run() {
    let prevTime = await getBlockTimestamp(minBlock)
    let prevBlock = minBlock
    for (let block=minBlock + blockStep; block <= maxBlock+blockStep; block+=blockStep) {
        const curTime = await getBlockTimestamp(block)
        
        writeTimestamp({
            minTime: prevTime,
            maxTime: curTime,
            minBlock: prevBlock,
            maxBlock: block
        })
        
        await new Promise(res => setTimeout(res, 10000))

        prevTime = curTime
        prevBlock = block
    }
}
run()//.then(require('./insertPrices'))

