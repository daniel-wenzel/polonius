var cheerio = require('cheerio'); // Basically jQuery for node.js
const rp = require("request-promise") 
const moment = require('moment')

module.exports = async (blocknumber) => {
    var options = {
        uri: `https://etherscan.io/block/${blocknumber}`,
        transform: function (body) {
            return cheerio.load(body);
        }
    };
    const $ = await rp(options)
    const timeText = $('.fa-clock').parent().text()
    const time = timeText.split('(')[1].replace(')','').replace('+UTC', '').trim()
    const timestamp = +moment.utc(time, 'MMM-DD-YYYY hh:mm:ss a').format('X')
    
    return timestamp
}