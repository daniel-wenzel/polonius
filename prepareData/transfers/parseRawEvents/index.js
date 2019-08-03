const gunzip = require('gunzip-maybe')
const tar = require('tar-stream')
const https = require('https')
const extract = tar.extract()
const es = require('event-stream')
const BigNumber = require('bignumber.js')


https.get('https://tubcloud.tu-berlin.de/s/tEHoSia5raaBDpG/download', (resp) => {
    resp.pipe(gunzip()).pipe(extract)
})

let numFiles = 0
extract.on('entry', function (header, stream, next) {
    // header is the tar header
    // stream is the content body (might be an empty stream)
    // call next when you are done with this entry
    numFiles ++
    stream.on('end', function () {
        console.log(numFiles)
        next() // ready for next entry
    })
    if (numFiles < 0) {
        stream.resume()
    }
    else {
        parseFileStream(stream)
    }
    // // just auto drain the stream
})

extract.on('finish', function () {
    // all entries read
})
let block
let i = 0;
function parseFileStream(stream) {
    stream
        .pipe(es.split())
        .pipe(es.filterSync(isTransfer))
        .pipe(es.filterSync(line => {
            if (i++ <50) {
                isTransfer(line)
                return true
            }
            process.exit(1)
            return false
        }))
        .pipe(es.mapSync(parseTransfer)) 
        .pipe(es.join('\n')) 
        .pipe(process.stdout)
}
function isTransfer(line) {
    const topicField = getTopicField(line, 5)
    if (topicField == '') {
        return false
    }
    if (topicField.indexOf("['0xddf252ad") != 0) {
        return false
    }
    if (topicField.split(',').length != 3) {
        return false
    }
    return true
}


function getTopicField(line) {
    const fieldStart = line.indexOf(',"[')+2
    const fieldEnd = line.indexOf(']",')+2
    return line.substring(fieldStart, fieldEnd)
}

function parseTransfer(line) {
    const tokenAddress = line.substring(0, line.indexOf(','))
    const blocknumber = parseInt(getField(line, 2))
    const amount = new BigNumber(getField(line, 3)).toString()
    const topicsRaw = getTopicField(line)
    const topics = topicsRaw.substring(1, topicsRaw.length-2).split(",")

    // topics contains commas and is therefore messing with the finding of fields
    const lineAfterTopic = line.substring(line.indexOf(']"')) 
    const id = getField(lineAfterTopic,2)+'-'+getField(lineAfterTopic,3)

    const trim = (t) => t.replace("'0x000000000000000000000000", '0x').replace("'","").trim()
    return [tokenAddress, blocknumber, trim(topics[1]), trim(topics[2]), amount,id].join(',')
}

function getField(line, id) {
    return line.substring(nthIndex(line, ',', id)+1, nthIndex(line, ',', id+1))
}

function nthIndex(str, pat, n){
    var L= str.length, i= -1;
    while(n-- && i++<L){
        i= str.indexOf(pat, i);
        if (i < 0) break;
    }
    return i;
}