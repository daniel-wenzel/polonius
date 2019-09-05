var cheerio = require('cheerio'); // Basically jQuery for node.js
const rp = require("request-promise")

const readPath = "../../data/tokens.json"
const writePath = 'data/tokens.json'

const fs = require('fs');
const cmcOverview = require(readPath).filter(a => a.address !== undefined)
let numUnsavedEntries = 0;


async function run() {
    const currencies = await getCurrencies()
    for (currency of currencies) {
        // go through list to find orgs which were already added
        const currencySlug = currency.split('/')[4]
        if (cmcOverview.find(c => c.slug === currencySlug) !== undefined) {
            console.log("omitting "+currency)
            continue;
        }
        const data = await parseCMCPage(currency)
        if (data == undefined) continue
        console.log(data.name)
        numUnsavedEntries ++
        if (numUnsavedEntries > 5) save()
        cmcOverview.push(data)
    }
}
async function parseCMCPage(url, backoff) {
    try {
        var options = {
            uri: url,
            transform: function (body) {
                return cheerio.load(body);
            }
        };
        const $ = await rp(options)

        const explorerHrefs = getAllHrefsBySelector($, 'span[title="Explorer"] + a[href]')
        if (explorerHrefs.length == 0) {
            throw new Error("no Explorer found! Cant extract an address")
        }
        let address = explorerHrefs.map(e => e.split('/').find(p => p.startsWith('0x'))).reduce((a,b) => a == undefined? b:a)
        if (address == undefined) {
            // link is something like https://etherscan.io/token/Bat
            const etherscan = explorerHrefs.find(a => a.includes("etherscan"))
            if (etherscan == undefined) {
                console.error("no address found in "+url+ " omitting.")
                return
            }
            address = await followLinkAndExtractAddress(etherscan)
        }
        address = address.substring(0, 42).toLowerCase()
        const slug = url.split('/')[4]
        const name = $('h1 img').first().attr('alt')
        const logo = $('h1 img').first().attr('src')
        const ticker = $('h1 span').first().text().replace('(', '').replace(')', '')

        const marketCap = $('span[data-currency-market-cap]').first().attr('data-usd')
        const price = $('span[data-currency-price]').first().attr('data-usd')
        const marketVolume_24h = $('span[data-currency-volume]').first().attr('data-usd')

        const chats = getAllHrefsBySelector($, 'span[title="Chat"] + a[href]')
        const sourceCodes = getAllHrefsBySelector($, 'span[title="Source Code"] + a[href]')
        const messageBoards = getAllHrefsBySelector($, 'span[title="Message Board"] + a[href]')
        const announcements = getAllHrefsBySelector($, 'span[title="Announcement"] + a[href]')
        const website = getAllHrefsBySelector($, 'span[title="Website"] + a[href]')
        const whitepaper = getAllHrefsBySelector($, 'span[title="Technical Documentation"] + a[href]')


        const supplies = []
        $('span[data-format-supply]').each((i,e) => supplies.push($(e).attr('data-format-value')))
        const circulatingSupply = supplies[0]
        const totalSupply = supplies[1]

        return {
            address, slug, name, logo, ticker, website, whitepaper, price, marketCap, marketVolume_24h, circulatingSupply, totalSupply, chats, sourceCodes, announcements, messageBoards
        }
    }
    catch (e) {
        if (e.statusCode === 429) {
            backoff = (backoff || 1000) * 2 + Math.floor(Math.random() * 500)
            console.log(" ...Backing off for "+backoff/1000+" seconds")
            await new Promise(res => setTimeout(res, backoff))
            return parseCMCPage(url, backoff)

        }
        else {
            console.log(url)
            console.error(e)
            process.exit(1)
        }
    }
}

async function getCurrencies() {
    var options = {
        uri: 'https://coinmarketcap.com/tokens/views/all/',
        transform: function (body) {
            return cheerio.load(body);
        }
    };
    const $ = await rp(options)
    const orgs = []
    $('tr[data-platformsymbol="ETH"] a.currency-name-container[href]').each(function(i, elem) {
        orgs.push('https://coinmarketcap.com'+$(this).attr('href'));
      })
    return orgs
}

function save() {
    fs.writeFile(writePath, JSON.stringify(cmcOverview, 0, 2), (err) => {
        if (err) {
            console.error(err)
            process.exit(1)
        }
    })
}

function getAllHrefsBySelector($, selector) {
    const hits = []
    $(selector).each((i,e) => hits.push($(e).attr('href')))
    return hits
}

async function followLinkAndExtractAddress(url) {
    var options = {
        uri: url,
        resolveWithFullResponse: true
    };
    const response = await rp(options)
    const path = response.request.uri.path
    const address = path.split('/').find(p => p.startsWith('0x'))
    if (address == undefined) {
        throw new Error("could not find address in url: "+url)
    }
    return address
}
module.exports = run