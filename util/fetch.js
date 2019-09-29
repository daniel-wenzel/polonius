const cheerio = require("cheerio");
const rp = require("request-promise");

module.exports = async (url, backoff = 1000) => {
  try {
    var options = {
      uri: url,
      transform: function(body) {
        return cheerio.load(body);
      }
    };
    const $ = await rp(options);
    return $;
  } catch (e) {
    if (e.statusCode === 429) {
      backoff = (backoff || 1000) * 2 + Math.floor(Math.random() * 500);
      console.log(" ...Backing off for " + backoff / 1000 + " seconds");
      await new Promise(res => setTimeout(res, backoff));
      return module.exports(url, backoff);
    } else {
      throw e;
    }
  }
};
