const requireSQL = require('./requireSQL')
const commands = requireSQL('dbscripts/util/commands.sql')
commands() // this takes quite a while