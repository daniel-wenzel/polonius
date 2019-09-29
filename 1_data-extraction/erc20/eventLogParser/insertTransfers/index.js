const lineToTransfer = require('../../../../prepareData/util/lineToTransfer')
const fs = require('fs');
const readline = require('readline');
const zlib     = require('zlib');
const {insertTransfers, insertAccounts} = require('./insertOperations')

async function run() {
    const path = './data/ordered/'
    const files = fs.readdirSync(path)
    for (const file of files) {
        await readFile(path+file)
    }
    console.log("done done <3")
}

async function readFile(path) {
    let isFirstLine = true
    const fileStream = fs.createReadStream(path);

    const rl = readline.createInterface({
      input: fileStream.pipe(zlib.createGunzip()),
      crlfDelay: Infinity
    });

    let transfers = []
    let accounts = new Set()
    console.log("reading "+path)
    for await (const line of rl) {
        if (isFirstLine) {
            isFirstLine = false
            continue
        }
        const transfer = lineToTransfer(line)
        transfers.push(transfer)
        accounts.add(transfer.from)
        accounts.add(transfer.to)
    }
    console.log("read! adding "+accounts.size +" accounts to db.")
    insertAccounts(accounts) // synchronous
    console.log("accounts done. Doing "+transfers.length+" transfers")
    insertTransfers(transfers) // synchronous
    console.log(`finished ${path}`)
}

run()