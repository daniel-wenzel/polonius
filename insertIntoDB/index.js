/*require('./schema')// sync
require('./insertTokens') // sync
require('./insertTransfers') // not sync, doenst return anything

*/
const db = require('./util/db')
console.log("running the query")
db.prepare('REPLACE INTO Address (address, indegree) SELECT t.`to`,count(*) as indegree FROM Transfer t GROUP BY t.`to`').run()
console.log("done")