const fetch = require("../../../util/fetch")
const getAllHrefsBySelector = require("../../../util/getAllHrefsBySelector")
module.exports = async (label) => {
    console.log(`crawl label: ${label}`)
    const perPage = 100
    let allAddresses = []

    let page = 1
    let addressesOnPage = []
    do {
        console.log(`... page ${page}`)
        const url = `https://etherscan.io/accounts/label/${label}/${page}?ps=${perPage}`
        const $ = await fetch(url)
        addressesOnPage = getAllHrefsBySelector($, 'tbody a[href]').map(a => a.split('/')[2])
        allAddresses = allAddresses.concat(addressesOnPage)
        page ++
    }
    while (addressesOnPage.length == perPage)    
    
    return allAddresses
}