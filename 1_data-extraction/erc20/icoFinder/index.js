const requireSQL = require('./util/requireSQL')
const run = requireSQL('1_dataextraction/erc20/icoFinder/findICOs/init.sql')
run() // this takes quite a while