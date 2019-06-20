const fetch = require("../util/fetch");
const getAllHrefsBySelector = require("../util/getAllHrefsBySelector");
const getAllTextBySelector = require("../../scrapers/util/getAllTextBySelector");
module.exports = async () => {
  console.log(`crawling richest addresses`);
  const perPage = 100;

  const url = `https://etherscan.io/accounts/?ps=${perPage}`;
  const $ = await fetch(url);
  const labels = getAllTextBySelector($, "td[width] + td")
  const addressesOnPage = getAllHrefsBySelector($, "tbody a[href]").map(
    a => a.split("/")[2]
  ).filter((a,i) => labels[i] !== '');
  return addressesOnPage
};
