const fetch = require("../util/fetch")
const getAllHrefsBySelector = require("../util/getAllHrefsBySelector")
module.exports = async (address) => {
    const url = `https://etherscan.io/address/${address}`

    const $ = await fetch(url)
    const tags = getAllHrefsBySelector($, '.mt-1 .u-label').map(a => a.split('/')[3])
    const name = $("[title='Public Name Tag (viewable by anyone)']").text().trim()
    const nameUrl = $("[title='Public Name Tag (viewable by anyone)'] [href]").attr('href')
    console.log(`crawled address ${address} (${name})`)
    
    return {
        address,
        tags,
        name,
        url: nameUrl
    }
}