require('log-timestamp');
const requireSQL = require('./util/requireSQL')
const run = requireSQL('dbscripts/k-anonymity/run.sql')
run() // this takes quite a while