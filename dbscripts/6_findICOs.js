const requireSQL = require('./util/requireSQL')
const run = requireSQL('dbscripts/findICOs/init.sql')
run() // this takes quite a while