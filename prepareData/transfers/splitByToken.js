const fs       = require('fs');
const zlib     = require('zlib');
const readline = require('readline');

const interval = setInterval(status, 5000)
const cmcTokens = require('../fileLocations').getTokens()
const interestingAddresses = new Set()
cmcTokens.forEach(t => interestingAddresses.add(t.address))

let n = 0;
let firstLine = undefined

readTransfers()
/*const tokenCreationsReader = readline.createInterface({
    input: fs.createReadStream('./data/tokenCreations.csv.gz')
  });
  tokenCreationsReader.on('line', (line) => {
      const parts = line.split(',')
      // switch block number and address
      const replace = parts[1] 
      parts[1] = parts[0] 
      parts[0] = replace

      writeLine(parts.join(','))
  }).on('close', () => {
    console.log("added token creations")
    
})*/

function readTransfers() {
    const gzip = zlib.createGunzip()
    gzip.on('error', (err) => {
        console.log("FINISHED WITH ERROR")
        console.log(err)

        stop()
        console.log("check if all files were written correctly")
        lineReader.close()
    })
    const lineReader = readline.createInterface({
        input: fs.createReadStream('./data/transfers.csv.gz').pipe(gzip)
      });
      
    lineReader.on('line', (line) => {
        writeLine(line)
    });
    
    lineReader.on('close', () => {
        console.log("done!")
        stop()
    })
}

function stop() {
    clearInterval(interval)
    Object.values(streams).forEach(s => s.end())
}

function writeLine(line) {
    if (firstLine === undefined) {
        firstLine = line
        return
    }
  n++;
  const token = line.substring(0, line.indexOf(','))
  if (!isOfInterest(token)) return
  getStream(token).write(line+"\n")
}


function status() {
    const numLines = 62300149
    const percent = Math.floor(n / numLines * 10000)/100
    console.log(n+ ` lines parsed (${percent}%)`)
}

const streams = {}
function getStream(address) {
    if (streams[address] == undefined) {
        const name = cmcTokens.find(c => c.address == address).slug
        const output = fs.createWriteStream('data/individual/'+name+"_"+address+'.csv.gz');
        const compress = zlib.createGzip();
        /* The following line will pipe everything written into compress to the file stream */
        compress.pipe(output);
        compress.write(firstLine+"\n")
        streams[address] = compress
    }
    return streams[address]
}

function isOfInterest(token) {
    if (interestingAddresses.has(token)) return true
    return false

}