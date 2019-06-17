const dataDirRelative = '../data/'
const dataDirBase = 'data/'

const tokenFilename = 'tokens.json'

module.exports.getTokens = () => require(dataDirRelative + tokenFilename)
module.exports.getTokensWritePath = dataDirBase + tokenFilename