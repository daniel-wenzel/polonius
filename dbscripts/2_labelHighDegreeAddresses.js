const requireSQL = require('./util/requireSQL')
const labelHighDegreeAddresses = requireSQL('dbscripts/labelHighDegreeAddresses/run.sql')
labelHighDegreeAddresses() // this takes quite a while