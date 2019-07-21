const requireSQL = require('./util/requireSQL')
const findPaperWallets = requireSQL('dbscripts/findPaperWallets/init.sql')
findPaperWallets() // this takes quite a while