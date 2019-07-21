const requireSQL = require('./util/requireSQL')
const findEarlyAddresses = requireSQL('dbscripts/findICOAddresses/isEarlyTransaction.sql')
findEarlyAddresses() // this takes quite a while