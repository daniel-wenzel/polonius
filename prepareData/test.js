const fs       = require('fs');
const zlib     = require('zlib');
const readline = require('readline');


const gzip = zlib.createGunzip()
gzip.on('error', (err) => {
    console.log("caught error!")
    console.error(err)
    lineReader.end()
})
const lineReader = readline.createInterface({
    input: fs.createReadStream('./data/ordered/0chain_0xb9ef770b6a5e12e45983c5d80545258aa38f3b78.csv.gz').pipe(gzip)
});

lineReader.on('line', (line) => {
});

lineReader.on('close', () => {
    console.log("done!")
})