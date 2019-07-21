const requireSQL = require('./util/requireSQL')
const findEarlyAddresses = requireSQL('dbscripts/findEarlyAddress/isEarlyTransaction.sql')
findEarlyAddresses() // this takes quite a while