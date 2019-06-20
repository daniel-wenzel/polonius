const db = require('../../insertIntoDB/util/db')
const fs = require('fs')

module.exports = (path) => {
    const statementFile = fs.readFileSync('./'+path, {encoding: 'utf-8'})
    return db.transaction((args) => {
        const pathElements = path.split('/')
        console.log("Running "+pathElements[pathElements.length-1])
        statementFile.split(';').forEach(statement => {
            if (statement.trim() == "") return
            const startTime = Date.now()
            console.log(statement.trim())
            if (args != undefined) {
                db.prepare(statement).run(args)
            }
            else {
                db.prepare(statement).run()
            }
            const timeInSeconds = Math.round((Date.now() -startTime)/100)/10
            console.log(`Finished in ${timeInSeconds} seconds`)
        })
    })
}