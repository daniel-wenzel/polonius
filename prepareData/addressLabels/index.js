const addresses = require("../../data/etherscanLabels/addresses");
const labels = new Set(require("../../data/etherscanLabels/labels"));
let uncrawledAddresses = new Set(
  require("../../data/etherscanLabels/uncrawledAddresses")
);
let uncrawledLabels = new Set(
  require("../../data/etherscanLabels/uncrawledLabels")
);

const fs = require("fs");
let numParsed = 0

const crawlAddressPage = require("./crawlAddressPage");
const crawlLabelList = require("./crawlLabelList");
const crawlRichestAddresses = require("./crawlRichestAddresses");

async function run() {
    Object.values(addresses).filter(a => a.name == '' && a.tags.length == 0).map(a => a.address).forEach(a => uncrawledAddresses.add(a))
  if (uncrawledAddresses.size == 0 && uncrawledLabels.size == 0) {
    (await crawlRichestAddresses())
      .filter(a => addresses[a] == undefined)
      .forEach(a => uncrawledAddresses.add(a));
  }

  while (uncrawledAddresses.size || uncrawledLabels.size) {
    if (uncrawledAddresses.size > uncrawledLabels.size) {
      await crawlAddresses();
    } else {
      await crawlLabels();
    }
    numParsed ++
    if (numParsed % 50 == 0) {
        save();
    }
  }
  save()
}

async function crawlAddresses() {
  if (uncrawledAddresses.size == 0) return;
  const uncrawledAddress = uncrawledAddresses.values().next().value;
  const crawlResult = await crawlAddressPage(uncrawledAddress);
  crawlResult.tags
    .filter(t => !labels.has(t))
    .forEach(t => uncrawledLabels.add(t));
  addresses[uncrawledAddress] = crawlResult;
  uncrawledAddresses.delete(uncrawledAddress);
}

async function crawlLabels() {
  if (uncrawledLabels.size == 0) return;
  const uncrawledLabel = uncrawledLabels.values().next().value;
  const newAddresses = await crawlLabelList(uncrawledLabel);

  newAddresses
    .filter(a => addresses[a] == undefined)
    .forEach(a => uncrawledAddresses.add(a));
  labels.add(uncrawledLabel);
  uncrawledLabels.delete(uncrawledLabel)
}

function save() {
  console.log("saved!");
  saveFile("./data/etherscanLabels/addresses.json", addresses);
  saveFile("./data/etherscanLabels/labels.json", Array.from(labels));
  saveFile(
    "./data/etherscanLabels/uncrawledAddresses.json",
    Array.from(uncrawledAddresses)
  );
  saveFile(
    "./data/etherscanLabels/uncrawledLabels.json",
    Array.from(uncrawledLabels)
  );
}

function saveFile(filename, json) {
  fs.writeFile(filename, JSON.stringify(json, 0, 2), err => {
    if (err) {
      console.error(err);
      process.exit(1);
    }
  });
}

run().catch(err => console.error(err));
