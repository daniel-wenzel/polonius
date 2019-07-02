const db = require('../insertIntoDB/util/db')
const requireSQL = require('./util/requireSQL')



const init = requireSQL('dbscripts/findICOAddresses/balanceHopperInit.sql')
const step = requireSQL('dbscripts/findICOAddresses/balanceHopper.sql')

init()
for (let i=0; i< 10000; i++) {
    step()
    console.log(i)
}