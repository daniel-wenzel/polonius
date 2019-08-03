const fs = require('fs')
const zlib     = require('zlib');
const readline = require('readline');
const tokenData = require('../../fileLocations').getTokens()
const expandLine = require('./expandLine')
const Big = require('big.js');



console.log(tokenData.filter(t => t.decimals == undefined).map(t => {
    t.historicalData = undefined
    return t
}))

async function run() {

    for (token of tokenData) {
        if (token.decimals == undefined) {
            console.error("No decimals set for token "+token.slug)
            continue
        }
        await parseToken(token)
    }
}
run().catch(err => console.error(err))

let duplicates = 0
let firstLine = undefined
let lines = new Set()
function addLine(line) {
    if (firstLine == undefined) {
        firstLine = line
        return
    }
    /*if (lines.has(line)) {
        duplicates++
        return
    }*/
    lines.add(line)
}

function getInfo(line) {
    const vals = line.split(',')
    return {
        block: +vals[1],
        from: vals[2],
        to: vals[3]
    }
}

function compare(line1, line2) {
    const a = getInfo(line1)
    const b = getInfo(line2)

    if (a.block != b.block) return a.block-b.block
    const aline = a.from+a.to
    const bline = b.from+b.to
    if (aline > bline) return 1
    if (aline < bline) return -1
    return 0
}

function mergeSameBlockTransactions(array) {
    if (array.length == 0) {
        return array
    }
    const mergedLines = []
    let lastLine = array[0]
    for (let i=1; i<array.length; i++) {
        // from to and block are the same
        if (compare(lastLine, array[i]) == 0) {
            const amount1 = array[i].split(',')[4]
            const lineAsArray = lastLine.split(',')
            lineAsArray[4] = ""+Big(lineAsArray[4]).plus(Big(amount1))
            lastLine = lineAsArray.join(',')
        }
        else {
            mergedLines.push(lastLine)
            lastLine = array[i]
        }
    }
    mergedLines.push(lastLine)
    const numMerged = array.length - mergedLines.length
    console.log("   "+numMerged+ " of "+array.length+" lines merged")
    return mergedLines
}

async function parseToken(token) {
    const fileName = `${token.slug}_${token.address}.csv.gz`

    if (!fs.existsSync('./data/individual/'+fileName)) {
        console.log(`Omitting ${token.slug}: no transfers`)
        return 
    }
    if (fs.existsSync('./data/ordered/'+fileName)) {
        console.log(`Omitting ${token.slug}: already parsed`)
        return 
    }
    console.log("parsing "+token.slug)
    firstLine = undefined
    duplicates = 0
    lines = new Set()
    const expandLineT = expandLine(token)
    return new Promise((res, rej) => {
        const lineReader = readline.createInterface({
            input: fs.createReadStream('./data/individual/'+fileName).pipe(zlib.createGunzip())
        });
          
        lineReader.on('line', (line) => {
            addLine(line)
        });
        
        lineReader.on('close', () => {
            console.log("   read file! removed "+duplicates+" duplicates.")
            let array = Array.from(lines)
            lines = undefined // free up memory
            let sorted = mergeSameBlockTransactions(array.sort(compare))
            array = undefined // free up memory

            const output = fs.createWriteStream('data/ordered/'+fileName);
            const compress = zlib.createGzip();
            compress.pipe(output);
            //firstLine = 'token,blocknumber,from,to,amount,timestamp,slug,amountInTokens,currentUSDHigh,currentUSDLow,USDHigh,USDLow'
            firstLine = 'token,blocknumber,from,to,amount,id,slug,amountInTokens,amountInUSD'
            compress.write(firstLine+"\n")

            sorted.forEach(l => {
                const expandedLine = expandLineT(l)+"\n"
                compress.write(expandedLine)
            })
            compress.end()
            console.log("   wrote file")  
            compress.on('finish', res);
        })
    })
}