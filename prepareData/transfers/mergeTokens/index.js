const fs = require('fs');
const readline = require('readline');
const zlib     = require('zlib');

let firstLine = undefined
let runningFiles = 0
let currentBlock = 0

const awaitBlock = {}

const output = fs.createWriteStream('data/allCleaned.csv.gz');
const compress = zlib.createGzip()
/* The following line will pipe everything written into compress to the file stream */
compress.pipe(output);

async function doneWithBlock(nextBlock, cb) {
    runningFiles --
    if (nextBlock !== undefined) {
        const triggers = awaitBlock[nextBlock] || []
        triggers.push(cb)
        awaitBlock[nextBlock] = triggers
    }

    if (runningFiles == 0) {
        const smallestBlock = Math.min(...Object.keys(awaitBlock))
        currentBlock = smallestBlock
        if (currentBlock % 10000 == 0) {
            console.log(currentBlock)
        }
        const registerdCallBacks = awaitBlock[currentBlock] || []
        runningFiles = registerdCallBacks.length
        for (trigger of registerdCallBacks) {
            trigger()
        }
        delete awaitBlock[currentBlock]
    }
}

async function readFile(filePath) {
    const fileStream = fs.createReadStream(filePath);

    const rl = readline.createInterface({
      input: fileStream.pipe(zlib.createGunzip()),
      crlfDelay: Infinity
    });
    runningFiles ++
    for await (const line of rl) {
        const block = + line.split(',')[1]
        if (firstLine == undefined) {
            firstLine = line
            writeLine(line)
        }
        if (isNaN(block)) {
            continue
        }
        if (block > currentBlock) {
            await new Promise(res => {
                doneWithBlock(block, res)
            })
        }
        writeLine(line)
        if (currentBlock > 4660000) {
            break
        }
    }
    console.log(`finished ${filePath} (${Object.keys(awaitBlock).length} left)`)
    doneWithBlock()
}

function writeLine(line) {
    compress.write(line+"\n")
}
async function run() {
    const path = './data/ordered/'
    const files = fs.readdirSync(path)
    const promises = files.map(f => readFile(path+f))
    await Promise.all(promises)
    compress.end()
    console.log("done with parsing (probably still writing things in the stream for a minute)")
}

run()


